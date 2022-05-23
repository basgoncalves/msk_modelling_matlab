function Vf = HfFilter(V,N,fc,fs,nn)
% Vf: filtered signal
% V: raw signal, matrix. Filter in vertical direction.
% fc: cutoff frequency
% fs: sample frequency 
Wn = 2*fc/fs;
[B,A] = butter(N,Wn);
Vf = zeros(size(V,1),nn);
for j = 1:nn
  Vf(:,j) = filtfilt(B,A,V(:,j));
end  