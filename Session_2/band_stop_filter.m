%filters the signal wiht bandstop filter with lower bound Lb and higher
%bound Hb
function filteredSig = band_stop_filter(sig,Lb,Hb,fs)
bhi = fir1(40,[Lb/fs*2,Hb/fs*2],'stop');
filteredSig = filter(bhi,1,sig);
%fvtool(bhi,1,'Fs',fs)
end