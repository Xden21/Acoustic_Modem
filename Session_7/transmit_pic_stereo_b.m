close all;
clear;
nfft = 512;
qam_dim = 6;
prefix_length =350;
Lt = 20; %amount of training frames
Ld = 0; %amount of data frames
fs = 16000;
channel_order = 100;

% Generate two random channels
channel_1 = randn(1,channel_order);
channel_2 = randn(1,channel_order);
H1 = fft(channel_1, nfft);
H2 = fft(channel_2, nfft);


qam_orders = no_bit_loading(nfft,qam_dim);
bitcount = 0;
for i=1:nfft/2
    bitcount = bitcount + qam_orders(i);
end
trainbits = randi([0 1],1,bitcount);


[a, b] = fixed_transmitter_side_beamformer(channel_1, channel_2, nfft);
%channel 1 estimation
b = zeros(size(a));
a = ones(size(b));

[ofdmStream1_left, ofdmStream1_right, trainblock,amount_of_packs] = ofdm_mod_stereo(0,qam_orders,prefix_length,trainbits,Lt,Ld,a, b);

%channel 2 estimation
a = zeros(size(a));
b = ones(size(b));

[ofdmStream2_left, ofdmStream2_right, trainblock,amount_of_packs] = ofdm_mod_stereo(0,qam_orders,prefix_length,trainbits,Lt,Ld,a, b);


ofdmStream_left = [ofdmStream1_left; ofdmStream2_left];
ofdmStream_right = [ofdmStream1_right; ofdmStream2_right];


[simin,nbsecs,fs,sync_pulse] = initparams_stereo(ofdmStream_left,ofdmStream_right,fs,channel_order);

%sigout1 = fftfilt(channel_1, simin(:,1));
%sigout2 = fftfilt(channel_2, simin(:,2));
%sigout = sigout1 + sigout2;
%sigout = awgn(sigout,30);
sim('recplay');
sigout = simout.signals.values;

aligned_sigout = alignIO(sigout,sync_pulse,channel_order);
aligned_sigout = aligned_sigout(1:length(ofdmStream_left),:);

[x,calc_channel_freq_resp] = ofdm_demod_bl(aligned_sigout,qam_orders,prefix_length,trainblock,Lt,Ld);%no need for the stereo version, it's the same
% figure;
% plot(abs(calc_channel_freq_resp(:,1)))
% hold on
% plot(abs(H1))
% hold off;
% title('First channel estimation')
% 
% figure;
% plot(abs(calc_channel_freq_resp(:,2)))
% hold on
% plot(abs(H2))
% hold off;
% title('Second channel estimation')
% 
% %error plot
% figure;
% errors_h1 = abs(calc_channel_freq_resp(:,1)-H1');
% plot(errors_h1);
% title('Error on H1')
% 
% figure;
% plot(ifft(calc_channel_freq_resp(:,1).',nfft))
% title('IR channel 1')
% 
% 
% figure;
% subplot(2,1,1)
% plot(angle(H1));
% subplot(2,1,2)
% plot(angle(calc_channel_freq_resp(:,1)))
% 
%%
figure;
subplot(2,1,1)
plot(abs(calc_channel_freq_resp(:,1)));
subplot(2,1,2)
plot(abs(calc_channel_freq_resp(:,2)));
channel_left = calc_channel_freq_resp(:,1);
channel_right = calc_channel_freq_resp(:,2);
%%

[a, b] = fixed_transmitter_side_beamformer(channel_left,channel_right, nfft);
%%
Lt = 10;
Ld = 30;
qam_orders = no_bit_loading(nfft,qam_dim);

bitcount = 0;
for i=1:nfft/2
    bitcount = bitcount + qam_orders(i);
end
trainbits = randi([0 1],1,bitcount);
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

[leftStream, rightStream, trainblock,amount_of_packs] = ofdm_mod_stereo(bitStream,qam_orders,prefix_length,trainbits,Lt,Ld,a, b);
leftStream = real(leftStream);
rightStream = real(rightStream); %waarom complex geworden???

[simin,nbsecs,fs,sync_pulse] = initparams_stereo(leftStream,rightStream,fs,channel_order);
%%
sim('recplay');
sigout = simout.signals.values;

aligned_sigout_data = alignIO(sigout,sync_pulse,channel_order);
aligned_sigout_data = aligned_sigout_data(1:length(leftStream),:);


[output_sig,calc_channel_freq_resp_data] = ofdm_demod_bl(aligned_sigout_data,qam_orders,prefix_length,trainblock,Lt,Ld); %no need for the stereo version, it's the same
received = output_sig;
ber(bitStream',received)



%%
figure;
hold on
plot(abs(calc_channel_freq_resp_data(:,1)))
plot(abs(calc_channel_freq_resp_data(:,4)))
plot(abs(calc_channel_freq_resp_data(:,3)))
plot(abs(calc_channel_freq_resp_data(:,2)))
hold off;