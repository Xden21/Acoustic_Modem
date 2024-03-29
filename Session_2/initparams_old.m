function [simin,nbsecs,fs] = initparams_old(toplay,fs)
    % Rescale to interval between -1 and 1 (ex. 2.7)
    toplay = rescale_singal(toplay);
    simin = zeros(2*fs + length(toplay) + fs,2);
    simin(2*fs+1:2*fs+length(toplay), 1) = toplay';
    simin(2*fs+1:2*fs+length(toplay), 2) = toplay';
    nbsecs = size(simin,1)/fs;
end
