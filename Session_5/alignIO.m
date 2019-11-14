function [out_aligned] = alignIO(out,pulse)
    margin = 20;
    corr_seq = xcorr(out,pulse);
    max_corr=  max(corr_seq);
    ind = find(corr_seq==max_corr)-length(out)+length(pulse)+1-margin;
    out_aligned = out(ind:end);
end