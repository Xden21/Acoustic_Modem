%Calculate impuls response.

fs = 16000;
sig = [1,zeros(1,fs)]; %impulse
dftsize = 256;
[simin,nbsecs,fs] = initparams(sig,fs);

sim('recplay');
sigout = simout.signals.values;
[~,startVal] = max(sigout);
endVal = startVal + 250;
subplot(2,1,1);
plotSign = sigout(startVal-15:endVal);
plot(plotSign);

subplot(2,1,2);
plot(abs(fft(plotSign,fs)));

