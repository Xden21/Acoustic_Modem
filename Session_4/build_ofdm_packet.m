function ofdm_packet = build_ofdm_packet(bitstream,qam_orders)
    % Amount of frequency bins
    nfft = length(qam_orders);
    
    % Amount of bits of the datastream is packed within each frame
    frame_bits = 0;
    for i=1:(nfft/2) % Not -1 since we include the DC frequency (which should be zero anyways)
        frame_bits = frame_bits + qam_orders(i);
    end
    
    % Amount of padding to get a multiple of frame_bits
    pad_count = frame_bits - mod(length(bitstream), frame_bits);
    
    % Add padding to datastream
    bitstream_padded = [bitstream; zeros(pad_count,1)];
    
    % Calculate the amount of frames (=amount of values for each bin)
    frame_count = length(bitstream_padded)/frame_bits;
    
    % Calculate the total amount of bits per bin
    bits_per_bin = qam_orders.*frame_count;
    
    % Build ofdm packet row per row
    ofdm_packet = zeros(nfft, frame_count);
    
    last_index = 0;
    for i=1:(nfft/2)
        if qam_orders(i) ~= 0
            qam_symb = qam_mod(bitstream_padded(last_index+1:last_index + bits_per_bin(i)), qam_orders(i));
            ofdm_packet(i,:) = qam_symb;
            ofdm_packet(nfft-i+2,:) = conj(qam_symb);            
            last_index = last_index + bits_per_bin(i);
        end
    end
end

