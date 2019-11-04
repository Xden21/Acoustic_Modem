% Parameters
seq_len = 10000;
qam_dim = 6;
nfft = 104;
prefix_length = 5;

% sequence generation
seq = randi([0,1],1,seq_len);

qam_orders = qam_dim .* ones(nfft,1);
qam_orders(1) = 0; % DC
qam_orders(nfft/2+1) = 0; % complex conj DC

mod_seq = ofdm_mod_bl(seq', qam_orders, prefix_length);


% Ofmd demodulation
demod_seq = ofdm_demod_bl(mod_seq, qam_orders,prefix_length);


% BER
ber(seq, demod_seq')