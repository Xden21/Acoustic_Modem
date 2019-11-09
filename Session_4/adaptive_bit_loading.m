function qam_orders = adaptive_bit_loading(channel_model, noise_power,max_order)
    %ADAPTIVE_BIT_LOADING Summary of this function goes here
    %   Detailed explanation goes here
    if nargin ==2
        max_order = 6;
    end
    gamma = 2^4*10;
    
    if length(channel_model) ~= length(noise_power)
        error('vector lengths dont match');
    end
    qam_orders = zeros(length(channel_model),1);
    for i=2:length(qam_orders)/2
        order = min( floor(log2(1+((abs(channel_model(i)).^2)/(gamma*noise_power(i))))),floor(log2(1+((abs(channel_model(end-i+2)).^2)/(gamma*noise_power(end-i+2))))));
        if (order  > max_order) || (noise_power(i)<=0) || (noise_power(end-i+2) <= 0)
            qam_orders(i) = max_order;
            qam_orders(end-i+2) = max_order;
        else
            qam_orders(i) = order;
            qam_orders(end-i+2) = order;
        end
    end
end

