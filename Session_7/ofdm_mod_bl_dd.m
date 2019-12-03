function [mod_sig ,trainblock]= ofdm_mod_bl_dd(sig, qam_orders, prefix_length, trainblock, Lt)
    %Bookkeeping
    if mod(length(qam_orders),2) ~= 0
        error('fft size must be an even number')
    end     
        
    % Use of build_ofdm_packet to support bit loading, this version adds Lt
    % training frames in front of data frames
      
    [ofdm_packet, trainblock] =  build_ofdm_packet_dd(sig, qam_orders, trainblock, Lt);

    %Step 3: calculate time domain values and serialize
    ofdm_td = ifft(ofdm_packet);
    
    %Add cyclic prefix.
    ofdm_td = [ofdm_td(end-prefix_length+1:end,:);ofdm_td];
    
    mod_sig = ofdm_td(:);
    
    %Time domain ofdm signal is now in mod_sig
end

