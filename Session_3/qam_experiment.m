seq_len = 8000;
N = 4;
seq = randi(2,1,seq_len) - 1;
mod_seq = qam_mod(seq, N);
mod_seq = awgn(mod_seq, 30);
scatterplot(mod_seq);

demod_seq = qam_demod(mod_seq, N);
ratio = ber(seq, demod_seq)