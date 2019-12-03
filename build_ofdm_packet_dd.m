function [ofdm_packet, trainframe, data_windows] = build_ofdm_packet_dd(bitstream,qam_orders, trainbits, Lt)
    % Amount of frequency bins
    nfft = length(qam_orders);
    
    % Amount of bits of the datastream is packed within each frame
    frame_bits = 0;
    for i=1:(nfft/2) % Not -1 since we include the DC frequency (which should be zero anyways)
        frame_bits = frame_bits + qam_orders(i);
    end
    
    % Amount of padding to get a multiple of frame_bits
    pad_count = mod(frame_bits - mod(length(bitstream), frame_bits), frame_bits);
    
    % Add padding to datastream
    bitstream_padded = [bitstream; zeros(pad_count,1)];
    
    % Calculate the amount of frames (=amount of values for each bin)
    frame_count = length(bitstream_padded)/frame_bits;
    
    % Calculate the total amount of bits per bin
     bits_per_bin = qam_orders.*frame_count;
    
    % Build ofdm packet row per row
    ofdm_data_packet = zeros(nfft, frame_count);
    
    
    for bin=1:nfft/2
        if qam_orders(bin) ~= 0
            bits = zeros(1, bits_per_bin(bin));
            if bin ~= 1
                bit_offset = sum(qam_orders(1:bin-1));
            else
                bit_offset = 0;
            end

            for frame=1:frame_count
                    bits(((frame-1) * qam_orders(bin)) + 1: frame * qam_orders(bin)) = ...
                        bitstream_padded((bit_offset) + (frame - 1) * frame_bits + 1 : (bit_offset) + (frame - 1) * frame_bits + qam_orders(bin));
            end
            qam_symb = qam_mod(bits, qam_orders(bin));
            ofdm_data_packet(bin, :) = qam_symb;
            ofdm_data_packet(nfft-bin+2,:) = conj(qam_symb);
        end
    end
    
    trainframe = zeros(nfft,1);
    for bin=1:nfft/2
        if qam_orders(bin) ~= 0
            bits = zeros(1, qam_orders(bin));
            if bin ~= 1
                bit_offset = sum(qam_orders(1:bin-1));
            else
                bit_offset = 0;
            end
            bits = trainbits((bit_offset+1) : (bit_offset) + qam_orders(bin));

            qam_symb = qam_mod(bits, qam_orders(bin));
            trainframe(bin, :) = qam_symb;
            trainframe(nfft-bin+2,:) = conj(qam_symb);
        end
    end
    
    data_windows = ceil(frame_count/Ld);
    ofdm_packet = zeros(nfft, frame_count + Lt*data_windows);
    
    frames_to_send = mod(frame_count, Ld);
    for pack=1:data_windows
        if(pack==data_windows && frames_to_send ~= 0)
            ofdm_packet(:,(Ld+Lt)*(pack - 1)+1: (Ld+Lt)*(pack - 1)+(frames_to_send+Lt)) = [repmat(trainframe,1,Lt), ofdm_data_packet(:,(Ld)*(pack - 1)+1:(Ld)*(pack - 1)+(frames_to_send))];
        else
            ofdm_packet(:,(Ld+Lt)*(pack - 1)+1: (Ld+Lt)*pack) = [repmat(trainframe,1,Lt), ofdm_data_packet(:,(Ld)*(pack - 1)+1: (Ld)*pack)];
        end
    end
end

