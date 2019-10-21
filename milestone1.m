%Milestones for the first 2 sessions.

%% Obligatory part

%White noise experiment of exercise 1-2
analyze_rec;
%Estimation of IR with IR2
IR2;
%Estimation of IR with IR1
IR1;
%% Shannon Channel Capacity measurements

%Shannon Capacity
compute_shannon;

%open fig Shannon capacity over distance.
open('Shannon_Capacity_over_distance.fig');

%% Bandstop tests

IR_bandstop;
%Test voor 3 opeenvolgend gefilterde signalen het verschil.
F2 = abs(Y/L);
F1 = F2(1:L/2+1);
F1(2:end-1) = 2*F1(2:end-1);
f = fs*(0:(L/2))/L;
prev1 = F1;
IR_bandstop

F2 = abs(Y/L);
F1 = F2(1:L/2+1);
F1(2:end-1) = 2*F1(2:end-1);
f = fs*(0:(L/2))/L;
prev2 = F1;
IR_bandstop
F2 = abs(Y/L);
F1 = F2(1:L/2+1);
F1(2:end-1) = 2*F1(2:end-1);
f = fs*(0:(L/2))/L;
prev3 = F1;
diff = zeros(1,length(prev1));
for i = 1:length(prev1)
    diff(i) = sqrt((sqrt((prev1(i)-prev2(i))^2)-prev3(i))^2);
end
figure;
plot(f, diff);

