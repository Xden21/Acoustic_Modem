function qam_symbol_array = decision_device(symbol_array, qam_orders)
    if length(qam_orders) == 1
        qam_orders = qam_orders*ones(size(symbol_array));
    end
    if length(symbol_array) ~= length(qam_orders)
        error('arrays are of different length');
    end
    %Intiger for qam dim if we have equal qam dimensions
    qam_symbol_array = zeros(1,length(symbol_array));
    
    for symbol = 1:length(symbol_array)
        if symbol_array(symbol) ~= 0 && qam_orders(symbol) ~= 0% If zero, stay zero
            y = qammod((0:2^qam_orders(symbol)-1),2^qam_orders(symbol),'UnitAveragePower',true);
            [~,ind] = min(abs(symbol_array(symbol).'-y));
            qam_symbol_array(symbol) = y(ind);
        end
    end
end
