pulse = [1 0 0 1 0 0 1 0 0 0 1]
rand_seq = randn(1,50);
out = [0.01*randn(1,5),pulse,rand_seq/max(abs(rand_seq))];
out_aligned = alignIO(out,pulse)-length(out)+1+length(pulse);
length(out_aligned)