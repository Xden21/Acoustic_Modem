function mod_sig = ofdm_mod(sig, nfft, prefix_length)
    %Bookkeeping
    if mod(nfft,2) ~= 0
        error('fft size must be an even number')
    end
    
    % Basic implementation
    elements_per_frame = nfft/2 -1; %Amount of elements of the modulated 
                                    %signal must be added to each frame
    
    %Step 1: Pad data to fit in the frames
    padcount = mod(elements_per_frame - mod(length(sig), elements_per_frame),elements_per_frame);
    sig_padded = [sig, zeros(1,padcount)];
    
    %Step 2: Serial to parallel shift
    frame_count = length(sig_padded)/elements_per_frame;
    
    %Generate empty packet
    ofdm_packet = zeros(nfft, frame_count);
    
    % Fill packet with data
    for frame_i=1:frame_count
        % Add QAM symbols
        ofdm_packet(2:elements_per_frame+1, frame_i) = sig_padded((frame_i-1)*elements_per_frame+1:frame_i*elements_per_frame);
         %Add complex conjugate of QAM singals in reverse order
        ofdm_packet(elements_per_frame+3:end, frame_i) = fliplr(conj(sig_padded((frame_i-1)*elements_per_frame+1:frame_i*elements_per_frame)));
    end
        
   
    %Step 3: calculate time domain values and serialize
    ofdm_td = ifft(ofdm_packet);
    
    %Add cyclic prefix.
    ofdm_td = [ofdm_td(end-prefix_length+1:end,:);ofdm_td];
    
    mod_sig = ofdm_td(:);
    
    %Time domain ofdm signal is now in mod_sig
end

