[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

subplot(2,2,1); %time domain IR
IR_plot = plot(est_channel_model);


subplot(2,2,2); %trasnmitted image
colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,2,4); %received image

subplot(2,2,3); %channel freq response 
chfreqres_plot = plot(abs(calc_channel_freq_resp));
ylim([-20,100]);

refreshdata
%refresh using p.YDataSource = 'y ,p.XDataSource = 'x' for plot p =
%plot(x,y)
%after changing x or y, use refreshdata