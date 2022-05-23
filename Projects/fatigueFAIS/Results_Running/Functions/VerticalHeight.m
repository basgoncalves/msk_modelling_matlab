
% VJ C3D files collected using the VICON motion analysis system are opened 
% using BTK server (Biomechanics Tool-Kit). Variables of interest are then
% extracted from the C3D files into the Matlab workspace for further analysis.

function MaxHeight = VerticalHeight (forceData,fs)

%% -----------------------------------------------------------------------%
%  GRF - Data analysis
%-------------------------------------------------------------------------%

% time per sample
dt = 1/fs;


g = 9.81;
grf_z = forceData(:,3);

% Remove any offset
% grf_z_osr = -grf_z(:);  % negate if required
grfz_osr = grf_z(:)-min(grf_z(:));  %  offset removed
plot(grfz_osr)
%select baseleine for subjects weight
[x,y] = ginput(2);
mass= mean(grfz_osr(x(1):x(2)))/g;
bw = mass*g;

peakResidual =max(grfz_osr(x(1):x(2))-bw);                  % from Moir (2008) - DOI: 10.1080/10913670802349766

Start_minus = find(grfz_osr < bw-peakResidual);
Start_minus = Start_minus(1);
Start_plus = find(grfz_osr > bw+peakResidual);
Start_plus = Start_plus(1);
Start = min(Start_minus,Start_plus)

Flight = find(grfz_osr==0)
StartFlight = Flight(1);
EndFlight = Flight(end);

line([Start Start], ylim);

line([EndFlight EndFlight], ylim);

% % Details required for plotting
% samples = 1:length(grfz_osr);
% maxx = max(grfz_osr);
% miny = min(samples); maxy = max(samples); 
% 
% % Plot data to select start & end points
% figure (1)
% plot(grfz_osr);
% ylabel ('GRF-z [N]')
% xlabel ('Samples')
% axis ([miny maxy -100 maxx+100])
% grid on
% set(gcf,'units','normalized','position',[0.01 0.02 0.98 0.89]) % L B W H

% Ginput to determine 1.quiet standing, 2.take-off, & 3.landing
x1 = [Start StartFlight  EndFlight];
% [x1, y1] = ginput(3);
grfz = grfz_osr(round(x1(1)):round(x1(2)), :);


% Time vector
time = (1:length(grfz))*dt;
x1 = x1*dt;

% Calculating jump height

% 1.Flight-time method
ft = x1(3)-x1(2);
vto = (g*ft)/2;
yflight1 = (vto^2/(2*g))*100;

% 2.Impulse-momentum using integration
imp = trapz(grfz(:)-bw)*dt;
vtoimp = imp/mass;
relative_imp = vtoimp;
yflight2 = (vtoimp^2/(2*g))*100;

% % 3.Acceleration method -  Rod Barrett
% accel = (1/mass)*(grfz-bw);  % Calculate acceleration by solving Newtons second law: sum of forces on body equals mass * acceleration
% veloc = cumtrapz(time,accel);   % The function Z = cumtrapz(X,Y) integrates Y with respect to X using trapezoidal integration

% Double check impulse using average force x pushoff time (I=F.t)
po_time = x1(2)-x1(1);
avgf_imp = mean(grfz-bw)*po_time;


%% -----------------------------------------------------------------------%
%  Printing data to file
%-------------------------------------------------------------------------%




% Discrete Variables
%----------------------%
% if exist('VJ_Fatigue_Results.txt') == 0
%     fid = fopen('VJ_Fatigue_Results.txt', 'w');
%     header1 = 'subject_code, gender_code, trial_code, flight_time, jht_ftime, jht_impmom, impulse, impulse_f_x_t, impulse_rel';
%     fprintf(fid, '%s\n', header1);
% else
%     fid = fopen('VJ_Fatigue_Results.txt', 'a');
% end
% dataOut = [subjectIndex, genderIndex, trialIndex, ft, yflight1, yflight2, imp, avgf_imp, relative_imp];
% specifiers1 = '%6.2f,%6.2f,%6.2f,%6.2f,%6.2f,%6.2f,%6.2f,%6.2f,%6.2f\n';
% fprintf(fid, specifiers1, dataOut');
% fclose('all');


%% -----------------------------------------------------------------------%
%  End of m.file
%-------------------------------------------------------------------------%
