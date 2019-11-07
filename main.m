% Exercise session 4: DMT-OFDM transmission scheme
qam_dim = 4;
nfft = 100;
prefix_length = 80;
channel_order = 50;
snr = 30;
load IRest.mat

% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

% QAM modulation
% qamStream = qam_mod(bitStream, qam_dim);

% OFDM modulation
qam_orders = no_bit_loading(nfft, qam_dim);

ofdmStream = ofdm_mod_bl(bitStream, qam_orders, prefix_length);

% Channel

channel_model = h(1:channel_order);
rxOfdmStream = fftfilt(channel_model, ofdmStream);
%rxOfdmStream = awgn(rxOfdmStream, snr);

channel_freq_response = fft(channel_model, nfft);

% OFDM demodulation
rxBitStream = ofdm_demod_bl(rxOfdmStream, qam_orders, prefix_length, channel_freq_response)';

% QAM demodulation
%rxBitStream = qam_demod(rxQamStream, qam_dim);

% Remove padding
rxBitStream = rxBitStream(1:length(bitStream))';

% Compute BER
berTransmission = ber(bitStream,rxBitStream);

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);

% Plot images
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title('Received image'); drawnow;
