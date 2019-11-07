function qam_orders = adaptive_bit_loading(channel_model, noise_power)
    %ADAPTIVE_BIT_LOADING Summary of this function goes here
    %   Detailed explanation goes here
    gamma = 10;
    
    if length(channel_model) ~= length(noise_power)
        error('vector lengths dont match');
    end
    
    qam_orders = zeros(length(channel_model),1);
    for i=1:length(qam_orders)
        qam_orders(i) = floor(log2(1+((abs(channel_model(i)).^2)/(gamma*noise_power(i)))));
        if qam_orders(i) > 6
            qam_orders(i) = 6;
        end
    end
    qam_orders(1) = 0;
    qam_orders(length(qam_orders)/2 + 1) = 0;
end

