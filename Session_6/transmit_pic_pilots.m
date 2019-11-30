load IRest.mat;
nfft = 512;
qam_dim = 4;
prefix_length =200;
fs = 16000;
channel_order = 120;

%pilot signals
pilotbits = randi([0 1],1,qam_dim*(nfft/4));
pilot_symbs = qam_mod(pilotbits, qam_dim);

%get image data.
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');
qam_orders = no_bit_loading(nfft, qam_dim);
ofdmStream = ofdm_mod_bl_pilot(bitStream,qam_orders,prefix_length, pilot_symbs);

%test for BER 0;
[simin,nbsecs,fs,sync_pulse] = initparams(ofdmStream,fs,channel_order);
%sigout = fftfilt(h(1:channel_order),simin(:,1));
%with accoustic channel
sim('recplay');
sigout = simout.signals.values;
Rx =alignIO(sigout,sync_pulse,channel_order);
Rx =Rx(1:length(ofdmStream));

[received,calc_channel_freq_resp] = ofdm_demod_bl_pilot(Rx,qam_orders,prefix_length,pilot_symbs);

ber(bitStream',received)
