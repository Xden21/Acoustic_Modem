function  demod_sig = qam_demod(mod_sig,Nq)

   de_sig = qamdemod(mod_sig, 2^Nq, 'UnitAveragePower',true); 
   bi_matr = de2bi(de_sig,'left-msb');
   [a,b] = size(bi_matr);
   demod_sig = reshape(bi_matr', 1, a*b);
end

