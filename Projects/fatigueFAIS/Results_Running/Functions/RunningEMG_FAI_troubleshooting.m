
x1 = foot_contacts(1);
x2 = foot_contacts(2);
line([x1 x1], ylim);
line([x2 x2], ylim);

markersNames = fieldnames(data.marker_data.Markers);
HeelMarker = sort(markersNames(contains(markersNames, 'HEE'))); % Gets the foot markers
HeelMarkerR = HeelMarker{2};
HeelMarkerR = HeelMarker{1};


filter marker data
cutOff = 7;
Wn = cutOff/(fs_Markers/2);
[b,a] = butter(2,Wn);

% Find verical path heel marker 

PathHeelMarkerRz = filtfilt(b,a,data.marker_data.Markers.(HeelMarkerR)(:,3));
PathHeelMarkerLz = filtfilt(b,a,data.marker_data.Markers.(HeelMarkerL)(:,3));

% Find sagital path heel marker 
PathHeelMarkerRy = filtfilt(b,a,data.marker_data.Markers.(HeelMarkerR)(:,2));
PathHeelMarkerLy = filtfilt(b,a,data.marker_data.Markers.(HeelMarkerL)(:,2));

% Find verical path TOE marker 
PathToeMarkerRz = filtfilt(b,a,data.marker_data.Markers.(toeMarkerR)(:,3));
PathToeMarkerLz = filtfilt(b,a,data.marker_data.Markers.(toeMarkerL)(:,3));

% Find sagital path TOE marker 
PathToeMarkerRy = filtfilt(b,a,data.marker_data.Markers.(toeMarkerR)(:,2));
PathToeMarkerLy = filtfilt(b,a,data.marker_data.Markers.(toeMarkerL)(:,2));



GRFz = data.GRF.FP.F(:,3);



originalData = PathHeelMarkerRy;
finaData = GRFz;
InterpRatio = length(originalData)/length(finaData);                        % ti
originalLength = (InterpRatio:length(originalData))';
InterpPoints =  InterpRatio:InterpRatio:length(originalData);

PathHeelMarkerRz = interp1(originalLength,PathHeelMarkerRz,InterpPoints)';
PathHeelMarkerLz = interp1(originalLength,PathHeelMarkerLz,InterpPoints)';
PathHeelMarkerRy = interp1(originalLength,PathHeelMarkerRy,InterpPoints)';
PathHeelMarkerLy = interp1(originalLength,PathHeelMarkerLy,InterpPoints)';

PathToeMarkerRz = interp1(originalLength,PathToeMarkerRz,InterpPoints)';
PathToeMarkerLz = interp1(originalLength,PathToeMarkerLz,InterpPoints)';
PathToeMarkerRy = interp1(originalLength,PathToeMarkerRy,InterpPoints)';
PathToeMarkerLy = interp1(originalLength,PathToeMarkerLy,InterpPoints)';

fs_Analog = data.analog_data.Info.frequency;
time = 0:1/fs_Analog:length(finaData)/fs_Analog;
dt = 1/fs_Analog;


%% Plot Toe Rz

%filter marker data
cutOff = 7;
Wn = cutOff/(fs_Markers/2);
[b,a] = butter(2,Wn);

figure
hold on
DispToeRz= PathToeMarkerRz/1000;                     % displacement in m 
plot (DispToeRz,'b--');  

vToeRz = ((diff(DispToeRz)/ dt));       % velocity in m/s
vToeRz=vToeRz(:,1);
vToeRz(isnan(vToeRz))=0;
vToeRz = filtfilt(b,a,vToeRz);


plot((vToeRz(:,1)),'-');
[vMin,ContactToeRz_idx_velocity]=min(vToeRz(:,1));
hold on
plot([0 2000],[0 0],'k-')

plot (ContactToeRz_idx_velocity,vMin,'r.','MarkerSize',20)
ylabel('displacement(m) or velocity(m/s)')
yyaxis right 
plot(data.GRF.FP.F(:,end)/100,'b')
ylabel('Force(N)')

