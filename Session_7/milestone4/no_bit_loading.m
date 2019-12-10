function [qam_orders] = no_bit_loading(nfft, qam_order)

    qam_orders = qam_order .* ones(nfft,1);
    qam_orders(1) = 0; % DC
    qam_orders(nfft/2+1) = 0; % Nyquist frequency
end

