clc
clear
close all                            % close all opened figures

addpath(genpath('E:\MATLAB'));                % add current folder and sub folders to path

EMGdataAll = EMGanalysis_FAI(2);

bar(cell2mat(EMGdataAll(8:9,2:end)),'DisplayName','cell2mat(EMGdataAll(8:9,2:end))')
lg=legend('EMG Lahti Lunge', 'EMG MVIC', 'EMG Nordic curl');
xticklabels({'BFlh','ST'})
ylabel ('EMG (mV)')
set(lg,'color','none','Location', 'NorthEastOutside');


%% Plot BF 

%filter parameter 
        fcolow = 2;
        fcohigh = 300;
        Fs= 1000;
        
[filename,dataMVIC,Fs,Labels] = ImportEMGc3d;
 actualFrames = 1: length(dataMVIC); 
 [filter_MVIC,FFT_EMG] = emgAnalysis_noplots(dataMVIC, Fs, fcolow, fcohigh);
 MaxEMG_BF = max(movmean(filter_MVIC(:,8),Fs,10));
 MaxEMG_ST = max(movmean(filter_MVIC(:,7),Fs,10));
 
figure 
data = dataMVIC(:,8);
plot(data)
Nticks = length(xticks);
xticks(0:length(data)/10:length(data));
timeTrial = length(data)/Fs;
xticklabels(0:timeTrial/10:timeTrial);
xtickangle(45)
xlabel('Time(s)')
ylabel ('EMG (mV)')
title('MVIC')


figure 
data = filter_MVIC(:,8)/MaxEMG_BF*100;
plot(data)
Nticks = length(xticks);
xticks(0:length(data)/10:length(data));
timeTrial = length(data)/Fs;
xticklabels(0:timeTrial/10:timeTrial);
xtickangle(45)
xlabel('Time(s)')
ylabel ('EMG (%MVIC)')
title('MVIC')
ylim([0 100])



[filename,dataNordics,Fs,Labels] = ImportEMGc3d;
actualFrames = 1: length(dataNordics); 
[filter_Nordic,FFT_EMG] = emgAnalysis_noplots(dataNordics, Fs, fcolow, fcohigh);
 
figure 
data = dataNordics(:,8);
plot(data)
Nticks = length(xticks);
xticks(0:length(data)/10:length(data));
timeTrial = length(data)/Fs;
xticklabels(0:timeTrial/10:timeTrial);
xtickangle(45)
xlabel('Time(s)')
ylabel ('EMG (mV)')
title('Nordic')

figure 
data = filter_Nordic(:,8)/MaxEMG_BF*100;
plot(data)
Nticks = length(xticks);
xticks(0:length(data)/10:length(data));
timeTrial = length(data)/Fs;
xticklabels(0:timeTrial/10:timeTrial);
xtickangle(45)
xlabel('Time(s)')
ylabel ('EMG (%MVIC)')
title('Nordic')
ylim([0 100])

[filename,dataJohan,Fs,Labels] = ImportEMGc3d;
actualFrames = 1: length(dataJohan); 
[filter_Johan,FFT_EMG] = emgAnalysis_noplots(dataJohan, Fs, fcolow, fcohigh);

figure
plot(dataJohan(:,8));
Nticks = length(xticks);
xticks(0:length(dataJohan)/10:length(dataJohan));
timeTrial = length(dataJohan)/Fs;
xticklabels(0:timeTrial/10:timeTrial);
xtickangle(45)
xlabel('Time(s)')
ylabel ('EMG (mV)')
[x,y]=ginput(2)

figure 
data = dataJohan(x(1):x(2),8);
plot(data)
Nticks = length(xticks);
xticks(0:length(data)/10:length(data));
timeTrial = length(data)/Fs;
xticklabels(0:timeTrial/10:timeTrial);
xtickangle(45)
xlabel('Time(s)')
ylabel ('EMG (mV)')
title('Lahti Lunge')