figure
yyaxis left 
hold on
aHeelRy =diff(vToeRz)/dt;
aHeelRy=aHeelRy(:,1);
aHeelRy(isnan(aHeelRy))=0;
aHeelRy = filtfilt(b,a,aHeelRy);
plot(aHeelRy)
plot([0 2000],[0 0],'k--')
[aMin,ContactToeRz_idx_acc]=min(aHeelRy(:,1));
[~,AccPeaks] = findpeaks(aHeelRy,1)
hold on
yyaxis right 
plot(data.GRF.FP.F(:,end)/100,'b')

plot (ContactToeRz_idx_acc,10,'g.','MarkerSize',20)
title ('Foot contact from Toe marker')
set(gca,'FontSize', 14)
legend('Displacement ToeRy', 'Velecoity ToeRy','Contact from Velocity','GRFz','Contact from Acceleration')
%% Plot Toe Ry

%filter marker data
cutOff = 7;
Wn = cutOff/(fs_Markers/2);
[b,a] = butter(2,Wn);

figure
hold on
xToeRy= PathToeMarkerRy/1000;                     % displacement in m 
plot (xToeRy,'r--');  

vToeRy = ((diff(xToeRy)/ dt));       % velocity in m/s
vToeRy=vToeRy(:,1);
vToeRy(isnan(vToeRy))=0;
vToeRy = filtfilt(b,a,vToeRy);

plot((vToeRy(:,1)),'-');
[vMin,ContactToeRy_idx_velocity]=min(vToeRy(:,1));
[vMax,ContactToeRy_idx_velocityMax]=max(vToeRy(:,1));
hold on
plot([0 2000],[0 0],'k-')

[ClosesToZero,ClosesToZeroidx]=min(abs(vToeRy-0));
minVal=vToeRy(ClosesToZeroidx);

plot(ClosesToZeroidx,ClosesToZero,'r.','MarkerSize',20)
plot (ContactToeRy_idx_velocityMax,vMax,'r.','MarkerSize',20)
plot (ContactToeRy_idx_velocity,vMin,'r.','MarkerSize',20)
ylabel('displacement(m) or velocity(m/s)')
yyaxis right 
plot(data.GRF.FP.F(:,end))

ylabel('Force(N)')
aHeelRy =diff(vToeRy)/dt;
[aMin,ContactToeRy_idx_acc]=min(aHeelRy(:,1));

plot (ContactToeRy_idx_acc,10,'g.','MarkerSize',20)
title ('Foot contact from Toe marker')
set(gca,'FontSize', 14)
legend('Displacement ToeRy', 'Velecoity ToeRy','Contact from Velocity','GRFz','Contact from Acceleration')
%% Plot Toe Lz
figure
hold on
xToeLz= PathToeMarkerLz;                     % displacement in m 
plot (xToeLz,'r--');                                
vToeLz = ((diff(xToeLz)./ diff(time)));       % velocity in m/s
yyaxis left
plot((vToeLz(:,1)),'-');
[vMin,ContactToeLz_idx_velocity]=min(vToeLz(:,1));
hold on
plot (ContactToeLz_idx_velocity,vMin,'r.','MarkerSize',20)
ylabel('displacement(m) or velocity(m/s)')
yyaxis right 
plot(data.GRF.FP.F(:,end))

ylabel('Force(N)')
aHeelRy =diff(vToeLz)/dt;
[aMin,ContactToeLz_idx_acc]=min(aHeelRy(:,1));

plot (ContactToeLz_idx_acc,10,'g.','MarkerSize',20)
title ('Foot contact from Toe marker')
set(gca,'FontSize', 14)
legend('Displacement ToeLz', 'Velecoity ToeLz','Contact from Velocity','GRFz','Contact from Acceleration')

plot([0 200],[0 0],'k-')
%% Plot Heel Rz

%filter marker data
cutOff = 7;
Wn = cutOff/(fs_Markers/2);
[b,a] = butter(2,Wn);

