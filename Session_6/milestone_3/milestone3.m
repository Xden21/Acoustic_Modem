%% part 1 => BW usage 100%

BWUsage = 100;
transmit_pic;
visualize_demod;

%% part 2 => on off bitloading with BWUsage 50%

BWUsage = 50;
transmit_pic;
visualize_demod;

%% Part 3 => adaptive bitloading

transmit_pic_adapt;
visualize_demod;
