function [mod_sig_speaker1, mod_sig_speaker2 ,trainblock, amount_of_packs] = ofdm_mod_stereo(sig, qam_orders, prefix_length, trainblock, Lt, Ld, speaker1_factors, speaker2_factors)
     %Bookkeeping
    if mod(length(qam_orders),2) ~= 0
        error('fft size must be an even number')
    end     
        
    % Use of build_ofdm_packet to support bit loading
      
    [ofdm_packet, trainblock, amount_of_packs] =  build_ofdm_packet(sig, qam_orders, trainblock, Lt, Ld);

    ofdm_packet_speaker1 = speaker1_factors .* ofdm_packet; % multiplies each bin in each frame with the correct factor, factors must be column vector
    ofdm_packet_speaker2 = speaker2_factors .* ofdm_packet;

    
    %Step 3: calculate time domain values and serialize
    ofdm_td1 = ifft(ofdm_packet_speaker1);
    ofdm_td2 = ifft(ofdm_packet_speaker2);

    %Add cyclic prefix.
    ofdm_td1 = [ofdm_td1(end-prefix_length+1:end,:);ofdm_td1];
    ofdm_td2 = [ofdm_td2(end-prefix_length+1:end,:);ofdm_td2];
    
    mod_sig_speaker1 = ofdm_td1(:);
    mod_sig_speaker2 = ofdm_td2(:);

    %Time domain ofdm signal is now in mod_sig

end

