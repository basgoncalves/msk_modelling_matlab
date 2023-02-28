%%EMG analysis Load sharing study
% Remove DC offset
EMG = detrend(emg.Channel1);
Fs = 1000; %Sampling frequency for EMG data
Fnyq = Fs/2; %Determines the Nyquist frequency
fcolow = 2; %Choose the cutoff for low-pass Butterworth filter
fcohigh = 20; % Choose cutoff for High-pass BW filter

%% Plot the raw data and rectified signal
subplot(2,1,1)
plot(emg.Channel1), xlabel(' (Hz)'), ylabel('Volts (V)'), title('EMG Raw')
subplot(2,1,2)
plot(EMG), xlabel(' (Hz)'), ylabel('Amplitude (V)'), title('Remove DC Offset EMG')

%High-pass filter
[b,a] = butter(2,fcohigh/Fnyq,'high');
filter_EMG = filtfilt(b,a,EMG);

%Rectify signal (Obtain absolute value)
rec_EMG = abs(filter_EMG-mean(filter_EMG)); 

%% figure(2); %Create new figure with plot of rectified signal
plot(actualFrames, rec_EMG), xlabel(' (Hz)'), ylabel('Amplitude (V)'), title('Rectified EMG')
% axis([min(actualFramess), max(actualFramess), 0, 6e-3]);

%% Low-pass filter
[b,a] = butter(2,fcolow*1.25/Fnyq,'low');
filter_EMG1 = filtfilt(b,a,rec_EMG);

%%
figure(3)
plot(actualFrames, EMG, 'b',actualFrames, rec_EMG, 'g', actualFrames, filter_EMG1, 'r'), xlabel(' (Hz)'), ylabel('Amplitude (V)'), title('Low Pass filtered EMG')
legend('Raw', 'Rectified', 'Linear envelope');

%% Vector of frequencies present in spectra
N = length(emg.Channel1);
freqs = 0:Fs/N:Fnyq;

%Compute fft and plot amplitude spectrum
LGastroc_fft = fft(emg.Channel1-mean(emg.Channel1));
figure(4);
plot(freqs, abs(LGastroc_fft(1:N/2+1)));
xlabel('Sampling frequency up to Nyquist frequency (Hz)'), ylabel('Magnitude'), title(sprintf('FFT at %d', Fs));
% axis([0, Fnyq, 0, 0.25])
%Compute and plot power spectrum
Px_Gastroc = LGastroc_fft.*conj(LGastroc_fft);
figure(5);
plot(freqs,abs(Px_Gastroc(1:N/2+1)));
xlabel('Sampling frequency up to Nyquist frequency (Hz)'), ylabel('Magnitude'), title(sprintf('Power spectrum at %d', Fs));
% axis([0, Fnyq, 0, 0.07])
%% Save Figures
saveas(figure(3),'NoisyEMG', 'jpeg'); 
saveas(figure(4),'FFT_NoisyEMG', 'jpeg'); 
saveas(figure(5),'PowerSpec_NoisyEMG', 'jpeg'); 
