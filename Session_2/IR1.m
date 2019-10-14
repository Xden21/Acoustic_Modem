%Calculate impuls response.

fs = 16000;
sig = [1,zeros(1,5*fs)]; %impulse
dftsize = 256;
[simin,nbsecs,fs] = initparams(sig,fs);

sim('recplay');
sigout = simout.signals.values; %Noise and signal together.

