function ofdm_packet = on_off_bit_loading(sig, channel_model,qam_order, channel_fraction)
    %ON_OFF_BIT_LOADING Summary of this function goes here
    %   Detailed explanation goes here

    % Choose which channels will be used.
    
    % Determine which frequency bins we want to use
    sorted_coef = sort(channel_model, 'descend');
    ind = ceil(length(sorted_coef)*channel_fraction);

    min_val = sorted_coef(ind);

    
    for i=1:length(channel_model)
        if channel_model(i) < min_val
            channel_model(i) = 0;
        else
            channel_model(i) = qam_order;
        end
    end
    qam_orders = [channel_model,0,fliplr(channel_model)];
    ofdm_packet = build_ofdm_packet(sig,qam_orders);
    % Build packet so that the non used frequency bins are zero.
    
end