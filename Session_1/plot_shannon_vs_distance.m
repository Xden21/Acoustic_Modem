%Estimates the capacity of the channel.
%sampling frequency determines the bandwidth. (user defined)
fs = 16000;

t = 0:1/fs:2;

C = zeros(10,1);

for i=1:10
    disp('next');
    sig = sin(2*pi*10000*t); % original signal
    soundsc(sig, fs);
    pause(4);
    disp('ssst');

    
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
    

    for j = 1:(dftsize/2)
        C(i) = C(i) + log2(1+Ps(j)/Pn(j));
    end
    C(i) = C(i)*fs/dftsize
    

end
x = 5:5:50;
figure;
plot(x,C);
xlabel("Distance (cm)");
ylabel("Channel Capacity (bits/s)");
title("Channel capacity over distance");

