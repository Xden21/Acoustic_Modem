seq_len = 8000;
N = 4;
nfft = 64;
seq = randi([0,1],1,seq_len);
mod_seq = ofdm_mod(seq, N, nfft, 10);
%mod_seq = awgn(mod_seq, 30);

demod_seq = ofdm_demod(mod_seq, N, nfft,10);
ratio = ber(seq, demod_seq)