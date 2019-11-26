function [sig,channel_est] = ofdm_demod_bl(mod_sig,  qam_orders, prefix_length, pilot_sims)
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
    
    frame_bits = 0;
    for i=1:2:(nfft/2) % Not -1 since we include the DC frequency (which should be zero anyways) only count actual data bins
        frame_bits = frame_bits + qam_orders(i);
    end
    
    %calculate transfer function
    full_pilot_block = [pilot_sims,fliplr(conj(pilot_sims))]; %extend with compl conj
    [cLen,rLen] = size(ofdm_packet);    
    channel_est = zeros(cLen,frame_count);
    sig = zeros(1, frame_count*frame_bits);
    for frame=1:frame_count
        est_channel_freq = zeros(1,cLen);
        inv_channel_freq = zeros(1,cLen);
        for i = 2:2:cLen
            if full_pilot_block(i/2) ~= 0
                est_channel_freq(i) = ofdm_packet(i,frame)/full_pilot_block(i/2);
            end
        end

        % Interpolate frequency response
        time_domain_channel_resp = ifft(est_channel_freq, nfft);
        %figure;
        %plot(time_domain_channel_resp);
        window = ones(length(time_domain_channel_resp)/2, 1);
    %    plot(window);
        time_domain_channel_resp_filt = [time_domain_channel_resp(1:end/2).*window.', zeros(1,length(time_domain_channel_resp)/2)];
        %plot(time_domain_channel_resp);

        est_channel_freq = 2*fft(time_domain_channel_resp_filt, nfft);
        est_channel_freq(1) = 0;
        est_channel_freq(nfft/2+1) = 0;
        channel_est(:,frame) = est_channel_freq;
        
        for i = 1:cLen
            if est_channel_freq(i) ~= 0
                inv_channel_freq(i) = 1.0/est_channel_freq(i);
            end
        end

        %Step 3: Equalize


        H = diag(inv_channel_freq);

        %Equalize
        ofdm_packet_eq = H * ofdm_packet(:,frame);
        %Step 4: Unpack ofdm frames to QAM symbol stream

        % Use of unpack_ofdm_packet to support bit loading
        sig((frame-1)*frame_bits+1: frame*frame_bits) = unpack_ofdm_packet_pilot(ofdm_packet_eq, qam_orders);
    end
end