function ratio =  qam_experiment(qam_order,seq,snr)


mod_seq = qam_mod(seq, qam_order);
mod_seq = awgn(mod_seq, snr);
%scatterplot(mod_seq);

demod_seq = qam_demod(mod_seq, qam_order);
ratio = ber(seq, demod_seq);
end