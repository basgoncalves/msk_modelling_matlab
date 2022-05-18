%%EMG analysis Load sharing study
% First remove DC offset
EMG = detrend(Channel2); % Channel 2 is a column vector representing data for a single muscle
Fs = 1500; %Sampling frequency for your EMG data
Fnyq = Fs/2; %Determines the Nyquist frequency
fcolow = 2; %Choose the cutoff for low-pass Butterworth filter
fcohigh = 20; % Choose cutoff for High-pass BW filter
Frame = [1,0:1:length(Channel2)]; % This should set the X-axis limits on plots.

%% Plot the raw data and DC offset signal
subplot(2,1,1)
plot(Channel2), xlabel(' (Hz)'), ylabel('Volts (V)'), title('EMG Raw')
subplot(2,1,2)
plot(EMG), xlabel(' (Hz)'), ylabel('Amplitude (V)'), title('Remove DC Offset EMG')

%High-pass filter
[b,a] = butter(2,fcohigh/Fnyq,'high');
filter_EMG = filtfilt(b,a,EMG);

%Rectify signal (Obtain absolute value)
rec_EMG = abs(filter_EMG-mean(filter_EMG));

figure(2); %Create new figure with plot of rectified signal
plot(Frame, rec_EMG), xlabel(' (Hz)'), ylabel('Amplitude (V)'), title('Rectified EMG')
axis([min(Frame), max(Frame), 0, 6e-3]);

%Low-pass filter
[b,a] = butter(2,fcolow*1.25/Fnyq,'low');
filter_EMG_lowPass = filtfilt(b,a,rec_EMG);
figure(3)

% Plot Raw, rectified, and Linear envelope EMG
plot(Frame, EMG, 'b',Frame, rec_EMG, 'g', Frame, filter_EMG_lowPass, 'r'),...
     xlabel(' (Hz)'), ylabel('Amplitude (V)'), title('Low Pass filtered EMG Lat Gastroc Gain = 1')
legend('Raw', 'Rectified', 'Linear envelope');
axis([min(Frame), max(Frame), 0, 6e-3]);

%% Signal analysis

%Vector of frequencies present in spectra
N = length(Channel2);
freqs = 0:Fs/N:Fnyq;

%Compute fft and plot amplitude spectrum
LGastroc_fft = fft(Channel2-mean(Channel2));
figure(4);
plot(freqs, abs(LGastroc_fft(1:N/2+1)));
xlabel('Sampling frequency up to Nyquist frequency (Hz)'), ylabel('Magnitude'), title('FFT of Good EMG signal');
axis([0, Fnyq, 0, 0.25])

%Compute and plot power spectrum
Px_Gastroc = LGastroc_fft.*conj(LGastroc_fft);
figure(5);
plot(freqs,abs(Px_Gastroc(1:N/2+1)));
xlabel('Sampling frequency up to Nyquist frequency (Hz)'), ylabel('Magnitude'), title('Power spectrum of Good EMG signal');
axis([0, Fnyq, 0, 0.07]);

%% Save Figures
saveas(figure(3),'GoodEMG', 'tif');
saveas(figure(4),'FFT_GoodEMG', 'tif');
saveas(figure(5),'PowerSpec_GoodEMG', 'tif');
