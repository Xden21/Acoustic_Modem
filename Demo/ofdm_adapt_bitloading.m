fraction = 0.5;
qam_dim = 4;
nfft = 100;
prefix_length = 80;
channel_order = 50;
snr = 15;
load IRest.mat
fs=16000;

% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

% OFDM modulation
qam_orders = no_bit_loading(nfft, qam_dim);

ofdmStream = ofdm_mod_bl(bitStream, qam_orders, prefix_length);

% Channel

channel_model = h(1:channel_order);
rxOfdmStream = fftfilt(channel_model, ofdmStream);
rxOfdmStream = awgn(rxOfdmStream, snr);

channel_freq_response = fft(channel_model, nfft);

% OFDM demodulation
rxBitStream = ofdm_demod_bl(rxOfdmStream, qam_orders, prefix_length, channel_freq_response)';

% Remove padding
rxBitStream = rxBitStream(1:length(bitStream))';

% Compute BER
berTransmission = ber(bitStream,rxBitStream)

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);

% Plot images
subplot(2,2,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,2,3); colormap(colorMap); image(imageRx); axis image; title('Received image basic OFDM'); drawnow;

%----------ADAPTIVE---------
% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

%Channel
channel_model = h(1:channel_order);
channel_freq_response = fft(channel_model, nfft);
%Calculate noise power

Pn = get_noise_power(channel_model,fs,nfft,snr);
%OFDM modulation
qam_orders_adapt = adaptive_bit_loading(channel_freq_response,Pn,qam_dim);
subplot(2,2,2); plot(qam_orders_adapt); title('QAM-orders');
ofdmStream_adapt = ofdm_mod_bl(bitStream, qam_orders_adapt, prefix_length);


rxOfdmStream_adapt = fftfilt(channel_model, ofdmStream_adapt);
rxOfdmStream_adapt = awgn(rxOfdmStream_adapt, snr);

% OFDM demodulation
rxBitStream_adapt= ofdm_demod_bl(rxOfdmStream_adapt, qam_orders_adapt, prefix_length, channel_freq_response)';

% Remove padding
rxBitStream_adapt = rxBitStream_adapt(1:length(bitStream))';

% Compute BER
berTransmission_adapt = ber(bitStream,rxBitStream_adapt)

% Construct image from bitstream
imageRx_adapt = bitstreamtoimage(rxBitStream_adapt, imageSize, bitsPerPixel);

% Plot images
subplot(2,2,4); colormap(colorMap); image(imageRx_adapt); axis image; title('Received image adaptive bit loading'); drawnow;
