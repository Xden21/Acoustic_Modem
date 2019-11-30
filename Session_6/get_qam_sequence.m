function qam_stream = get_qam_sequence(ofdm_packet)
    [nfft, frame_count] = size(ofdm_packet);
    % Unpack and demodulate ofdm_packet to bitstream
    qam_stream = zeros(1,frame_count*(nfft/2-1));
    for frame = 1:frame_count
        qam_stream(1+(frame-1)*(nfft/2-1):(frame*(nfft/2-1))) = ofdm_packet(2:nfft/2,frame);
    end
end


