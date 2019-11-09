% Parameters
seq_len = 10000;
qam_dim = 4;
nfft = 10;
prefix_length = 10;

% sequence generation
seq = randi([0,1],1,seq_len);

qams = 1:6;
snrs = 0:0.1:25;
results = zeros(length(qams), length(snrs));

for qam = 1:6
    for snr = 1:length(snrs)
        %Calculate qam-N modulated signal
        qam_sig = qam_mod(seq, qam);

        % Calcultate ofdm_modulated signal
        mod_seq = ofdm_mod(qam_sig, nfft, prefix_length);

        % Add noise
        mod_seq = awgn(mod_seq, snrs(snr));


        % Ofmd demodulation
        demod_seq = ofdm_demod(mod_seq, nfft,prefix_length);

        rec_seq = qam_demod(demod_seq, qam);

        % BER
        results(qam,snr) = ber(seq, rec_seq);
    end
end

semilogy(snrs,results');
title('OFDM')
ylim([10^(-4),1]);
xlabel('SNR [dB]')
ylabel('BER (log)')
legend('QAM-2','QAM-4','QAM-8','QAM-16','QAM-32','QAM-64');