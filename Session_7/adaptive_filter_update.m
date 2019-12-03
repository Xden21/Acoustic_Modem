function [W_next, x_hat] = adaptive_filter_update(W_prev, input, mu, alpha, qam_orders)

    x_tilde = input.*conj(W_prev);
    x_hat= decision_device(x_tilde,qam_orders).';
    W_next = W_prev + mu./(alpha + conj(input).*input).*input.*conj(x_hat - conj(W_prev).*input);
end

