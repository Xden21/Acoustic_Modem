%Calculate impuls response.

fs = 16000;
sig = [randn(1,2*fs)]; %impulse
dftsize = 256;
[simin,nbsecs,fs] = initparams(sig,fs);

sim('recplay');
sigout = simout.signals.values;


[~,startVal] = max(sigout);
row = [sig(1),zeros(1,249)];
xToep = toeplitz(sig,row);


firstPeak = 1;
amountOfPeaks = 0;
notDone = 0;
i = 1;
while notDone == 0
    
            if firstPeak ==1
                if sigout(i)>0.45
                    firstPeak = i;
                end
            end
            if i> (firstPeak + 50)
                firstPeak = 1;
                amountOfPeaks =0;
            else
                if sigout(i)>0.45
                    amountOfPeaks = amountOfPeaks+1;
                end
            end
            if amountOfPeaks >=5
                notDone = 1;
            end

    if i >= length(sigout)
        notDone = 1;
    else
        i = i+1;
    end
end
plot(sigout);
firstPeak
figure;
y = (sigout(firstPeak:firstPeak+length(sig)-1));
h = (xToep\y)';
plot(h);



