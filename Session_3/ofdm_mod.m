function mod_sig = ofdm_mod(sig,trainblock, nfft, prefix_length,Lt,Ld)
    %Bookkeeping
    if mod(nfft,2) ~= 0
        error('fft size must be an even number')
    end
    
    
    % Basic implementation
    elements_per_frame = nfft/2-1; %Amount of elements of the modulated 
                                    %signal must be added to each frame
    
                                 
    %Step 1: Pad data to fit in the frames
    padcount = mod(elements_per_frame - mod(length(sig), elements_per_frame),elements_per_frame);
    sig_padded = [sig, zeros(1,padcount)];
    
   %we can devide it in frames according to Lt and Ld
    data_windows = ceil(length(sig_padded)/elements_per_frame/Ld); %amount of times we send a pack of dataframes
    frames_to_send = length(sig_padded)/elements_per_frame; %resting amount of frames
    data_with_tr = zeros(1,elements_per_frame*(frames_to_send+data_windows*Lt));
    
    for i = 1:data_windows
        if frames_to_send < Ld  %last data_window doesnt contain Ld frames
            data_with_tr((Ld+Lt)*elements_per_frame*(i-1)+1:(Ld+Lt)*elements_per_frame*(i-1)+elements_per_frame*frames_to_send + Lt*elements_per_frame) = [repmat(trainblock,1,Lt),sig_padded((i-1)*(Ld*elements_per_frame)+1:(i-1)*Ld*elements_per_frame+elements_per_frame*frames_to_send)];
        else
            data_with_tr((Ld+Lt)*elements_per_frame*(i-1)+1:(Ld+Lt)*elements_per_frame*i) = [repmat(trainblock,1,Lt),sig_padded((i-1)*(Ld*elements_per_frame)+1:i*Ld*elements_per_frame)];
            frames_to_send = frames_to_send - Ld;
        end
    end
    
    
    %Step 2: Serial to parallel shift
    frame_count = length(data_with_tr)/elements_per_frame;
    
    %Generate empty packet
    ofdm_packet = zeros(nfft, frame_count);
    
    % Fill packet with data
    for frame_i=1:frame_count
        % Add QAM symbols
        ofdm_packet(2:elements_per_frame+1, frame_i) = data_with_tr((frame_i-1)*elements_per_frame+1:frame_i*elements_per_frame);
         %Add complex conjugate of QAM singals in reverse order
        ofdm_packet(elements_per_frame+3:end, frame_i) = fliplr(conj(data_with_tr((frame_i-1)*elements_per_frame+1:frame_i*elements_per_frame)));
    end
        
   
    %Step 3: calculate time domain values and serialize
    ofdm_td = ifft(ofdm_packet, nfft);
    
    %Add cyclic prefix.
    ofdm_td = [ofdm_td(end-prefix_length+1:end,:);ofdm_td];
    
    mod_sig = ofdm_td(:);
    
    %Time domain ofdm signal is now in mod_sig
end

