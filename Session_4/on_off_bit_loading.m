function qam_orders = on_off_bit_loading(channel_model,qam_order, channel_fraction)
    %ON_OFF_BIT_LOADING Summary of this function goes here
    %   Detailed explanation goes here

    % Choose which channels will be used.
    
    % Determine which frequency bins we want to use (we use magnitude to
    % determine biggest attenuation)
    sorted_coef = sort(abs(channel_model), 'descend');
    
    %only half of the fraction must be deleted, because their conjugate
    %position will be deleted too
    ind = length(sorted_coef) - ceil(length(sorted_coef)*channel_fraction/2);

    min_val = sorted_coef(ind);
    
    qam_orders = zeros(1, length(channel_model));
    for i=2:length(channel_model)/2
        % check both current bin and conjugate bin
        if abs(channel_model(i)) < min_val || abs(channel_model(end-i+1)) < min_val
            qam_orders(i) = 0;
            % Mirror on conjugate
            qam_orders(end-i+2) = 0;
        else
            qam_orders(i) = qam_order;
            % Mirror on conjugate
            qam_orders(end-i+2) = qam_order;
        end
    end    
end