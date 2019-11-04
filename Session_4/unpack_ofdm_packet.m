function bitstream = unpack_ofdm_packet(ofdm_packet,qam_orders)
    [nfft, frame_count] = size(ofdm_packet);
    
    % Calculate the total amount of bits per bin
    bits_per_bin = qam_orders.*frame_count;
    
    % Calculate total amount of bits in bitstream
    total_bits = 0;    
    for i=1:(nfft/2)
        total_bits = total_bits + bits_per_bin(i);
    end
    
    % Unpack and demodulate ofdm_packet to bitstream
    bitstream = zeros(total_bits,1);
    
    last_index = 0;
    for i=1:(nfft/2)
        if qam_orders(i) ~= 0
            bitstream(last_index+1:last_index+bits_per_bin(i)) = qam_demod(ofdm_packet(i,:), qam_orders(i));
            last_index = last_index + bits_per_bin(i);
        end
    end
end

