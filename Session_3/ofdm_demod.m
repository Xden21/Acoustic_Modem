function sig = ofdm_demod(mod_sig, qam_dim, nfft, prefix_length)
    %Bookkeeping
    if mod(nfft,2) ~= 0
        error('fft size must be an even number')
    end
    elements_per_frame = nfft/2 -1; %Amount of elements of the modulated 
                                    %signal must be added to each frame
    
    if qam_dim < 2 || qam_dim > 6
        error('qam_dim must be an integer between 2 and 6 (incl)')
    end
    
    %Step 1: parallelize the incoming signal.
    frame_count = length(mod_sig)/(nfft+prefix_length);
    
    ofdm_td = reshape(mod_sig, nfft+prefix_length, frame_count);
    
    %Step 2: Calculate the transmitted ofdm packet.
    %Remove Cyclic prefix
    ofdm_td = ofdm_td(prefix_length+1:end,:);
    
    ofdm_packet = fft(ofdm_td);
    
    %Step 3: Unpack ofdm frames to QAM symbol stream
    
    %Make empty signal stream
    qam_sig_padded = zeros(1, nfft*elements_per_frame);
    
    for frame_i=1:frame_count
        %Pull out original QAM signal values from each frame and add to
        %signal stream
        qam_sig_padded((frame_i-1)*elements_per_frame + 1:frame_i*elements_per_frame) = ofdm_packet(2:elements_per_frame+1, frame_i);
    end
    
    %Step 4:Unpad and demodulate QAM signal to get orignal signal sequence

    %TODO remove padding? => With noise present, could be difficult if
    %there is no knowledgde about desired signal length.
    sig = qam_demod(qam_sig_padded, qam_dim);    
end