figure 
data = filter_Johan(x(1):x(2),8)/MaxEMG_BF*100;
plot(data)
Nticks = length(xticks);
xticks(0:length(data)/10:length(data));
timeTrial = length(data)/Fs;
xticklabels(0:timeTrial/10:timeTrial);
xtickangle(45)
xlabel('Time(s)')
ylabel ('EMG (%MVIC)')
title('Lahti Lunge')
ylim([0 100])




%% ST

%filter parameter 
        fcolow = 2;
        fcohigh = 300;
       
        
[filename,dataMVIC,Fs,Labels] = ImportEMGc3d;
 actualFrames = 1: length(dataMVIC); 
 [filter_MVIC,FFT_EMG] = emgAnalysis_noplots(dataMVIC, Fs, fcolow, fcohigh);
 MaxEMG_BF = max(movmean(filter_MVIC(:,8),Fs,10));
 MaxEMG_ST = max(movmean(filter_MVIC(:,7),Fs,10));
 
figure 
data = dataMVIC(:,7);
plot(data)
Nticks = length(xticks);
xticks(0:length(data)/10:length(data));
timeTrial = length(data)/Fs;
xticklabels(0:timeTrial/10:timeTrial);
xtickangle(45)
xlabel('Time(s)')
ylabel ('EMG (mV)')
title('MVIC')


figure 
data = filter_MVIC(:,7)/MaxEMG_ST*100;
plot(data)
Nticks = length(xticks);
xticks(0:length(data)/10:length(data));
timeTrial = length(data)/Fs;
xticklabels(0:timeTrial/10:timeTrial);
xtickangle(45)
xlabel('Time(s)')
ylabel ('EMG (%MVIC)')
title('MVIC')
ylim([0 100])



[filename,dataNordics,Fs,Labels] = ImportEMGc3d;
actualFrames = 1: length(dataNordics); 
[filter_Nordic,FFT_EMG] = emgAnalysis_noplots(dataNordics, Fs, fcolow, fcohigh);
 
figure 
data = dataNordics(:,7);
plot(data)
Nticks = length(xticks);
xticks(0:length(data)/10:length(data));
timeTrial = length(data)/Fs;
xticklabels(0:timeTrial/10:timeTrial);
xtickangle(45)
xlabel('Time(s)')
ylabel ('EMG (mV)')
title('Nordic')

figure 
data = filter_Nordic(:,7)/MaxEMG_ST*100;
plot(data)
Nticks = length(xticks);
xticks(0:length(data)/10:length(data));
timeTrial = length(data)/Fs;
xticklabels(0:timeTrial/10:timeTrial);
xtickangle(45)
xlabel('Time(s)')
ylabel ('EMG (%MVIC)')
title('Nordic')
ylim([0 100])

[filename,dataJohan,Fs,Labels] = ImportEMGc3d;
actualFrames = 1: length(dataJohan); 
[filter_Johan,FFT_EMG] = emgAnalysis_noplots(dataJohan, Fs, fcolow, fcohigh);

figure
plot(dataJohan(:,7));
Nticks = length(xticks);
xticks(0:length(dataJohan)/10:length(dataJohan));
timeTrial = length(dataJohan)/Fs;
xticklabels(0:timeTrial/10:timeTrial);
xtickangle(45)
xlabel('Time(s)')
ylabel ('EMG (mV)')
[x,y]=ginput(2)

figure 
data = dataJohan(x(1):x(2),8);
plot(data)
Nticks = length(xticks);
xticks(0:length(data)/10:length(data));
timeTrial = length(data)/Fs;
xticklabels(0:timeTrial/10:timeTrial);
xtickangle(45)
xlabel('Time(s)')
ylabel ('EMG (mV)')
title('Lahti Lunge')

figure 
data = filter_Johan(x(1):x(2),8)/MaxEMG_ST*100;
plot(data)
Nticks = length(xticks);
xticks(0:length(data)/10:length(data));
timeTrial = length(data)/Fs;
xticklabels(0:timeTrial/10:timeTrial);
xtickangle(45)
xlabel('Time(s)')
ylabel ('EMG (%MVIC)')
title('Lahti Lunge')
ylim([0 100])




