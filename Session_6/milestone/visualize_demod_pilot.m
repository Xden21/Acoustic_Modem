%%
transmit_pic_pilots;

%%
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');
chan_freq_resp = abs(calc_channel_freq_resp(:,1));
imp_responses = ifft(calc_channel_freq_resp,nfft);
imp_respons = imp_responses(:,1);
image_data = received(1:length(bitStream))';
image_data_length  = ceil(length(image_data)/size(calc_channel_freq_resp,2));
send_time = (nfft+prefix_length)/fs;

%plots

subplot(2,2,1); %channel freq response 
imp_resp_pl = plot(imp_respons);
title('Channel in time domain');
imp_resp_pl.YDataSource = 'imp_respons';
ylim([-max(max(imp_responses)) max(max(imp_responses))]);

subplot(2,2,2); %trasnmitted image
colormap(colorMap); image(imageData); axis image; title('Transmitted image'); drawnow;
subplot(2,2,4); %received image

subplot(2,2,3); %time domain IR   
IR_plot = plot(chan_freq_resp);
title('Channel in frequency domain (no DC)'); 
IR_plot.YDataSource = 'chan_freq_resp';
ylim([0,10])

subplot(2,2,4);
colormap(colorMap);
imageRx = bitstreamtoimage(image_data(1:image_data_length), imageSize, bitsPerPixel);
im_pl = image(imageRx); axis image; drawnow;
title(['received image after seconds' num2str(send_time)]);
for pack = 2:size(calc_channel_freq_resp,2)
    pause(send_time);
    chan_freq_resp = abs(calc_channel_freq_resp(:,pack));
    imp_respons = imp_responses(:,pack);
    refreshdata


    subplot(2,2,4);
    colormap(colorMap);
    if pack == size(calc_channel_freq_resp,2)
        imageRx = bitstreamtoimage(image_data, imageSize, bitsPerPixel);
    else
        imageRx = bitstreamtoimage(image_data(1:pack*image_data_length), imageSize, bitsPerPixel);
    end
    im_pl = image(imageRx); axis image; drawnow;
    title(['received image after ' num2str((pack+1)*send_time) ' seconds']);
end
