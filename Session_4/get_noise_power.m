function Pn = get_noise_power(input_sig, output_sig,channel_model,fs,nfft)
[Pin] = pwelch(input_sig, 1000,500, nfft, fs, 'twosided');
figure;
plot(Pin);
title('Pin')

[Pout] = pwelch(output_sig, 1000,500, nfft, fs, 'twosided');  %recorded signal PSD
figure;
plot(Pout);
title('Pout')

TfSquared = abs(channel_model).^2;
Pn = real(Pout - (TfSquared').*Pin);
end


