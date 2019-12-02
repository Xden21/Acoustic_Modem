function Pn = get_noise_power(output_sig,channel_model,fs,nfft)
[Pout_db] = pwelch(output_sig, 1000,500, nfft, fs, 'twosided');  %recorded signal PSD
Pout = power(10,Pout_db./10);
TfSquared = abs(channel_model).^2;
Pn = real(Pout' - TfSquared);
end


