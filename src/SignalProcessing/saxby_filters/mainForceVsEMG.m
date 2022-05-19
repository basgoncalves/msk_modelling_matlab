
clear;
close all;
clc;

%%
% script to examine the relationship between isometric elbow flexion and
% EMG singal. Run from /src directory.
% For 2008AHS, Introduction to Biomechanics, Lab # 5.
% d.saxby@griffith.edu.au

addpath(genpath(pwd));

%% Settings

a = 0;

if a < 1
    disp('---------------------')
    disp('Specifications')
    disp('---------------------')
    fs = input('Enter sampling frequency: ');
    disp(' ');
    dt = 1/fs;
    t = 0:dt:5-dt;
    gain = input('Enter amplifier gain: ');
    disp(' ');
    lengthOfTrial = input('Enter the length of the trial in seconds: ');
    disp(' ');
    order = input('Enter the order for the band pass filter: ');
    disp(' ');
    lpfcut = input('Enter the low pass cut-off frequency for the band pass filter: ');
    disp(' ');
    hpfcut = input('Enter the high pass cut-off frequency for the band pass filter: ');
    disp(' ');
    linEnvLPCut = input('Enter the cut-off frequency for the low pass filter used to create the linear envelope: ');
    disp(' ');
    if lpfcut > hpfcut
        a = 1;
        fcut = 0.8*[hpfcut, lpfcut];
    else
        error('The low pass cut-off frequency must be greater than the high pass cut-off frequency!');
        disp(' ');
        disp(' ');
    end
else
    fs = 2000;
    dt = 1/fs;
    lengthOfTrial = 5; % in seconds
    t = 0:dt:lengthOfTrial-dt;
    gain = 2000;
    order = 2;
    lpfcut = 400;
    hpfcut = 20;
    fcut = 0.8*[hpfcut, lpfcut];
    linEnvLPCut = 6;
end

% presets, comment our if GUI option is prefered, and set variable "a" on
% line 14 to zero.

%% Read in data holding EMG (first column) and force (second column)
% Trial 1
disp(' ');
cd(pwd);
[FileName,PathName] = uigetfile('*.mat','Select trial 1 (lowest force)', '..\');
cd(PathName);
% data1 = dlmread(FileName, '\t');
data1=load(FileName);

% Trial 2
disp(' ');
FileName = uigetfile('*.mat','Select trial 2');
% data2 = dlmread(FileName, '\t');
data2=load(FileName);

% Trial 3
disp(' ');
FileName = uigetfile('*.mat','Select trial 3');
% data3 = dlmread(FileName, '\t');
data3=load(FileName);

% Trial 4
disp(' ');
FileName = uigetfile('*.mat','Select trial 4 (highest force)');
% data4 = dlmread(FileName, '\t');
data4 = load(FileName);

%% Set force variables
force1 = data1.data(1:end-1,2);
force2 = data2.data(1:end-1,2);
force3 = data3.data(1:end-1,2);
force4 = data4.data(1:end-1,2);

%% Detrend gain-scaled data and assign to EMG variable
emg1 = detrend(data1.data(:,1)/gain, 'constant');
emg2 = detrend(data2.data(:,1)/gain, 'constant');
emg3 = detrend(data3.data(:,1)/gain, 'constant');
emg4 = detrend(data4.data(:,1)/gain, 'constant');

%% Plot Detrended EMG
fig(1) = figure('Name', 'Profile of Detrended EMG');
title('Detrended EMG')
hold on;
sizeOfT = size(t,2);
plot(t, emg4(1:sizeOfT), 'k');
plot(t, emg3(1:sizeOfT), 'b');
plot(t, emg2(1:sizeOfT), 'y');
plot(t, emg1(1:sizeOfT), 'c');
xlabel('Time [s]');
ylabel('EMG [mV]');

%% Band-pass filter emg
emg1BP = matfiltfilt(dt, fcut, order, emg1);
emg2BP = matfiltfilt(dt, fcut, order, emg2);
emg3BP = matfiltfilt(dt, fcut, order, emg3);
emg4BP = matfiltfilt(dt, fcut, order, emg4);

fig(2) = figure('Name', 'Band-pass filtered EMG');
title('BP filtered EMG');
hold on;
plot(t, emg4BP(1:sizeOfT), 'k');
plot(t, emg3BP(1:sizeOfT), 'b');
plot(t, emg2BP(1:sizeOfT), 'y');
plot(t, emg1BP(1:sizeOfT), 'c');
xlabel('Time [s]');
ylabel('EMG [mV]');

%% Rectify BP filtered emg and plot.
emg1Rect = abs(emg1BP);
emg2Rect = abs(emg2BP);
emg3Rect = abs(emg3BP);
emg4Rect = abs(emg4BP);

fig(3) = figure('Name', 'Full wave rectified band-passed EMG');
title('Rectified EMG')
hold on;
plot(t, emg4Rect(1:sizeOfT), 'k');
plot(t, emg3Rect(1:sizeOfT), 'b');
plot(t, emg2Rect(1:sizeOfT), 'y');
plot(t, emg1Rect(1:sizeOfT), 'c');
xlabel('Time [s]');
ylabel('EMG [mV]');

%% Linear Envelope to BP'd Rectified EMG
emg1LinEnv = matfiltfilt(dt, linEnvLPCut, order, emg1Rect);
emg2LinEnv = matfiltfilt(dt, linEnvLPCut, order, emg2Rect);
emg3LinEnv = matfiltfilt(dt, linEnvLPCut, order, emg3Rect);
emg4LinEnv = matfiltfilt(dt, linEnvLPCut, order, emg4Rect);

fig(4) = figure('Name', 'Linear Envelope of Conditioned EMG');
title('Linear envelope EMG')
hold on;
plot(t, emg4LinEnv(1:sizeOfT), 'k');
plot(t, emg3LinEnv(1:sizeOfT), 'b');
plot(t, emg2LinEnv(1:sizeOfT), 'y');
plot(t, emg1LinEnv(1:sizeOfT), 'c');
xlabel('Time [s]');
ylabel('EMG [mV]');

%% Calculate mean force and emg from each trial. Plot.
forceMean = [mean(force1), mean(force2), mean(force3), mean(force4)]; 
emgMean = [mean(emg1LinEnv), mean(emg2LinEnv), mean(emg3LinEnv), mean(emg4LinEnv)]; 

fig(5) = figure('Name', 'Mean Force and EMG');
title('Mean Force vs EMG');
hold on;
plot(emgMean, forceMean, 'ko')
ylabel('Mean Force [N]');
xlabel('Mean EMG [mV]');

p = polyfit(emgMean, forceMean, 1);
f = polyval(p, emgMean);
plot(emgMean, f, '--r');

%%
rmpath(pwd);
