function  demod_sig = qam_demod(mod_sig,Nq)
   de_sig = qamdemod(mod_sig, 2^Nq); 
   bi_matr = de2bi(de_sig');
   [a,b] = size(bi_matr);
   demod_sig = reshape(bi_matr', 1, a*b);
end

