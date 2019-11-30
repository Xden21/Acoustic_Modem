function Pn = get_noise_power(output_sig,channel_model,fs,nfft)
[Pout] = pwelch(output_sig,1000, 500, nfft, fs);  %recorded signal PSD
TfSquared = abs(channel_model).^2;
Pn = real(Pout' - TfSquared);
end


