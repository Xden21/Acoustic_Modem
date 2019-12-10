function [rxBitStream,est_channel_freq] = ofdm_demod_est(mod_sig,  qam_orders, prefix_length, trainblock)
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
    full_train_block = [0,trainblock,0,fliplr(conj(trainblock))]; %extend with compl conj
    [cLen,rLen] = size(ofdm_packet);
    est_channel_freq = zeros(1,cLen);
    inv_channel_freq = zeros(1,cLen);
    for i = 1:cLen
        if full_train_block(i) ~= 0
            x_column = full_train_block(i)*ones(rLen,1);
            est_channel_freq(i) = (x_column\(ofdm_packet(i,:).'));
            inv_channel_freq(i) = 1/est_channel_freq(i);
        end
    end

    %Step 3: Equalize



    H = diag(inv_channel_freq);

    %Equalize
    data_pack_eq = H * ofdm_packet;         
    %Step 4: Unpack ofdm frames to QAM symbol stream

    % Use of unpack_ofdm_packet to support bit loading
    rxBitStream = unpack_ofdm_packet(data_pack_eq, qam_orders);
    
end