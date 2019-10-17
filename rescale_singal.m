function [signal] = rescale_singal(signal)
% Removes signal by removing the DC value en dividing by the maximum
% absolute amplitude.

    DC = mean(signal);
    signal = signal - DC;
  	max_val = max(abs(signal));
    if max_val ~= 0
        signal = signal / max_val;
    end
end

