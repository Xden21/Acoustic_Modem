function [sig,channel_est] = ofdm_demod_bl_dd(mod_sig,  qam_orders, prefix_length, trainframe, Lt, mu, alpha)
    %Bookkeeping
    nfft = length(qam_orders);
    
    if mod(nfft,2) ~= 0
        error('fft size must be an even number')
    end
    
    %Step 1: parallelize the incoming signal.
    padding_length = mod(nfft+prefix_length - mod(length(mod_sig),nfft+prefix_length), nfft+prefix_length);
    mod_sig = [mod_sig;zeros(padding_length,1)];
    frame_count = length(mod_sig)/(nfft+prefix_length);
    data_frame_count = frame_count - Lt;
    
    ofdm_td = reshape(mod_sig, nfft+prefix_length, frame_count);
    
    %Step 2: Calculate the transmitted ofdm packet.
    %Remove Cyclic prefix
    ofdm_td = ofdm_td(prefix_length+1:end,:);
    
    ofdm_packet = fft(ofdm_td, nfft);
    
    frame_bits = 0;
    for i=1:2:(nfft/2) % Not -1 since we include the DC frequency (which should be zero anyways) only count actual data bins
        frame_bits = frame_bits + qam_orders(i);
    end
    
    % Pull out training frames and make first estimate
     %calculate transfer function
    est_channel_freq = zeros(nfft,1);
    inv_channel_freq = zeros(nfft,1);
    for i = 1:nfft
        if trainframe(i) ~= 0
            x_column = trainframe(i)*ones(Lt,1);
            est_channel_freq(i) = (x_column\(ofdm_packet(i,1:Lt).')); %Only estimate the first Lt frames
            inv_channel_freq(i) = 1/est_channel_freq(i);
        end
    end
    
    % Initialize variables
    channel_est = zeros(nfft, data_frame_count);
    channel_est(:,1) = est_channel_freq;
    adaptive_filter_weights = zeros(nfft, data_frame_count);
    adaptive_filter_weights(:,1) = conj(inv_channel_freq);
    ofdm_data_packet_eq = zeros(nfft, data_frame_count);
    x_tilde = ofdm_packet(:,Lt+1).*inv_channel_freq;
    ofdm_data_packet_eq(:,1) = decision_device(x_tilde,qam_orders).';
    for packet = 1:(data_frame_count - 1)
        [adaptive_filter_weights(:,packet+1), ofdm_data_packet_eq(:,packet+1)] = adaptive_filter_update(adaptive_filter_weights(:,packet),  ofdm_packet(:,Lt+packet+1), mu, alpha, qam_orders);
        for i = 1:nfft
            if(adaptive_filter_weights(i, packet+1) ~= 0)
                channel_est(i, packet+1) = 1/conj(adaptive_filter_weights(1,packet+1));
            end
        end
    end
    
    sig = unpack_ofdm_packet(ofdm_data_packet_eq, qam_orders);
end