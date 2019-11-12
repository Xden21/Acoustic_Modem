load IRest.mat;
nfft = 80;  %DFT-size
prefix_length = 55;
channel_order = 50;
qam_dim = 4;
%random bitstream
trainbits = randi([0 1],1,qam_dim*(nfft/2-1));
%qam modulated training block
trainblock = qam_mod(trainbits,qam_dim);
%make a sequence of 100 trainingblocks
ofdm_train_seq = repmat(trainblock,1,100);
%ofdm of train seq
Tx = ofdm_mod(ofdm_train_seq,nfft,prefix_length);
%part of channel model
channel_model = h(1:nfft);
channel_freq_resp = fft(channel_model);
%fitler the train seq
Rx = fftfilt(channel_model,Tx);
[output_sig,calc_channel_freq_resp] = ofdm_demod(Rx,nfft,prefix_length,channel_freq_resp,trainblock);
plot(abs(calc_channel_freq_resp).^-1);
hold on;
plot(abs(channel_freq_resp));
