function ratio = ber(inputSig,outputSig)
    outputSig = outputSig(1:length(inputSig));
    
    [~, ratio] = biterr(inputSig, outputSig);
end

