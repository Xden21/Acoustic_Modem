function bitstream = unpack_ofdm_packet_pilot(ofdm_packet,qam_orders)
    [nfft, frame_count] = size(ofdm_packet);
    
    % Calculate the total amount of bits per bin
    bits_per_bin = qam_orders.*frame_count;
    
    % Amount of bits of the datastream is packed within each frame
    frame_bits = 0;
    for i=1:2:(nfft/2) % Not -1 since we include the DC frequency (which should be zero anyways) only count actual data bins
        frame_bits = frame_bits + qam_orders(i);
    end
    
    % Calculate total amount of bits in bitstream
    total_bits = 0;    
    for i=1:2:(nfft/2)
        total_bits = total_bits + bits_per_bin(i);
    end
    
    % Unpack and demodulate ofdm_packet to bitstream
    bitstream = zeros(total_bits,1);
    
    for bin = 1:2:nfft/2
        if qam_orders(bin) ~= 0
            if bin ~= 1
                bit_offset = sum(qam_orders(1:2:bin-1));
            else
                bit_offset = 0;
            end

            demod_sig = qam_demod(ofdm_packet(bin, :), qam_orders(bin));

            for frame=1:frame_count
                bitstream((bit_offset) + (frame - 1) * frame_bits + 1 : (bit_offset) + (frame - 1) * frame_bits + qam_orders(bin)) = ...
                        demod_sig(((frame-1) * qam_orders(bin)) + 1: frame * qam_orders(bin));

            end
        end
    end
end

