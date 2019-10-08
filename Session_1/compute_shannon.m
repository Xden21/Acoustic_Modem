%Estimates the capacity of the channel.
%sampling frequency determines the bandwidth. (user defined)
fs = 16000;


%channel is not flat, noise has gaussian distribution but is not white.
sig = sin(2*pi*1000*t) % original signal
[simin,nbsecs,fs] = initparams(sig,fs);

sim('recplay');
Ps = simout.signals.values; %Noise and signal together.


N= 100 %frequency bins.
Ps %recorded signal
Pn %noise power in bin k ( %why scaling)

for i = 1:N
    C = C+ log2(1+Ps(i)/Pn(i));
end
C = C*fs/2/N;