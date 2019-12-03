close all;
qam_symbol_length = 1000;
qam_dim = 4;
delta = -0.25-.25i;
snr = 30;
mu = .3;
alpha = 5;
%generate random bit sequence
bit_seq = randi([0 1],1,qam_dim*qam_symbol_length);

%qam sequence
qam_symbols = qam_mod(bit_seq,qam_dim);

%start value for Hk
Hk = 0.5 + 0.25i;

%adding noise
Y = awgn(Hk.*qam_symbols,snr);
Wk = 1/(Hk') + delta;

w_values = zeros(1, qam_symbol_length);
x_hat = zeros(1, qam_symbol_length);
x_tilde = zeros(1, qam_symbol_length);
w_values(1) = Wk;
x_tilde(1) = Y(1)*Wk';
x_hat(1) = decision_device(x_tilde(1),qam_dim);
for L = 1:qam_symbol_length-1
    x_tilde(L+1) = Y(L+1)*w_values(L)';
    x_hat(L+1)= decision_device(x_tilde(L+1),qam_dim);
    w_values(L+1) = w_values(L)+ mu/(alpha + Y(L+1)'*Y(L+1))*Y(L+1)*conj(x_hat(L+1) - w_values(L)'*Y(L+1));
end
errors = abs(x_hat-x_tilde);
figure;
plot(errors);
title('X hat - X tilde');
H_errors = conj(w_values)-1/Hk;
figure;
plot(mag2db(abs(H_errors)));
title('Wk-1/H');
ylabel('Error (dB)')