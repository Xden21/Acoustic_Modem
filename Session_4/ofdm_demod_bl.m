function [sig,est_channel_freq] = ofdm_demod_bl(mod_sig,  qam_orders, prefix_length, trainblock)
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
    
    
%     
%     if nargin == 4
        %Invert channel_response
%         channel_response = est_channel_freq.^(-1);

        H = diag(inv_channel_freq);

        %Equalize
        ofdm_packet_eq = H * ofdm_packet;
%     else
%         ofdm_packet_eq = ofdm_packet;
%     end
    %Step 4: Unpack ofdm frames to QAM symbol stream
    
    % Use of unpack_ofdm_packet to support bit loading
    sig = unpack_ofdm_packet(ofdm_packet_eq, qam_orders);
end