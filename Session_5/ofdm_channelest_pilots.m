load IRest.mat;
close all;

nfft = 126;  %DFT-size
prefix_length = 55;
channel_order = 50;
qam_dim = 4;

%random bitstream
trainbits = randi([0 1],1,qam_dim*(nfft/2-1));

%qam modulated training block
trainblock = qam_mod(trainbits,qam_dim);

% For pilot tones, only use the odd half (so set even half to zero)
trainblock_pilot = zeros(size(trainblock));
trainblock_pilot(1:2:end) = trainblock(1:2:end);

%make a sequence of 100 trainingblocks
ofdm_train_seq = repmat(trainblock_pilot,1,100);
%ofdm of train seq
Tx = ofdm_mod(ofdm_train_seq,nfft,prefix_length);

%part of channel model
channel_model = h(1:channel_order);
channel_freq_resp = fft(channel_model, nfft);
%fitler the train seq
Rx = fftfilt(channel_model,Tx);

% Demodulaten using 
[output_sig,calc_channel_freq_resp] = ofdm_demod_pilot(Rx,nfft,prefix_length,channel_freq_resp,trainblock_pilot);
received = qam_demod(output_sig, qam_dim);

est_channel_model = ifft(calc_channel_freq_resp, nfft);
figure;
plot(abs(calc_channel_freq_resp));
hold on;
plot(abs(channel_freq_resp));
hold off;
legend('estimated response','measured response')

figure;
plot(ifft(channel_freq_resp, nfft));
hold on;
plot(est_channel_model);
hold off;
legend('estimated response','measured response')

sent_bits = qam_demod(trainblock_pilot, qam_dim);
ber(sent_bits, received)