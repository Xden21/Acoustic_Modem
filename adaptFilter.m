%sampling frequency determines the bandwidth. (user defined)
channel_order = 5;
seq_len = 10000;
qam_dim = 4;
nfft = 20;
prefix_length = 6;
snr = 30;
fs = 16000;
%-------------------------------EXAMPLE SEE MAIN-----------------------
%make an impulse response
%add noise
%convolution with H
%outcome ->psd
%psd-H*X ( fft input sig)
%this is the noise psd

%Create sequence and channel
seq = randi([0,1],1,seq_len);
channel_model = randn(1,channel_order);
channel_freq_response = fft(channel_model, nfft);

%use the basic transmission.
qam_orders = qam_dim .* ones(nfft,1);
qam_orders(1) = 0; % DC
qam_orders(nfft/2+1) = 0; % Nyquist frequency

%make time domain signal
mod_seq = ofdm_mod_bl(seq', qam_orders, prefix_length);
%go through filter
mod_seq_filt = fftfilt(channel_model,mod_seq);
%add Noise
noiseOfdmStream = awgn(mod_seq_filt,snr);
%Ofmd demodulation
demod_seq = ofdm_demod_bl(noiseOfdmStream, qam_orders,prefix_length);

% BER
ber(seq, demod_seq') %should not be equal to zero

[Pout] = pwelch(demod_seq,1000, 500, nfft, fs);  %recorded signal PSD

[Ps] = pwelch(mod_seq,1000,500,nfft,fs);
%let ps go through filter
TfSquared = channel_freq_response*conj(channel_freq_response)';

PsFiltered = TfSquared*Ps;


Pn = Pout - PsFiltered; % Calculate actual signal power

