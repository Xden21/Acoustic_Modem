function sig = ofdm_demod_bl(mod_sig,  qam_orders, prefix_length, channel_response)
    %Bookkeeping
    nfft = length(qam_orders);
    
    if mod(nfft,2) ~= 0
        error('fft size must be an even number')
    end
    
    %Step 1: parallelize the incoming signal.
    frame_count = length(mod_sig)/(nfft+prefix_length);
    
    ofdm_td = reshape(mod_sig, nfft+prefix_length, frame_count);
    
    %Step 2: Calculate the transmitted ofdm packet.
    %Remove Cyclic prefix
    ofdm_td = ofdm_td(prefix_length+1:end,:);
    
    ofdm_packet = fft(ofdm_td);
    
    %Step 3: Equalize
    
     if nargin == 4
        %Invert channel_response
        channel_response = channel_response.^(-1);
        H = diag(channel_response);

        %Equalize
        ofdm_packet_eq = H * ofdm_packet;
    else
        ofdm_packet_eq = ofdm_packet;
    end
    
    %Step 4: Unpack ofdm frames to QAM symbol stream
    
    % Use of unpack_ofdm_packet to support bit loading
    sig = unpack_ofdm_packet(ofdm_packet_eq, qam_orders);
end