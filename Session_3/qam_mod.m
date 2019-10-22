function mod_sig = qam_mod(sig,Nq)
    if rem(length(sig),Nq) ~= 0
        sig = [sig, zeros(1,Nq - rem(length(sig), Nq))];
    end
    data_in = reshape(sig,Nq,length(sig)/Nq)';
    data_in_de = bi2de(data_in, 'left-msb');
    mod_sig = qammod(data_in_de, 2^Nq, 'UnitAveragePower',true);
end

