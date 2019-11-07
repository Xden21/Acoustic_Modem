%sampling frequency determines the bandwidth. (user defined)
channel_order = 10;
nfft = 500;
snr = 10;
fs = 16000;

qam_dim = 6;
prefix_length = 11;

channel_model = randn(1,channel_order);
channel_freq_response = fft(channel_model, nfft);

sig = randn(1,2*fs);

sig_filt = fftfilt(channel_model,sig);
%add Noise
noiseSig = awgn(sig_filt,snr);

[Pout] = pwelch(noiseSig,1000, 500, nfft, fs);  %recorded signal PSD

[Ps] = pwelch(sig,1000,500,nfft,fs);
%let ps go through filter
TfSquared = abs(channel_freq_response).^2;

Ps = [Ps',fliplr(Ps(2:(length(Ps)-1)))'];
PsFiltered = TfSquared.*Ps;


Pn = real([Pout',fliplr(Pout(2:(length(Pout)-1)))'] - PsFiltered) % Calculate actual signal power




% sequence generation
seq = randi([0,1],1,2*fs);

%Basic
% qam_orders = qam_dim .* ones(nfft,1);
% qam_orders(1) = 0; % DC
% qam_orders(nfft/2+1) = 0; % Nyquist frequency
qam_orders = no_bit_loading(nfft, qam_dim);
mod_seq = ofdm_mod_bl(seq', qam_orders, prefix_length);

rxOfdmStream = fftfilt(channel_model, mod_seq);
%rxOfdmStream = awgn(rxOfdmStream, snr);
%rxOfdmStream = mod_seq;
% Ofmd demodulation
demod_seq = ofdm_demod_bl(rxOfdmStream, qam_orders,prefix_length, channel_freq_response);

% BER
ber(seq, demod_seq') %ber basic


% Adaptive
qam_orders = adaptive_bit_loading(channel_freq_response, Pn);

mod_seq = ofdm_mod_bl(seq', qam_orders, prefix_length);

rxOfdmStream = fftfilt(channel_model, mod_seq);
%rxOfdmStream = awgn(rxOfdmStream, snr);
% Ofmd demodulation
demod_seq = ofdm_demod_bl(rxOfdmStream, qam_orders,prefix_length, channel_freq_response);

% BER
ber(seq, demod_seq') %ber adaptive