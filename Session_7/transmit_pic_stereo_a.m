nfft = 512;
qam_dim = 6;
prefix_length =150;
Lt = 10; %amount of training frames
Ld = 30; %amount of data frames
fs = 16000;
channel_order = 100;

% Generate two random channels
channel_1 = randn(1,channel_order);
channel_2 = randn(1,channel_order);
H1 = fft(channel_1, nfft);
H2 = fft(channel_2, nfft);
H1_2 = sqrt(abs(H1).^2 + abs(H2).^2);

[a, b] = fixed_transmitter_side_beamformer(channel_1, channel_2, nfft);
%b = zeros(size(a));
%a = ones(size(b));
figure;
hold on;plot((abs(H1))); plot((abs(H2))); plot((abs(H1_2))); hold off;
title('H^1, H^2, H^{1+2}');
legend('H^1', 'H^2', 'H^{1+2}');
ylabel('magnitude')
xlim([1 nfft])

qam_orders = no_bit_loading(nfft,qam_dim);

bitcount = 0;
for i=1:nfft/2
    bitcount = bitcount + qam_orders(i);
end
trainbits = randi([0 1],1,bitcount);

[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');
%qamStream = qam_mod(bitStream, qam_dim);
[ofdmStream1, ofdmStream2, trainblock,amount_of_packs] = ofdm_mod_stereo(bitStream,qam_orders,prefix_length,trainbits,Lt,Ld,a, b);

sigout1 = fftfilt(channel_1, ofdmStream1);
sigout2 = fftfilt(channel_2, ofdmStream2);
sigout = sigout1 + sigout2;
sigout = awgn(sigout,30);

[output_sig,calc_channel_freq_resp] = ofdm_demod_bl(sigout,qam_orders,prefix_length,trainblock,Lt,Ld); %no need for the stereo version, it's the same
received = output_sig;
ber(bitStream',received)