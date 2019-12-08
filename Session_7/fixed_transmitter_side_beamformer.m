function [speaker1_factor, speaker2_factor] = fixed_transmitter_side_beamformer(channel_1,channel_2, nfft)

    H1 = fft(channel_1, nfft);
    H2 = fft(channel_2, nfft);
    
    speaker1_factor = zeros(nfft, 1);
    speaker2_factor = zeros(nfft, 1);
    for bin=1:nfft
        speaker1_factor(bin) = conj(H1(bin))/sqrt(abs(H1(bin))^2 + abs(H2(bin))^2);
        speaker2_factor(bin) = conj(H2(bin))/sqrt(abs(H1(bin))^2 + abs(H2(bin))^2);
    end
    
    % Plot Transfer functions
    H1_2 = sqrt(abs(H1).^2 + abs(H2).^2);
    figure;
    hold on;plot((abs(H1))); plot((abs(H2))); plot((abs(H1_2))); hold off;
    title('H^1, H^2, H^{1+2}');
    legend('H^1', 'H^2', 'H^{1+2}');
    ylabel('magnitude')
    xlim([1 nfft])
end

