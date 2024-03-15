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

function muscle_activation_from_excitations
warning off
fp = filesep;

% load data 
[filename, filepath] = uigetfile('*.csv', 'Select the emg .csv file');
fullfilepath = [filepath filename];

emg_data = importdata(fullfilepath);
[emg,~] = findData(emg_data.data,emg_data.colheaders, muscle,2);


%% activation-excitation dynamics (Pizzolato 2015)


% emg = 1:100;
fs = 1000;               % frame rate
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

