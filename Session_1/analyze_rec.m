fs = 16000;
t = 0:1/fs:2;
%sig = 1+sin(2*pi*400*t); %DC component added.
dftsize = 256;

%sig for 2.8
%sig = sin(2*pi*100*t)+sin(2*pi*200*t)+sin(2*pi*500*t)+sin(2*pi*1500*t)+sin(2*pi*2000*t)+sin(2*pi*4000*t)+sin(2*pi*6000*t);

%white nois signal for 2.9
sig = rand(1,2*fs);
sig(1) = 1; %Used as anchor point to find start of signal


% Rescales input! (see ex. 2.7)
[simin,nbsecs,fs] = initparams(sig,fs);

WhiteNoiseSignal = simin(:,1);

sim('recplay');
out = simout.signals.values;

%close all;

% Spectrogram
figure;
subplot(2,1,1);
spectrogram(sig, 3200, 1600, dftsize, fs, 'yaxis');
title("Input Signal");
subplot(2,1,2);
spectrogram(out, 3200, 1600, dftsize, fs, 'yaxis');
title("Output Signal with noise");
% 
% figure;
% % PSD
% subplot(2,1,1);
% periodogram(sig, [], length(sig),fs);
% title("PSD Input Signal");
% subplot(2,1,2);
% periodogram(out, [], length(sig),fs);
% title("PSD Output Signal with noise");
% 
% figure;
% % Bartlett
% subplot(2,1,1);
% pwelch(sig,1000, 0, dftsize, fs);
% title("PSD Bartlett Input Signal");
% subplot(2,1,2);
% pwelch(out, 1000, 0, dftsize, fs);
% title("PSD Bartlett Output Signal with noise");
% 
figure;
% Welch
subplot(2,1,1);
pwelch(sig, 1000, 500, dftsize, fs);
title("PSD Welch Input Signal");
subplot(2,1,2);
pwelch(out, 1000, 900, dftsize, fs);
title("PSD Welch Output Signal with noise");
ylim([-100,-20]);