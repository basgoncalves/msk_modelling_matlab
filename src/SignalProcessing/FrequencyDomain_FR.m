load data    %%1D array
Fs=2000;
t=0:1/Fs:1;
x=x(1:1000)-mean(x(1:1000)); %%Zero mean
n=length(x);
NFFT=2^nextpow2(n);
X=fft(x,NFFT)/length(x);
f=Fs/2*linspace(0,1,NFFT/2+1);
plot(f,abs(X(1:NFFT/2+1)));
xlabel('Frequency'); ylabel('|X(f)|'); 

fco=[30 400]; %%Bandpass filtering 
fnyq=Fs/2;
[b,a]=butter(3,fco*1.25/fnyq,'bandpass'); %usually windoww is calculated as: Wn = fco/(Fs/2); Overlapping amount is usually 50%.  
yyy=filtfilt(b,a,x);
yy=abs(yyy); %%Rectification  
BP_rectified=fft(yy,NFFT)/length(yy); 
figure;
plot(f,abs(BP_rectified(1:NFFT/2+1)));
xlabel('Frequency'); ylabel('|BP_rectified|'); 

fco2=6; %%Lowpass filtering 
[b,a]=butter(4,fco2/fnyq,'low');
y=filtfilt(b,a,yy);

NFFT=2^nextpow2(n);
Y=fft(y,NFFT)/length(y);
f=Fs/2*linspace(0,1,NFFT/2+1); 
figure; 
plot(f,abs(Y(1:NFFT/2+1)));
xlabel('Frequency'); ylabel('|Y|'); 