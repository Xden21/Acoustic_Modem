%filters the signal wiht bandstop filter with lower bound Lb and higher
%bound Hb
function filteredSig = band_stop_filter(sig,Lb,Hb,fs)
bhi = fir1(40,[Lb/fs*2,Hb/fs*2],'STOP');
filteredSig = filter(bhi,1,sig);
end