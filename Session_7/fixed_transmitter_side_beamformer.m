function [speaker1_factor, speaker2_factor] = fixed_transmitter_side_beamformer(channel_1,channel_2, nfft)

    H1 = fft(channel_1, nfft);
    H2 = fft(channel_2, nfft);
    
    speaker1_factor = zeros(nfft, 1);
    speaker2_factor = zeros(nfft, 1);
    for bin=1:nfft
        speaker1_factor(bin) = conj(H1(bin))/sqrt(abs(H1(bin))^2 + abs(H2(bin))^2);
        speaker2_factor(bin) = conj(H2(bin))/sqrt(abs(H1(bin))^2 + abs(H2(bin))^2);
    end
end

