%sampling frequency determines the bandwidth. (user defined)
channel_order = 50;
nfft = 100;
fs = 16000;
qam_dim = 6;
prefix_length = 80;
stopBand = [1000,5000];
stdNoise = 0.0001;
bandNoise = 0.05;
% sequence generation
testLen = 10;
basic_ber = zeros(1,testLen);
on_off_ber = zeros(1,testLen);
adaptive_ber = zeros(1,testLen);
for i = 1:testLen

channel_model = randn(1,channel_order);
channel_freq_response = fft(channel_model, nfft);
seq = randi([0,1],1,2*fs);
basic_qam_orders = no_bit_loading(nfft, qam_dim);

mod_seq = ofdm_mod_bl(seq', basic_qam_orders, prefix_length);

rxOfdmStream = fftfilt(channel_model, mod_seq);

rxOfdmStream_noise = rxOfdmStream + stdNoise*randn(1,length(rxOfdmStream))'+ bandNoise*bandpass(randn(1,length(rxOfdmStream)),stopBand,fs)';
% Ofmd demodulation
demod_seq = ofdm_demod_bl(rxOfdmStream_noise, basic_qam_orders,prefix_length, channel_freq_response);

% BER
basic_ber(i) = ber(seq, demod_seq'); %ber basic

%On off bitloadaing
qam_orders = on_off_bit_loading(channel_freq_response, qam_dim,0.5);
if i == testLen
    subplot(1,2,1); plot(qam_orders); title('On-off QAM-orders');
end
mod_seq = ofdm_mod_bl(seq', qam_orders, prefix_length);

rxOfdmStream = fftfilt(channel_model, mod_seq);

rxOfdmStream = rxOfdmStream + 4*stdNoise*randn(1,length(rxOfdmStream))'+ 4*bandNoise*bandpass(randn(1,length(rxOfdmStream)),stopBand,fs)';
% Ofmd demodulation
on_off_demod_seq = ofdm_demod_bl(rxOfdmStream, qam_orders,prefix_length, channel_freq_response);

% BER
on_off_ber(i) = ber(seq, on_off_demod_seq'); %ber basic


% Get the Pn
sig = randn(1,2*fs);
sig_filt = fftfilt(channel_model,sig);
noiseSig = sig_filt + stdNoise*randn(1,length(sig_filt))+ bandNoise*bandpass(randn(1,length(sig_filt)),stopBand,fs);
[Pout] = pwelch(noiseSig,1000, 500, nfft, fs);  %recorded signal PSD

[Ps] = pwelch(sig,1000,500,nfft,fs);
%let ps go through filter
TfSquared = abs(channel_freq_response).^2;

Ps = [Ps',fliplr(Ps(2:(length(Ps)-1)))'];
PsFiltered = TfSquared.*Ps;

Pn = real([Pout',fliplr(Pout(2:(length(Pout)-1)))'] - PsFiltered);
% Adaptive
qam_orders = adaptive_bit_loading(channel_freq_response, Pn,qam_dim);
if i == testLen
    subplot(1,2,2); plot(qam_orders); title('Adaptive QAM-orders');
end
mod_seq = ofdm_mod_bl(seq', qam_orders, prefix_length);
rxOfdmStream = fftfilt(channel_model, mod_seq);
rxOfdmStream = rxOfdmStream + stdNoise*randn(1,length(rxOfdmStream))'+ bandNoise*bandpass(randn(1,length(rxOfdmStream)),stopBand,fs)'; %add noise

% Ofmd demodulation
adapt_demod_seq = ofdm_demod_bl(rxOfdmStream, qam_orders,prefix_length, channel_freq_response);

% BER
adaptive_ber(i) = ber(seq, adapt_demod_seq'); %ber adaptive
end
figure;
hold on;
plot(basic_ber);
plot(on_off_ber);
plot(adaptive_ber);
title('BER')
legend(['Basic, with average: ' num2str(round(mean(basic_ber),3))],['ON OFF, with average: ' num2str(round(mean(on_off_ber),3))],['Adaptive, with average: ' num2str(round(mean(adaptive_ber),3))]);


hold off;