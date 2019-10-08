function [simin,nbsecs,fs] = initparams(toplay,fs)
%INITPARAMS TODO

    % Rescale to interval between -1 and 1 (ex. 2.7)
    toplay = rescale(toplay,-1,1);
    simin = zeros(2*fs + length(toplay) + fs,2);
    simin(2*fs+1:2*fs+length(toplay), 1) = toplay';
    simin(2*fs+1:2*fs+length(toplay), 2) = toplay';
    nbsecs = size(simin,1)/fs;
end

