function [simin,nbsecs,fs,sync_pulse] = initparams(toplay,fs,ir_length)
    x = 0:1/fs:0.1;
    sync_pulse = sin(2*pi*5500*x) +sin(2*pi*1000*x)+sin(2*pi*2000*x);    
    sync_pulse = sync_pulse./max(sync_pulse);
    toplay = rescale_singal(toplay);
    toplay = [sync_pulse,zeros(1,ir_length),toplay']';
    % Rescale to interval between -1 and 1 (ex. 2.7)
    simin = zeros(2*fs + length(toplay) + fs,2);
    simin(2*fs+1:2*fs+length(toplay), 1) = toplay';
    simin(2*fs+1:2*fs+length(toplay), 2) = toplay';
    nbsecs = size(simin,1)/fs;
end

