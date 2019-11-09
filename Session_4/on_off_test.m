%sampling frequency determines the bandwidth. (user defined)
channel_order = 10;
nfft = 500;
snr = 20;
fs = 16000;
qam_dim = 6;
prefix_length = 13;

channel_model = randn(1,channel_order);
channel_freq_response = fft(channel_model, nfft);

seq = randi([0,1],1,2*fs);

%Basic
% qam_orders = qam_dim .* ones(nfft,1);
% qam_orders(1) = 0; % DC
% qam_orders(nfft/2+1) = 0; % Nyquist frequency
qam_orders = no_bit_loading(nfft, qam_dim);
mod_seq = ofdm_mod_bl(seq', qam_orders, prefix_length);

rxOfdmStream = fftfilt(channel_model, mod_seq);
size(rxOfdmStream)
noise = 0.2*randn(1,length(rxOfdmStream));
noiseRaw = lowpass(noise,4000,fs)' + 0.1*randn(1,length(rxOfdmStream))';
rxOfdmStream = rxOfdmStream+noiseRaw;
%rxOfdmStream = awgn(rxOfdmStream, snr);
%rxOfdmStream = mod_seq;
% Ofmd demodulation
demod_seq = ofdm_demod_bl(rxOfdmStream, qam_orders,prefix_length, channel_freq_response);

% BER
ber(seq, demod_seq') %ber basic


% On-Off bit loading
qam_orders = on_off_bit_loading(channel_freq_response, qam_dim,0.5);
mod_seq = ofdm_mod_bl(seq', qam_orders, prefix_length);
rxOfdmStream = fftfilt(channel_model, mod_seq);
noise = 0.2*randn(1,length(rxOfdmStream));
noiseRaw = lowpass(noise,4000,fs)' + 0.1*randn(1,length(rxOfdmStream))';
rxOfdmStream = rxOfdmStream+noiseRaw;
%rxOfdmStream = awgn(rxOfdmStream, snr);
% Ofmd demodulation
demod_seq = ofdm_demod_bl(rxOfdmStream, qam_orders,prefix_length, channel_freq_response);

% BER
ber(seq, demod_seq') %ber adaptive