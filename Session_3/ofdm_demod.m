function sig = ofdm_demod(mod_sig, nfft, prefix_length, channel_response)
    %Bookkeeping
    if mod(nfft,2) ~= 0
        error('fft size must be an even number')
    end
    elements_per_frame = nfft/2 -1; %Amount of elements of the modulated 
                                    %signal must be added to each frame
    
    
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
    
    % Basic Implementation
    
    %Make empty signal stream
    qam_sig_padded = zeros(1, nfft*elements_per_frame);
    
    for frame_i=1:frame_count
        %Pull out original QAM signal values from each frame and add to
        %signal stream
        qam_sig_padded((frame_i-1)*elements_per_frame + 1:frame_i*elements_per_frame) = ofdm_packet_eq(2:elements_per_frame+1, frame_i);
    end
    
    % Remove padding?
    sig = qam_sig_padded;

end

