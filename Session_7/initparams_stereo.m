function [simin,nbsecs,fs,sync_pulse] = initparams_stereo(toplay_left,toplay_right,fs,ir_length)
    if length(toplay_left) ~= length(toplay_right)
        error('Left and right signal should be equally long.');
    end
    x = 0:1/fs:0.1;
    sync_pulse = sin(2*pi*1000*x)+sin(2*pi*1000*x)+sin(2*pi*2000*x);    
    sync_pulse = sync_pulse./max(sync_pulse);
    toplay_left = [sync_pulse,zeros(1,ir_length),toplay_left.'].';
    toplay_right = [sync_pulse,zeros(1,ir_length),toplay_right.'].';
    % Rescale to interval between -1 and 1 (ex. 2.7)
    simin = zeros(2*fs + length(toplay_left) + fs,2);
    simin(2*fs+1:2*fs+length(toplay_left), 1) = toplay_left';
    simin(2*fs+1:2*fs+length(toplay_right), 2) = toplay_right';
    nbsecs = size(simin,1)/fs;
end

