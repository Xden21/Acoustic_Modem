function [rxQamStream,channel_est] = ofdm_demod(mod_sig, nfft, prefix_length, trainblock,Lt,Ld)
    %Bookkeeping
    if mod(nfft,2) ~= 0
        error('fft size must be an even number')
    end
    elements_per_frame = nfft/2 -1; %Amount of elements of the modulated 
                                    %signal must be added to each frame
    
    
    %Step 1: parallelize the incoming signal.
    padding_length = mod(nfft+prefix_length - mod(length(mod_sig),nfft+prefix_length), nfft+prefix_length);
    mod_sig = [mod_sig;zeros(padding_length,1)];
    frame_count = length(mod_sig)/(nfft+prefix_length);   
    ofdm_td = reshape(mod_sig, nfft+prefix_length, frame_count);
    
    %Step 2: Calculate the transmitted ofdm packet.
    %Remove Cyclic prefix
    ofdm_td = ofdm_td(prefix_length+1:end,:);
    ofdm_packet = fft(ofdm_td, nfft); 
    
    %calculate transfer function and add to matrix
    full_train_block = [0,trainblock,0,fliplr(conj(trainblock))]; %extend with compl conj
    
    [cLen,rLen] = size(ofdm_packet);
    amount_of_train = ceil(rLen/(Lt+Ld));
    last_block_ld = mod(rLen,Lt+Ld)-Lt;
    channel_est = zeros(cLen,amount_of_train);
    rxQamStream = zeros(1,amount_of_train*Ld*elements_per_frame);
    for pack = 1:amount_of_train
        est_channel_freq = zeros(1,cLen);
        inv_channel_freq = zeros(1,cLen);
        for i = 1:cLen
            if full_train_block(i) ~= 0
                x_column = full_train_block(i)*ones(Lt,1);
                est_channel_freq(i) = (x_column\(ofdm_packet(i,(pack-1)*(Lt+Ld)+1:(pack-1)*(Lt+Ld)+Lt).'));
                inv_channel_freq(i) = 1/est_channel_freq(i);
            end
        end
        channel_est(:,pack) = est_channel_freq;

        %Step 3: Equalize

        H = diag(inv_channel_freq);

            %Equalize
            %ofdm_packet_eq = H * ofdm_packet;
         if pack == amount_of_train
             data_pack_eq = H * ofdm_packet(:,(pack-1)*(Lt+Ld)+1+Lt:(pack-1)*(Lt+Ld)+last_block_ld+Lt);         
         else
             data_pack_eq = H * ofdm_packet(:,(pack-1)*(Lt+Ld)+1+Lt:pack*(Lt+Ld));
         end

        %     else
        %         ofdm_packet_eq = ofdm_packet;
        %     end

            %Step 4: Unpack ofdm frames to QAM symbol stream

            % Basic Implementation


        if pack == amount_of_train
            %Make empty signal stream
            qam_sig_padded = zeros(1, last_block_ld*elements_per_frame);
            for frame_i=1:last_block_ld
                %Pull out original QAM signal values from each frame and add to
                %signal stream
                qam_sig_padded((frame_i-1)*elements_per_frame + 1:frame_i*elements_per_frame) = data_pack_eq(2:elements_per_frame+1, frame_i);
            end
            % Remove padding?
            rxQamStream((Ld*elements_per_frame)*(pack-1)+1:(Ld*elements_per_frame)*(pack-1) + elements_per_frame*last_block_ld) = qam_sig_padded;
        else
            qam_sig_padded = zeros(1, Ld*elements_per_frame);
            for frame_i=1:Ld
                %Pull out original QAM signal values from each frame and add to
                %signal stream
                qam_sig_padded((frame_i-1)*elements_per_frame + 1:frame_i*elements_per_frame) = data_pack_eq(2:elements_per_frame+1, frame_i);
            end

            % Remove padding?
            rxQamStream((Ld*elements_per_frame)*(pack-1)+1:(Ld*elements_per_frame)*pack) = qam_sig_padded;
        end
    end
end



