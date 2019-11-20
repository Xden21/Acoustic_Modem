load IRest.mat;
nfft = 512;
qam_dim = 4;
prefix_length =260;
Lt = 4; %amount of training frames
Ld = 5; %amount of data frames

trainbits = randi([0 1],1,qam_dim*(nfft/2-1));

%qam modulated training block
trainblock = qam_mod(trainbits,qam_dim);

%get image data.
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');
qamStream = qam_mod(bitStream, qam_dim);
ofdmStream = ofdm_mod(qamStream,trainblock,nfft, prefix_length,Lt,Ld);

%test for BER 0;

[simin,nbsecs,fs,sync_pulse] = initparams(Tx,fs,channel_order);
sigout = fftfilt(h(1:channel_order),simin(:,1));
%with accoustic channel
%sim('recplay');
%sigout = simout.signals.values;
Rx =alignIO(sigout,sync_pulse,channel_order);

[output_sig,calc_channel_freq_resp] = ofdm_demod(Rx,nfft,prefix_length,trainblock,Lt,Ld);
size(calc_channel_freq_resp)
plot(abs(calc_channel_freq_resp(:,1)))
hold on;
plot(abs(calc_channel_freq_resp(:,2)))
plot(abs(calc_channel_freq_resp(:,3)))
plot(abs(calc_channel_freq_resp(:,4)))
plot(abs(calc_channel_freq_resp(:,5)))
received = qam_demod(output_sig, qam_dim);
ber(bitStream,received);
