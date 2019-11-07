%sampling frequency determines the bandwidth. (user defined)
channel_order = 50;
nfft = 20;
snr = 30;
fs = 16000;

channel_model = randn(1,channel_order);
channel_freq_response = fft(channel_model, nfft);

sig = randn(1,2*fs);

sig_filt = fftfilt(channel_model,sig);
%add Noise
noiseSig = awgn(sig_filt,snr);

[Pout] = pwelch(noiseSig,1000, 500, nfft, fs);  %recorded signal PSD

[Ps] = pwelch(sig,1000,500,nfft,fs);
%let ps go through filter
TfSquared = channel_freq_response*conj(channel_freq_response)';

Ps = [Ps',fliplr(Ps(2:(length(Ps)-1)))']
PsFiltered = TfSquared*Ps;


Pn = real([Pout',fliplr(Pout(2:(length(Pout)-1)))'] - PsFiltered) % Calculate actual signal power




% Parameters
seq_len = 10000;
qam_dim = 4;
nfft = 20;
prefix_length = 6;

% sequence generation
seq = randi([0,1],1,seq_len);

%Basic
qam_orders = qam_dim .* ones(nfft,1);
qam_orders(1) = 0; % DC
qam_orders(nfft/2+1) = 0; % Nyquist frequency

mod_seq = ofdm_mod_bl(seq', qam_orders, prefix_length);

rxOfdmStream = awgn(mod_seq, snr);
% Ofmd demodulation
demod_seq = ofdm_demod_bl(rxOfdmStream, qam_orders,prefix_length);

% BER
ber(seq, demod_seq') %ber basic


% Adaptive
qam_orders = adaptive_bit_loading(channel_freq_response, Pn);

mod_seq = ofdm_mod_bl(seq', qam_orders, prefix_length);

rxOfdmStream = awgn(mod_seq, snr);
% Ofmd demodulation
demod_seq = ofdm_demod_bl(rxOfdmStream, qam_orders,prefix_length);

% BER
ber(seq, demod_seq') %ber adaptive