function qam_symbol = decision_device(symbol, qam_dim)
    y = qammod((0:2^qam_dim-1)',2^qam_dim,'UnitAveragePower',true);
    [~,ind] = min(abs(symbol-y));
    qam_symbol = y(ind);
end
