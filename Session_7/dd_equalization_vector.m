close all;
qam_symbol_length = 1000;
qam_dim = 4;
delta = [-0.25-.25i, 0.01+0.1i];
snr = 40;
mu = 0.1;
alpha = 0.0001;
%generate random bit sequence
bit_seq = randi([0 1],2,qam_dim*qam_symbol_length);

%qam sequence
qam_symbols(1,:) = qam_mod(bit_seq(1,:),qam_dim);
qam_symbols(2,:) = qam_mod(bit_seq(2,:),qam_dim);
%start value for Hk
H(1) = 0.5 + 0.25i;
H(2) = 0.6 -0.2i;
%adding noise

Y(1,:) = awgn(H(1).*qam_symbols(1,:),snr);
Y(2,:) = awgn(H(2).*qam_symbols(2,:),snr);
Wk = conj(H).^-1 + delta;

w_values = zeros(2, qam_symbol_length);
x_hat = zeros(2, qam_symbol_length);
x_tilde = zeros(2, qam_symbol_length);
w_values(:,1) = Wk.';
x_tilde(:,1) = Y(:,1).*Wk';
x_hat(:,1) = decision_device(x_tilde(:,1),qam_dim);
for L = 1:qam_symbol_length-1
    x_tilde(:,L+1) = Y(:,L+1).*conj(w_values(:,L));
   % x_hat(:,L+1)= decision_device(x_tilde(:,L+1),qam_dim);
   % w_values(:,L+1) = w_values(:,L)+ mu./(alpha + conj(Y(:,L+1)).*Y(:,L+1)).*Y(:,L+1).*conj(x_hat(:,L+1) - conj(w_values(:,L)).*Y(:,L+1));
   [w_values(:,L+1), x_hat(:,L+1)] = adaptive_filter_update(w_values(:,L),  Y(:,L+1), mu, alpha, qam_dim);
end
errors = abs(x_hat-x_tilde);
figure;
plot(errors(1,:));
hold on;
plot(errors(2,:));
hold off;
title('X hat - X tilde');
H_errors = conj(w_values)-(H.^-1).';
figure;
plot(mag2db(abs(H_errors(1,:))));
hold on;
plot(mag2db(abs(H_errors(2,:))));
hold off;
title('Wk-1/H');
ylabel('Error (dB)')