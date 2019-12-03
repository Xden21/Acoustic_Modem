function qam_symbol_array = decision_device(symbol_array, qam_dim)
    %Intiger for qam dim if we have equal qam dimensions
    qam_symbol_array = zeros(1,length(symbol_array));
    y = qammod((0:2^qam_dim-1),2^qam_dim,'UnitAveragePower',true);
    for symbol = 1:length(symbol_array)
        [~,ind] = min(abs(symbol_array(symbol).'-y));
        qam_symbol_array(symbol) = y(ind);
    end
end
