%Calculate impuls response.

fs = 16000;
sig = rand(1,2*fs); %impulse
sig(1) = 1;
filteredSig = band_stop_filter(sig,700,3000,fs);
[simin,nbsecs,fs] = initparams(filteredSig,fs);

sim('recplay');
sigout = simout.signals.values;

row = [filteredSig(1),zeros(1,249)];
xToep = toeplitz(filteredSig,row);

%Searches for the beginning of the signal
firstPeak = 1;
amountOfPeaks = 0;
done = 0;
i = 1;
while done == 0    
            if firstPeak ==1
                if abs(sigout(i))>0.3
                    firstPeak = i;
                end
            end
            if i> (firstPeak + 2500)
                firstPeak = 1;
                amountOfPeaks =0;
            else
                if abs(sigout(i))>0.4
                    amountOfPeaks = amountOfPeaks+1;
                end
            end
            if amountOfPeaks >=50
                done = 1;
            end

    if i >= length(sigout)
        disp('none found')
        done = 1;
    else
        i = i+1;
    end
end
%firstPeak
firstPeak = max(1, firstPeak - 20);
y = (sigout(firstPeak:firstPeak+length(filteredSig)-1));
figure;
h = (xToep\y)';
sgtitle('Estimated Impulse Response');
subplot(2,1,1);
plot(h);
title('Time domain impulse response')
xlabel('sample (k)')
ylabel('signal');
ylim([-1,1]);

subplot(2,1,2);
L = length(h);
Y = fft(h);
F2 = abs(Y/L);
F1 = F2(1:L/2+1);
F1(2:end-1) = 2*F1(2:end-1);
f = fs*(0:(L/2))/L;
plot(f, 20*log10(F1));
title('Single-Sided Amplitude Spectrum of the Impulse response')
xlabel('f (Hz)')
ylabel('P1 (dB)')
ylim([-100,-20]);
