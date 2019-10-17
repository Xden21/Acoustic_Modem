%Calculate impuls response.

fs = 16000;
sig = [1,zeros(1,fs)]; %impulse
dftsize = 256;
[simin,nbsecs,fs] = initparams(sig,fs);

sim('recplay');
sigout = simout.signals.values; %Noise and signal together.

[~,startVal] = max(sigout);
startVal = max(1, startVal-20);
endVal = startVal + 100;

%close all;
figure;
sgtitle('Measured Impulse Response');
subplot(2,1,1);
impulseResponseMeasured = sigout(startVal:endVal);
plot(impulseResponseMeasured);
title('Time domain impulse response')
xlabel('sample (k)')
ylabel('signal');
ylim([-1,1]);
subplot(2,1,2);
L = endVal - startVal;

y = sigout(startVal:endVal);
Y = fft(y);
F2 = abs(Y/L);
F1 = F2(1:L/2+1);
F1(2:end-1) = 2*F1(2:end-1);
f = fs*(0:(L/2))/L;
plot(f, 20*log10(F1));
title('Single-Sided Amplitude Spectrum of the Impulse response')
xlabel('f (Hz)')
ylabel('P1 (dB)')
ylim([-100,-20])