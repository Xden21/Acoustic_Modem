load IRest.mat;
nfft = 256;
qam_dim = 4;
prefix_length =150;
Lt = 6; %amount of training frames
Ld = 30; %amount of data frames
fs = 16000;
channel_order = 60;

BWUsage = 100;

%% Channel Estimation
%random bitstream
trainbits = randi([0 1],1,qam_dim*(nfft/2-1));

%qam modulated tr   aining block
trainblock = qam_mod(trainbits,qam_dim);

%make a sequence of 100 trainingblocks
ofdm_train_seq = repmat(trainbits,1,100);
%ofdm of train seq
qam_orders = no_bit_loading(nfft, qam_dim);

Tx = ofdm_mod_est(ofdm_train_seq,qam_orders,prefix_length);
[simin,nbsecs,fs,sync_pulse] = initparams(Tx,fs,channel_order);
%sigout = fftfilt(h(1:channel_order),simin(:,1));
sim('recplay');
sigout = simout.signals.values;
Rx =alignIO(sigout,sync_pulse,channel_order);
[received,calc_channel_freq_resp] = ofdm_demod_est(Rx,qam_orders,prefix_length,trainblock);

channel_est_err = ber(trainbits, received')
%% Calculate qam orders

qam_orders = on_off_bit_loading(calc_channel_freq_resp, qam_dim,1- BWUsage/100);

%% Send picture with bitloading

bitcount = 0;
for i=1:nfft/2
    bitcount = bitcount + qam_orders(i);
end
trainbits = randi([0 1],1,bitcount);

%qam modulated training block
%trainblock = qam_mod(trainbits,qam_dim);

%get image data.
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');
%qamStream = qam_mod(bitStream, qam_dim);
[ofdmStream, trainblock,amount_of_packs] = ofdm_mod_bl(bitStream,qam_orders,prefix_length,trainbits,Lt,Ld);

%test for BER 0;
[simin,nbsecs,fs,sync_pulse] = initparams(ofdmStream,fs,channel_order);
%sigout = fftfilt(h(1:channel_order),simin(:,1));
%with accoustic channel
sim('recplay');
sigout = simout.signals.values;
Rx =alignIO(sigout,sync_pulse,channel_order);
Rx =Rx(1:length(ofdmStream)+50);
[output_sig,calc_channel_freq_resp] = ofdm_demod_bl(Rx,qam_orders,prefix_length,trainblock,Lt,Ld);
received = output_sig;
ber(bitStream',received)
