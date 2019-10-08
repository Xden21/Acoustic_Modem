% Plays a test sound.

fs = 16000;
t = 0:1/fs:2;
sinewave = sin(2*pi*1500*t);
[simin,nbsecs,fs] = initparams(sinewave,fs);
sim('recplay');
out = simout.signals.values;
soundsc(out, fs);