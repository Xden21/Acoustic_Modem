function Pn = get_noise_power(channel_model,fs,nfft,snr)
sig = randn(1,2*fs);

channel_freq_response = fft(channel_model, nfft);

sig_filt = fftfilt(channel_model,sig);
noiseSig = awgn(sig_filt,snr);
[Pout] = pwelch(noiseSig,1000, 500, nfft, fs);  %recorded signal PSD

[Ps] = pwelch(sig,1000,500,nfft,fs);
%let ps go through filter
TfSquared = abs(channel_freq_response).^2;

Ps = [Ps',fliplr(Ps(2:(length(Ps)-1)))'];
PsFiltered = TfSquared.*Ps;


Pn = real([Pout',fliplr(Pout(2:(length(Pout)-1)))'] - PsFiltered);
end


