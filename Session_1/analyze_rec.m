fs = 16000;
t = 0:1/fs:2;
sig = sin(2*pi*400*t);

dftsize = 512;

[simin,nbsecs,fs] = initparams(sig,fs);
sim('recplay');
out = simout.signals.values;

close all;
% Spectrogram
subplot(2,1,1);
spectrogram(sig, 3200, 1600, dftsize, fs, 'yaxis');
title("Input Signal");
subplot(2,1,2);
spectrogram(out, 3200, 1600, dftsize, fs, 'yaxis');
title("Output Signal with noise");

figure;
% PSD
subplot(2,1,1);
periodogram(sig, [], dftsize,fs);
title("PSD Input Signal");
subplot(2,1,2);
periodogram(out, [], dftsize,fs);
title("PSD Output Signal with noise");

figure;
% Bartlett
subplot(2,1,1);
pwelch(sig,1000, 0, dftsize, fs);
title("PSD Bartlett Input Signal");
subplot(2,1,2);
pwelch(out, 1000, 0, dftsize, fs);
title("PSD Bartlett Output Signal with noise");

figure;
% Welch
subplot(2,1,1);
pwelch(sig, 1000, 900, dftsize, fs);
title("PSD Welch Input Signal");
subplot(2,1,2);
pwelch(out, 1000, 900, dftsize, fs);
title("PSD Welch Output Signal with noise");