function [filter_EMG1,EMG_fft] = emgAnalysis_noplots(EMG, Fs, fcolow, fcohigh)
%Function to process raw EMG data and run an FFT on the data
%   Input raw EMG signal, the frequency it was collected at, the low-pass
%   filter frequency, the high-pass filter frequency, and vector with number of frames in trial. 

EMGdetrend = detrend(EMG);
Fnyq = Fs/2;

%High-pass filter
[b,a] = butter(2,fcohigh/Fnyq,'high');
filter_EMG = filtfilt(b,a,EMGdetrend);

%Rectify signal (Obtain absolute value)
rec_EMG = abs(filter_EMG-mean(filter_EMG)); 

%% Low-pass filter
[b,a] = butter(2,fcolow*1.25/Fnyq,'low');
filter_EMG1 = filtfilt(b,a,rec_EMG);

%% Vector of frequencies present in spectra
N = length(EMGdetrend);
freqs = 0:Fs/N:Fnyq;

%Compute fft and plot amplitude spectrum
EMG_fft = fft(EMGdetrend-mean(EMGdetrend));


end

