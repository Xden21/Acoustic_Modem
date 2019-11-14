load IRest.mat;
nfft = 80;  %DFT-size
prefix_length = 55;
channel_order = 50;
qam_dim = 4;
fs = 16000;
%random bitstream
trainbits = randi([0 1],1,qam_dim*(nfft/2-1));

%qam modulated training block
trainblock = qam_mod(trainbits,qam_dim);

%make a sequence of 100 trainingblocks
ofdm_train_seq = repmat(trainblock,1,100);
%ofdm of train seq
Tx = ofdm_mod(ofdm_train_seq,nfft,prefix_length);
[simin,nbsecs,fs,sync_pulse] = initparams(Tx,fs,150);
sim('recplay');
sigout = simout.signals.values;
Rx =alignIO(sigout,sync_pulse);
%part of channel model


% Demodulaten using 
[output_sig,calc_channel_freq_resp] = ofdm_demod(Rx,nfft,prefix_length,trainblock);
received = qam_demod(output_sig, qam_dim);

est_channel_model = ifft(calc_channel_freq_resp, nfft);
%----------------legende-omgekeerd????---------------
plot(abs(calc_channel_freq_resp));
% hold on;
% plot(abs(channel_freq_resp));
% hold off;
% legend('estimated response','measured response')

figure;
%   plot(channel_model);
% hold on;
 plot(est_channel_model);
% hold off;
% legend('estimated response','measured response')

ber(trainbits, received)
