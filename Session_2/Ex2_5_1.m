close all;
run('IR1'); % Ouputs impulseResponseMeasured
run('analyze_rec'); % Outputs WhiteNoiseSignal

filtSig = fftfilt(impulseResponseMeasured, WhiteNoiseSignal);

% PSDfigure
figure;
subplot(2,1,1);
sgtitle("Comparing actual noise with calculated channel model")
spectrogram(filtSig, 3200, 1600, dftsize, fs, 'yaxis')
title("PSD Filtered signal");

subplot(2,1,2);
pwelch(filtSig, 1000, 900, dftsize, fs);
title("PSD Welch Output Signal with noise");
