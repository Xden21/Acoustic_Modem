fraction = 0.5;
qam_dim = 4;
nfft = 100;
prefix_length = 80;
channel_order = 50;
snr = 43;
load IRest.mat

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

%----------- ON-OFF bitloading----------

% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

%Channel
channel_model = h(1:channel_order);
channel_freq_response = fft(channel_model, nfft);

%OFDM modulation
qam_orders_on_off = on_off_bit_loading(channel_freq_response,qam_dim,fraction);
subplot(2,2,2); plot(qam_orders_on_off); title('QAM-orders')
ofdmStream_on_off = ofdm_mod_bl(bitStream, qam_orders_on_off, prefix_length);


rxOfdmStream_on_off = fftfilt(channel_model, ofdmStream_on_off);
rxOfdmStream_on_off = awgn(rxOfdmStream_on_off, snr);

% OFDM demodulation
rxBitStream_on_off= ofdm_demod_bl(rxOfdmStream_on_off, qam_orders_on_off, prefix_length, channel_freq_response)';

% Remove padding
rxBitStream_on_off = rxBitStream_on_off(1:length(bitStream))';

% Compute BER
berTransmission_on_off = ber(bitStream,rxBitStream_on_off)

% Construct image from bitstream
imageRx_on_off = bitstreamtoimage(rxBitStream_on_off, imageSize, bitsPerPixel);

% Plot images
subplot(2,2,4); colormap(colorMap); image(imageRx_on_off); axis image; title('Received image ON-OFF bit loading'); drawnow;
