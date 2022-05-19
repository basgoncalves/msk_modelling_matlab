
x = 0:10*pi;                     % number of x values should be a power of x (Robertson 2011, p229)
y = sin(x);
fs = 1;                           % sampling frequency
fs/2;                              % Nyquist frequncy (midpoint of frequency range)

figure;
P1 = subplot(2,1,1);
plot(x,y);
title (sprintf('amplitude time series - %.fHz',fs))
ylabel ('amplitude (AU)')
xlabel ('time (s)')
P1.XAxisLocation = 'origin';
mmfn

% fft - https://au.mathworks.com/help/matlab/ref/fft.html
x = y;                              % sampled data
n = length(x);                      % number of samples
dt = 1/fs;                          % time increment per sample
t = (0:n-1)/fs;                     % time range for the data
xticklabels([0:dt:t(end)])          % x tick labels in sec
N = 2^nextpow2(n);                  % new input length that is the next power of 2 pad the signal X with trailing zeros in order to improve the performance of fft.
y = fft (x,n);                      % fast Fourier transformation of data (FFT)
abs(y);                             % Amplitude of the FFT
power = (abs(y)/N);                 % Power of the FFT
fs/n;                               % frequency increments
f = fs*(0:(N/2))/N;                 % frequency range

subplot(2,1,2)
plot (f,power(1:N/2+1))
title ('amplitude-frequency series')
ylabel ('amplitude (AU)')
xlabel ('frequency (Hz)')
mmfn

%% fazle 

Fs = 1000;                    % Sampling frequency
T = 1/Fs;                     % Sample time
L = 1000;                     % Length of signal
t = (0:L-1)*T;                % Time vector
% Sum of a 50 Hz sinusoid and a 120 Hz sinusoid
x = 0.7*sin(2*pi*50*t) + sin(2*pi*120*t);   % signal 
y = x %+ 2*randn(size(t));     % Sinusoids plus noise
figure(1)
plot(Fs*t(1:50),y(1:50))
title('Signal Corrupted with Zero-Mean Random Noise')
xlabel('time (milliseconds)')
NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(y,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);
% Plot single-sided amplitude spectrum.
figure(2)
plot(f,2*abs(Y(1:NFFT/2+1)))
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')
