function [sig,est_channel_freq] = ofdm_demod(mod_sig, nfft, prefix_length, trainblock)
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
    ofdm_packet = fft(ofdm_td, nfft); 
    
    %calculate transfer function
    full_train_block = [0,trainblock,0,fliplr(conj(trainblock))]; %extend with compl conj
    [cLen,rLen] = size(ofdm_packet);
    est_channel_freq = zeros(1,cLen);
    inv_channel_freq = zeros(1,cLen);
    for i = 2:2:cLen
        if full_train_block(i) ~= 0
            x_column = full_train_block(i)*ones(rLen,1);
            est_channel_freq(i) = (x_column\(ofdm_packet(i,:).'));
        end
    end
    
    % Interpolate frequency response
    time_domain_channel_resp = ifft(est_channel_freq, nfft);
    figure;
    plot(time_domain_channel_resp);
    window = ones(length(time_domain_channel_resp)/2, 1);
%    plot(window);
    time_domain_channel_resp_filt = [time_domain_channel_resp(1:end/2).*window.', zeros(1,length(time_domain_channel_resp)/2)];
    plot(time_domain_channel_resp);
    
    est_channel_freq = 2*fft(time_domain_channel_resp_filt, nfft);
    est_channel_freq(1) = 0;
    est_channel_freq(nfft/2+1) = 0;
  %  est_channel_freq(1:2:end) = new_est_channel_freq(1:2:end);
    for i = 1:cLen
        if est_channel_freq(i) ~= 0
            inv_channel_freq(i) = 1.0/est_channel_freq(i);
        end
    end
    
    %Step 3: Equalize
    
    
    H = diag(inv_channel_freq);

    %Equalize
    ofdm_packet_eq = H * ofdm_packet;
    
    %Step 4: Unpack ofdm frames to QAM symbol stream
    
    % Basic Implementation
    
    %Make empty signal stream
    qam_sig_padded = zeros(1, frame_count*elements_per_frame);
    
    for frame_i=1:frame_count
        %Pull out original QAM signal values from each frame and add to
        %signal stream
        qam_sig_padded((frame_i-1)*elements_per_frame + 1:frame_i*elements_per_frame) = ofdm_packet_eq(2:elements_per_frame+1, frame_i);
    end
    
    % Remove padding?
    sig = qam_sig_padded;
end

