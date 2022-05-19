% calclate the perceitle p of a signal frequency
%
% REFERENCES
%   https://au.mathworks.com/help/matlab/ref/fft.html
%   https://au.mathworks.com/help/stats/prctile.html    


function Percent = FrequPercentile (Data,p,Fs)

X = Data;
Fs;           % Sampling frequency                    
T = 1/Fs;             % Sampling period       
L = length(X);             % Length of signal
t = (0:L-1)*T;        % Time vector

% fourrier transformation 
Y = fft(X);         

P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

% plot data 
% f = Fs*(0:(L/2))/L;
% plot(f,P1) 
% title('Single-Sided Amplitude Spectrum of X(t)')
% xlabel('f (Hz)')
% ylabel('|P1(f)|')

% 98th percentile 
Percent = prctile(P1,p);