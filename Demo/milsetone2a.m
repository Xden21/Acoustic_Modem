%initiate a random sequence of bits
seq_len = 10000;
seq = randi([0,1],1,seq_len);
max_snr = 26;
snrs = 0:0.2:max_snr;
ratios = zeros(1,length(snrs));
for order = 1:6             %for 6 orders
    for snr = 1:length(snrs)     %plot in function of snr
        ratios(snr)= qam_experiment(order,seq,snrs(snr));
    end 
    semilogy(snrs,ratios);  
    hold on; %plot each iteration
end
title('QAM')
ylim([10^(-4),1]);
xlim([0,max_snr]);
xlabel('SNR [dB]')
ylabel('BER (log)')
legend('QAM-2','QAM-4','QAM-8','QAM-16','QAM-32','QAM-64');
hold off;