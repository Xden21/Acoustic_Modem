function ofdm_packet = on_off_bit_loading(sig, channel_model,qam_order, channel_fraction)
    %ON_OFF_BIT_LOADING Summary of this function goes here
    %   Detailed explanation goes here

    % Choose which channels will be used.
    
    % Determine which frequency bins we want to use
    sorted_coef = sort(channel_model, 'descend');
    
    %only half of the fraction must be deleted, because their conjugate position will be deleted too
    ind = ceil(length(sorted_coef)*channel_fraction/2);

    min_val = sorted_coef(ind);

    for i=1:length(channel_model)/2
        % check both current bin and conjugate bin
        if channel_model(i) < min_val || channel_model(end-i+1) < min_val
            channel_model(i) = 0;
            % Mirror on conjugate
            channel_model(end-i+1) = 0;
        else
            channel_model(i) = qam_order;
            % Mirror on conjugate
            channel_model(end-i+1) = qam_order;
        end
    end
    ofdm_packet = build_ofdm_packet(sig,qam_orders);
    % Build packet so that the non used frequency bins are zero.    
end