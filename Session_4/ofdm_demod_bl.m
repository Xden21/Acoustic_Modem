function [rxBitStream,channel_est] = ofdm_demod_bl(mod_sig,  qam_orders, prefix_length, trainframe,Lt,Ld)
    %Bookkeeping
    nfft = length(qam_orders);
    
    if mod(nfft,2) ~= 0
        error('fft size must be an even number')
    end
    
    %Step 1: parallelize the incoming signal.
    padding_length = mod(nfft+prefix_length - mod(length(mod_sig),nfft+prefix_length), nfft+prefix_length);
    mod_sig = [mod_sig;zeros(padding_length,1)];
    frame_count = length(mod_sig)/(nfft+prefix_length);
    
    ofdm_td = reshape(mod_sig, nfft+prefix_length, frame_count);
    
    %Step 2: Calculate the transmitted ofdm packet.
    %Remove Cyclic prefix
    ofdm_td = ofdm_td(prefix_length+1:end,:);
    
    ofdm_packet = fft(ofdm_td, nfft);
    
    %calculate transfer function
    %full_train_block = [0,trainblock.',0,fliplr(conj(trainblock.'))]; %extend with compl conj
    [cLen,rLen] = size(ofdm_packet);
    amount_of_train = ceil(rLen/(Lt+Ld));
    last_block_ld = max(mod(rLen,Lt+Ld)-Lt,0);
    channel_est = zeros(cLen,amount_of_train);
    rxBitStream = [];
    for pack = 1:amount_of_train
        est_channel_freq = zeros(1,cLen);
        inv_channel_freq = zeros(1,cLen);
        for i = 1:cLen
            if trainframe(i) ~= 0
                x_column = trainframe(i)*ones(Lt,1);
                est_channel_freq(i) = (x_column\(ofdm_packet(i,(pack-1)*(Lt+Ld)+1:(pack-1)*(Lt+Ld)+Lt).'));
                inv_channel_freq(i) = 1/est_channel_freq(i);
            end
        end
        channel_est(:,pack) = est_channel_freq;

        %Step 3: Equalize



        H = diag(inv_channel_freq);

        %Equalize
        if (pack == amount_of_train) && (last_block_ld~=0)
            data_pack_eq = H * ofdm_packet(:,(pack-1)*(Lt+Ld)+1+Lt:(pack-1)*(Lt+Ld)+last_block_ld+Lt);         
        else
            data_pack_eq = H * ofdm_packet(:,(pack-1)*(Lt+Ld)+1+Lt:pack*(Lt+Ld));
        end
        %Step 4: Unpack ofdm frames to QAM symbol stream

        % Use of unpack_ofdm_packet to support bit loading
        rxBitStream =[rxBitStream unpack_ofdm_packet(data_pack_eq, qam_orders).'];
    end
end