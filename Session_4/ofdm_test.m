% Parameters
seq_len = 10000;
qam_dim = 4;
nfft = 20;
prefix_length = 6;
channel_order = 5;

% sequence generation
seq = randi([0,1],1,seq_len);

% Basic
% qam_orders = qam_dim .* ones(nfft,1);
% qam_orders(1) = 0; % DC
% qam_orders(nfft/2+1) = 0; % Nyquist frequency

% On Off Bit loading
channel_model = randn(1,channel_order);
channel_freq_response = fft(channel_model, nfft);
qam_orders = on_off_bit_loading(channel_freq_response, qam_dim, 0.3);

mod_seq = ofdm_mod_bl(seq', qam_orders, prefix_length);


% Ofmd demodulation
demod_seq = ofdm_demod_bl(mod_seq, qam_orders,prefix_length);


% BER
ber(seq, demod_seq')