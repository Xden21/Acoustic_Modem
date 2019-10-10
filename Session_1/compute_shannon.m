%Estimates the capacity of the channel.
%sampling frequency determines the bandwidth. (user defined)
fs = 16000;

t = 0:1/fs:2;

%channel is not flat, noise has gaussian distribution but is not white.
sig = sin(2*pi*1000*t); % original signal
[simin,nbsecs,fs] = initparams(sig,fs);

sim('recplay');
sigout = simout.signals.values; %Noise and signal together.

dftsize = 256; %dftsize => bins is dftsize/2.
[Ps] = pwelch(sigout,1000, 500, dftsize, fs);  %recorded signal PSD

sig = zeros(2*fs,1);% noise signal
[simin,nbsecs,fs] = initparams(sig,fs);

sim('recplay');
noiseout = simout.signals.values; %Noise and signal together.

[Pn] = pwelch(noiseout,1000, 500, dftsize, fs);  %recorded noise PSD 

Ps = Ps - Pn; % Calculate actual signal power

%noise power in bin k ( %why scaling) => with discritisation of intergral
%you must scale the values
C=0;
for i = 1:(dftsize/2)
    C = C + log2(1+Ps(i)/Pn(i));
end
C = C*fs/dftsize
