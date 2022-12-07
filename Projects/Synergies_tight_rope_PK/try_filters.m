% signal = EMG_raw.(proband).MVC_sprint_01;
fR = 1000;
mus = 10;
% signal = signal(mus,:);
%frequ = [1,20]+50;
%signal = sqrt(signal.^2);
%band = filterSignal_butter(signal(mus,:), 'stop', fR,'order', 4, 'cutoff', [20,30]);
bandwidth_values = [30,400];
high     = filterSignal_butter(signal, 'bandpass', fR,'order', 4, 'cutoff',  bandwidth_values);
%low1  = filterSignal_butter(high, 'low', fR, 'order', 2, 'cutoff', 30); % 4th order low-pass Butterworth filter 6 Hz

demeaned = high - mean(high); % demeaned

rectif = sqrt(demeaned.^2); %rectified

cuttoff_low = 9;
low  = filterSignal_butter(rectif, 'low', fR, 'order', 2, 'cutoff', cuttoff_low); % 4th order low-pass Butterworth filter 6 Hz
rms(low)
max(high)

ha = tight_subplotBG(5);
axes(ha(1))
plot(signal);
hold on
x = plot(low);
set(x, 'linewidth', 2);
title('Raw vs Processed')

axes(ha(2))
plot(high);
title(['band pass filtered = [' num2str(bandwidth_values) ']'])

axes(ha(3))
plot(demeaned);
title('demeaned')

axes(ha(4))
plot(rectif);
title('rectified')

axes(ha(5))
plot(low);
title(['low pass = [' num2str(bandwidth_values) ']'])

% figure(1)
% plot(signal);
% hold all
% x = plot(low2);
% set(x, 'linewidth', 2);
% figure(2)
% plot(high);
% figure(3)
% plot(demeaned);
% figure(4)
% plot(rectif);
% figure(5)
% plot(low2);
% %figure(6)
%plot(band)