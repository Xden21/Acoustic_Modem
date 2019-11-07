% Exercise session 4: DMT-OFDM transmission scheme
qam_dim = 4;
nfft = 80;
prefix_length = 80;
channel_order = 75;
snr = 30;

% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

% QAM modulation
% qamStream = qam_mod(bitStream, qam_dim);

% OFDM modulation
ofdmStream = ofdm_mod(bitStream, nfft, prefix_length);

% Channel
rxOfdmStream = awgn(ofdmStream, snr);

channel_model = h(1:channel_order);
rxOfdmStream = fftfilt(channel_model, rxOfdmStream);

channel_freq_response = fft(channel_model, nfft);

% OFDM demodulation
rxQamStream = ofdm_demod(rxOfdmStream, nfft, prefix_length, channel_freq_response);

% QAM demodulation
rxBitStream = qam_demod(rxQamStream, qam_dim);

% Remove padding
rxBitStream = rxBitStream(1:length(bitStream))';

% Compute BER
berTransmission = ber(bitStream,rxBitStream);

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);

% Plot images
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title('Received image'); drawnow;
