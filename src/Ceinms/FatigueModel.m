%% Description - Basilio Goncalves (2020)
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS (check if they are in the path)
%   OrganiseFAI
%   mmfn
%   TimeNorm
%   GCOS
%   findData
%INPUT
%   CEINMSdir directory of the subjetc CEINMS folder in the ElaboratedData folder
%-------------------------------------------------------------------------
%OUTPUT
%   2 plots
%--------------------------------------------------------------------------

function FatigueModel
warning off
fp = filesep;
[Dir,Temp,SubjectInfo,Trials,Fcut]=getdirFAI('009'); % EDIT THIS FUNCTION FOR a DIFFERENT PROJECT
% close all

d.Tpre = 1:100;
d.Apre = 1:100;
d.Tpost = 1:70;
d.Apost = d.Tpost.^1.08;


figure
hold on 
plot(d.Tpre,d.Apre)
plot(d.Tpost,d.Apost)
xlabel('torque(%pre MVIC)')
ylabel ('EMG (%pre MVIC)')

legend('pre','post')

%plot pre and post dots
mmfn_inspect


%% activation-excitation dynamics (Pizzolato 2015)
trialName = Trials.CEINMS{1};
OptimalGamma = OptimalGammaCEINMS_BG(Dir,[Dir.CEINMSsimulations fp trialName],SubjectInfo);
trialDirs = getosimfilesFAI(Dir,trialName);
CEINMSSettings = CEINMSsetup_FAI(Dir,Temp,SubjectInfo);


muscle = 'BFLH';
adjMuscle = ['bflh_' lower(SubjectInfo.TestedLeg)];

adjEMG = importdata(OptimalGamma.Activations);
[adjEMG,~] = findData(adjEMG.data,adjEMG.colheaders, adjMuscle,2);

MP = getMP (CEINMSSettings.outputSubjectFilename,adjMuscle);

emgAll = importdata(trialDirs.emg);
[emg,~] = findData(emgAll.data,emgAll.colheaders, muscle,2);


% emg = 1:100;
fs = 200;               % frame rate
e = emg;                % excitation from input EMG
e = TimeNorm(e,fs);
A = MP.activationScale; % nonlinear shape factor
c1= MP.c1;              % recursive coefficients
c2= MP.c2;
g = 1;                  % muscle gain
emd = 0.015;            % electromechanical delay(seconds)
d = round(fs*emd);      % EMD (frames)
u = zeros(1,d);
a = zeros(1,d);
for t= 1+d:length(e)       % time (frames)
    u(t) = g.*e(t-d)-(c1+c2).*u(t-1)-c1*c2.*u(t-2);
    a(t) = (e(t)^(A.*u(t))-1)/(e(t)^A-1);
end

adjEMG = TimeNorm(adjEMG,fs);

figure
LW = 1.5;
plot(u.*100,'LineWidth',LW)
hold on
plot(a.*100,'LineWidth',LW)
plot(adjEMG.*100,'LineWidth',LW)
xlabel('time(frames)')
ylabel('activation(AU)')
plot(e.*100,'LineWidth',LW)
ylabel(' % max ')
legend('neural activation(u)','muscle activation(a)','activations (CEINMS)','experimental EMG')
title([trialName '-' muscle],'interpreter','none')
mmfn_inspect

%% mutiple C! and C2
LW = 1.5;
ha = tight_subplotBG(2,0,[],[],[],0.5); hold on
for i = -0.8:0.1:-0.1
    c1= i;              % recursive coefficients
    c2= i;
    for t= 1+d:length(e)       % time (frames)
        u(t) = g.*e(t-d)-(c1+c2).*u(t-1)-c1*c2.*u(t-2);
        a(t) = (e(t)^(A.*u(t))-1)/(e(t)^A-1);
    end
    axes(ha(1)); hold on; plot(u,'LineWidth',LW); xlim([0 100])
    axes(ha(2)); hold on; plot(a,'LineWidth',LW); xlim([0 100])
end
 tight_subplot_ticks(ha,0,0)
xlabel('time(frames)')
ylabel('activation(AU)')
legend(split((num2str([-0.8:0.1:-0.1]))))
title('neural activation(u)','interpreter','none')
mmfn_inspect

