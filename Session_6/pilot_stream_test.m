% This script does the channel estimation, with support of the function
% that can do bitloading

load IRest.mat;
%close all;
nfft = 1024;  %DFT-size
prefix_length = 60;
channel_order = 50;
qam_dim = 4;
fs = 16000;
%random bitstream
dataset = randi([0 1],1,fs*2);

%pilot signals
pilotbits = randi([0 1],1,qam_dim*(nfft/4));
pilot_symbs = qam_mod(pilotbits, qam_dim);

%qam modulated tr   aining block
% trainblock = qam_mod(trainbits,qam_dim);

%ofdm of train seq
qam_orders = no_bit_loading(nfft, qam_dim);
Tx = ofdm_mod_bl_pilot(dataset',qam_orders,prefix_length, pilot_symbs);
%part of channel model
channel_model = h(1:channel_order);
channel_freq_resp = fft(channel_model, nfft);

Rx = fftfilt(channel_model, Tx);

% figure; plot(sigout); title('received');
% figure;
% plot(Rx); hold on; plot(Tx); hold off; legend('Rx', 'Tx'); title('aligned');

% Demodulaten using 
[received,calc_channel_freq_resp] = ofdm_demod_bl_pilot(Rx,qam_orders,prefix_length,pilot_symbs);
%received = qam_demod(output_sig, qam_dim);
% figure;
% plot(abs(output_sig(50:100)));
% hold on;
% plot(abs(ofdm_train_seq(50:100)));
% hold off;
% legend('output_sig','input sig')
% est_channel_model = ifft(calc_channel_freq_resp, nfft);
% %----------------legende-omgekeerd????---------------
% figure;
% plot(abs(calc_channel_freq_resp));
% title('calculated channel freq');
% hold on;
% plot(abs(channel_freq_resp));
% hold off;
% legend('estimated response','measured response')
% 
% figure;
%  plot(channel_model);
%  hold on;
%  plot(est_channel_model);
%  title('channel model');
%  hold off;
%  legend('estimated response','measured response')
% figure;
% L = length(est_channel_model);
% Y = fft(est_channel_model);
% F2 = abs(Y/L);
% F1 = F2(1:L/2+1);
% F1(2:end-1) = 2*F1(2:end-1);
% f = fs*(0:(L/2))/L;
% plot(f, 20*log10(F1));
% title('Single-Sided Amplitude Spectrum of the Impulse response')
% xlabel('f (Hz)')
% ylabel('P1 (dB)')
% ylim([-100,-20]);

ber(dataset, received) 
