%sampling frequency determines the bandwidth. (user defined)
channel_order = 50;
seq_len = 10000;
nfft = 20;
snr = 30;
fs = 16000;

channel_model = randn(1,channel_order);
channel_freq_response = fft(channel_model, nfft);

sig = randn(1,seq_len);

sig_filt = fftfilt(channel_model,sig);
%add Noise
noiseSig = awgn(sig_filt,snr);

[Pout] = pwelch(noiseSig,1000, 500, nfft, fs);  %recorded signal PSD

[Ps] = pwelch(sig,1000,500,nfft,fs);
%let ps go through filter
TfSquared = channel_freq_response*conj(channel_freq_response)';

PsFiltered = TfSquared*Ps;


Pn = Pout - PsFiltered % Calculate actual signal power

plot([1:11],Pn)