figure
hold on
DispHeelRz= PathHeelMarkerRz/1000;                     % displacement in m 
plot (DispHeelRz,'--');                                
vHeelRz = ((diff(DispHeelRz)./ diff(time)));       % velocity in m/s
vHeelRz=vHeelRz(:,1);
vHeelRz(isnan(vHeelRz))=0;
vHeelRz = filtfilt(b,a,vHeelRz);
yyaxis left
plot(vHeelRz,'-');
[vMin,ContactToeRz_idx_velocity]=min(vHeelRz(:,1));
hold on
plot (ContactToeRz_idx_velocity,vMin,'r.','MarkerSize',20)
yyaxis right 
plot(data.GRF.FP.F(:,end)/10)

aHeelRz =(diff(vHeelRz)/dt); 
aHeelRz=aHeelRz(:,1);
plot(aHeelRz); hold on
aHeelRz = filtfilt(b,a,aHeelRz);
plot(aHeelRz);
[aMin,aMinHeelRz_idx]=min(aHeelRz(:,1));
[~,PeakAcc_Rz] = findpeaks(aHeelRz(:,1),2000);

plot (aMinHeelRz_idx,10,'g.','MarkerSize',20)
set(gca,'FontSize', 14)
title ('Foot contact from Heel marker')
legend('Displacement HeelRz', 'Velecoity HeelRz','Contact from Velocity','GRFz','Contact from Acceleration')
%%
figure
hold on
plot(PathHeelMarkerRz,'g--')
plot(PathHeelMarkerLz,'c--')
plot(PathHeelMarkerRy,'b--')
plot(PathHeelMarkerLy,'r--')

plot(PathToeMarkerRz,'g')
plot(PathToeMarkerLz,'c')
plot(PathToeMarkerRy,'b')
plot(PathToeMarkerLy,'r')

legend('HeelRz', 'HeelLz','HeelRz','HeelLz','HeelRy','HeelLy','ToeRz', 'ToeLz','ToeRz','ToeLz','ToeRy','ToeLy''Force')
plot(data.GRF.FP.F(:,end))
ii = 2000
PathHeelMarkerRy(ii)
PathHeelMarkerLy (ii)

%% Vertical Position 
figure
yyaxis right 
plot(data.GRF.FP.F(:,end))
ylabel ('Force(N)')
hold on

DispToeRz= PathToeMarkerRz/1000;                     % displacement in m
DispHeelRz= PathHeelMarkerRz/1000; 
yyaxis left
plot (DispToeRz,'b--');  
plot (DispHeelRz,'r--');  

ToeContact = find (DispToeRz<min(DispToeRz)*1.6);
ToeContact_Binary = zeros((length(PathToeMarkerRz)),1);
ToeContact_Binary(ToeContact) = 1;
ContactsToe = find(ToeContact_Binary);
ToeStrikeRight=[];
ToeOffRight=[];
for ii = 2:length(ToeContact_Binary)
    if ToeContact_Binary(ii-1) == 0 && ToeContact_Binary(ii) == 1     % if rising burst =  heel strike       
        ToeStrikeRight(end+1) = ii;                
    elseif ToeContact_Binary(ii-1) == 1 && ToeContact_Binary(ii) == 0     % if falling burst = toe Off       
        ToeOffRight(end+1) = ii;        
    end    
end


HeelContact = find (DispHeelRz<min(DispHeelRz)*1.6);
HeelContact_Binary = zeros((length(PathHeelMarkerRz)),1);
HeelContact_Binary(HeelContact) = 1;
firstContactHeel = find(HeelContact_Binary);
HeelStrikeRight=[];
HeelOffRight=[];
for ii = 2:length(HeelContact_Binary)
    if HeelContact_Binary(ii-1) == 0 && HeelContact_Binary(ii) == 1     % if rising burst =  heel strike       
        HeelStrikeRight(end+1) = ii;                
    elseif HeelContact_Binary(ii-1) == 1 && HeelContact_Binary(ii) == 0     % if falling burst = toe Off       
        HeelOffRight(end+1) = ii;        
    end    
end

groundContact = min([ToeStrikeRight HeelStrikeRight]);

yyaxis left
%plot 
for ii = 1:length (ToeStrikeRight)
groundContact(ii) = min([ToeStrikeRight(ii) HeelStrikeRight(ii)]);
plot (groundContact,0,'r.','MarkerSize',20)
end


