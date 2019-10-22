function mod_sig = qam_mod(sig,Nq)
    if rem(length(sig),Nq) ~= 0
        sig = [sig, zeros(1,Nq - rem(length(sig), Nq))];
    end
    data_in = reshape(sig,length(sig)/Nq,Nq);
    data_in_de = bi2de(data_in);
    mod_sig = qammod(data_in_de, 2^Nq);
    modnorm(mod_sig,'peakpow',1)
    mod_sig = mod_sig.*modnorm(mod_sig,'peakpow',1);
end

