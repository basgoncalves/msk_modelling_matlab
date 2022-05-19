
clear;
close all;
clc;

%%
% script to condition the raw EMG to linear envelope
% Run from /src directory.
% For 2008AHS, Introduction to Biomechanics, Lab # 5.
% d.saxby@griffith.edu.au

addpath(genpath(pwd));

%% Settings

a = 1;

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
    gain = 2000;
    order = 2;
    lpfcut = 400;
    hpfcut = 20;
    fcut = 0.8*[hpfcut, lpfcut];
    linEnvLPCut = 4;
    
end

% presets, comment our if GUI option is prefered, and set variable "a" on
% line 14 to zero.



%% Read in data holding EMG (first column) and force (second column)
% Trial 1
disp(' ');
cd(pwd);
[FileName,PathName] = uigetfile('*.mat','Select trial erector spinae data ', '..\');
cd(PathName);
% data = dlmread(FileName, '\t');
load(FileName);

%% Detrend gain-scaled data and assign to EMG variable
emg = detrend(data(:,1)/gain, 'constant');

%% Plot Detrended EMG
fig(1) = figure('Name', 'Profile of Detrended EMG');
title('Detrended EMG')
hold on;
sizeOfT = size(emg,1);
t = 1:sizeOfT;
plot(t, emg, 'c');
xlabel('Time [s]');
ylabel('EMG [mV]');

%% Band-pass filter emg
emgBP = matfiltfilt(dt, fcut, order, emg);

fig(2) = figure('Name', 'Band-pass filtered EMG');
title('BP filtered EMG');
hold on;
plot(t, emgBP(1:sizeOfT), 'c');
xlabel('Time [s]');
ylabel('EMG [mV]');

%% Rectify BP filtered emg and plot.
emgRect = abs(emgBP);

fig(3) = figure('Name', 'Full wave rectified band-passed EMG');
title('Rectified EMG')
hold on;
plot(t, emgRect(1:sizeOfT), 'c');
xlabel('Time [s]');
ylabel('EMG [mV]');

%% Linear Envelope to BP'd Rectified EMG
emgLinEnv = matfiltfilt(dt, linEnvLPCut, order, emgRect);

fig(4) = figure('Name', 'Linear Envelope of Conditioned EMG');
title('Linear envelope EMG')
hold on;
plot(t, emgLinEnv(1:sizeOfT), 'c');
xlabel('Time [s]');
ylabel('EMG [mV]');

%%
rmpath(pwd);