%plot toe off
for ii = 1:length (ToeOffRight)
plot (ToeOffRight,0,'b.','MarkerSize',20)
end

legend('ToeRz','HeelRz','GroundContact','GroundContact','ToeOff','ToeOff','Force')
ylabel ('displacement (m)')
title('vertical position threshold')
%% Mintab
ylim ([0 1.2])
 [maxtab, mintab]=peakdet(PathToeMarkerRz, 70);
plot (mintab(1,1),mintab(1,2)/1000,'r.','MarkerSize',20)
plot (mintab(2,1),mintab(2,2)/1000,'r.','MarkerSize',20)
plot (maxtab(1,1),maxtab(1,2)/1000,'b.','MarkerSize',20)
plot (maxtab(2,1),maxtab(2,2)/1000,'c.','MarkerSize',20)




[~,LeftPeaks] = findpeaks(-PathHeelMarkerRz/1000,1);
plot (LeftPeaks(1),0.20,'r.','MarkerSize',20)

%% Vertical displacement method - Alvim et al. (2015) DOI:10.1123/jab.2014-0178

dt = 1/fs_Analog;
VericalDisplacement= (PathToeMarkerRz/1000).* (PathToeMarkerRy/1000);       % product of the veritcal and aterio-posterior positions in meters


DerivDisplacement = diff(VericalDisplacement)/dt;                           % pricut
[MinDeriv, MinDerividx] = min(abs(DerivDisplacement));

figure
hold on
plot (VericalDisplacement,'b-');
plot (DerivDisplacement,'b--');
plot(MinDerividx,MinDeriv,'b.','MarkerSize',20)
ylabel ('displacement (m)')
yyaxis right
plot(data.GRF.FP.F(:,end));
ylabel ('Force(N)')

title('Vertical displacement method')


%% Gait event algorithm 



%filter marker data
cutOff = 7;
Wn = cutOff/(fs_Markers/2);
[b,a] = butter(2,Wn);
dt = 1/fs_Analog;

VericalDisplacement= PathToeMarkerRz/1000;                     % displacement in m 


vToeRz = ((diff(DispToeRz)/ dt));                       % velocity in m/s
vToeRz=vToeRz(:,1);
vToeRz(isnan(vToeRz))=0;
vToeRz = filtfilt(b,a,vToeRz);

aToeRz =diff(vToeRz)/dt;                                % acceleration in m/s^2
aToeRz=aToeRz(:,1);
aToeRz(isnan(aToeRz))=0;
aToeRz = filtfilt(b,a,aToeRz);
[~,AccPeaks] = findpeaks(aToeRz,1);                     %index of peak

[NegativePeaks,~] =find(vToeRz(AccPeaks)<0);            % find peaks with negative gradient 
FirstPeak = AccPeaks(NegativePeaks(1));                 % index of the first peak
PosOfPeak =VericalDisplacement(AccPeaks(NegativePeaks(1)));

figure
hold on
plot (VericalDisplacement,'k-');
plot(FirstPeak,PosOfPeak,'b.','MarkerSize',20)
ylabel ('displacement (m)')
yyaxis right
plot(abs(aToeRz))
plot(data.GRF.FP.F(:,end)/10);
title('Gait event algorithm ')
ylabel ('Force(N)/Aceeleration(m/s2)')
legend ('Displacement','contact','Aceeleration','Force')

%%
load bostemp
days = (1:31*24)/24;
plot(days, tempC)
axis tight

hoursPerDay = 24;
coeff24hMA = ones(1, hoursPerDay)/hoursPerDay;
avg24hTempC = filter(coeff24hMA, 1, tempC);
plot(days,[tempC avg24hTempC])


[envHigh, envLow] = envelope(tempC,16,'peak');

legend('Hourly Temp','24 Hour Average (delayed)','location','best')
ylabel('Temp (\circC)')
xlabel('Time elapsed from Jan 1, 2011 (days)')
title('Logan Airport Dry Bulb Temperature (source: NOAA)')
Q= aHeelRz(:,1);
Q(isnan(Q))=0;
[envHigh, envLow] = envelope(Q,16,'peak')
acc = filtfilt(b,a,Q);

any(isnan(Q))
