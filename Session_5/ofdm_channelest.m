load IRest.mat;
%close all;
nfft = 512;  %DFT-size
prefix_length = 350;
channel_order = 250;
qam_dim = 4;
fs = 16000;
%random bitstream
trainbits = randi([0 1],1,qam_dim*(nfft/2-1));

%qam modulated tr   aining block
trainblock = qam_mod(trainbits,qam_dim);
qam_orders = no_bit_loading(nfft, qam_dim);
%make a sequence of 100 trainingblocks
ofdm_train_seq = repmat(trainblock,1,100);
%ofdm of train seq
Tx = ofdm_mod_est(ofdm_train_seq,qam_orders,prefix_length);
[simin,nbsecs,fs,sync_pulse] = initparams(Tx,fs,channel_order);
sigout = fftfilt(h(1:channel_order),simin(:,1));

%sim('recplay');
%sigout = simout.signals.values;
Rx =alignIO(sigout,sync_pulse,channel_order);
%part of channel model
figure; plot(sigout); title('received');
figure;
plot(Rx); hold on; plot(Tx); hold off; legend('Rx', 'Tx'); title('aligned');

% Demodulaten using 
[output_sig,calc_channel_freq_resp] = ofdm_demod_est(Rx,qam_orders,prefix_length,trainblock);
received = qam_demod(output_sig, qam_dim);
figure;
plot(abs(output_sig(50:100)));
hold on;
plot(abs(ofdm_train_seq(50:100)));
hold off;
legend('output_sig','input sig')
est_channel_model = ifft(calc_channel_freq_resp, nfft);
%----------------legende-omgekeerd????---------------
% figure;
% plot(abs(calc_channel_freq_resp));
% title('calculated channel freq');
% hold on;
% plot(abs(channel_freq_resp));
% hold off;
% legend('estimated response','measured response')

figure;
%   plot(channel_model);
% hold on;
 plot(est_channel_model);
 title('channel model');
% hold off;
% legend('estimated response','measured response')
figure;
L = length(est_channel_model);
Y = fft(est_channel_model);
F2 = abs(Y/L);
F1 = F2(1:L/2+1);
F1(2:end-1) = 2*F1(2:end-1);
f = fs*(0:(L/2))/L;
plot(f, 20*log10(F1));
title('Single-Sided Amplitude Spectrum of the Impulse response')
xlabel('f (Hz)')
ylabel('P1 (dB)')
ylim([-100,-20]);

ber(trainbits, received) 
