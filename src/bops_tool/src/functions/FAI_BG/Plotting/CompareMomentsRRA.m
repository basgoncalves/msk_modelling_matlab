

function  CompareMomentsRRA(DirID,trialName)

fp = filesep;
DirElaborated =  fileparts(DirID);
DirRRA =  strrep(DirID,'inverseDynamics','residualReductionAnalysis');
side = findLeg(DirElaborated,trialName);

s = lower(side{1});
moments = {'time';['pelvis_tilt_moment'];['pelvis_list_moment'];['lumbar_extension_moment'];...
['hip_flexion_' s '_moment'];['knee_angle_' s '_moment'];['ankle_angle_' s '_moment']};
MatchWord = 1;
%{'pelvis_rotation_moment','pelvis_tx_force','pelvis_ty_force','pelvis_tz_force'}

% ID after RRA
[ID_rra,~] = LoadResults_BG ([DirID fp trialName fp 'inverse_dynamics_RRA.sto'],...
    [],moments,MatchWord);
%ID 
[ID,Labels] = LoadResults_BG ([DirID fp trialName fp 'inverse_dynamics.sto'],...
    [],moments,MatchWord);


figure
Xlab = '% GaitCycle';
x =[1:101];
Ylab = 'moment(Nm)';
nrows = 2;
ncols = 3;
for kk = 2: length(Labels)
    subplot(nrows,ncols,kk-1)
    hold on
    plot(x,ID(:,kk))
    plot(x,ID_rra(:,kk))
    title(Labels{kk},'Interpreter','none')
    ylim([-500 500])
    mmfn
     % x Labels and x ticks
    if kk-1 > 2
        xlabel(Xlab)
    else
        xticks('')
    end
    
    %y ticks
    if kk-1 ~= [1:ncols:length(Labels)-1]
        yticks('')
    else
        ylabel(Ylab);
    end
    
end
legend('ID','RRA')
mmfn

cd([DirRRA fp trialName fp 'RRA'])
saveas(gcf,'IDafterRRA.jpeg')

cd([DirID fp trialName])
saveas(gcf,'IDafterRRA.jpeg')

%% Compare kinematics
coordinates = {'time';['lumbar_extension'];['hip_flexion_' s];['knee_angle_' s];...
    ['ankle_angle_' s]};

% IK after RRA
[IK_rra,~] = LoadResults_BG ([DirRRA fp trialName fp 'RRA' fp trialName '_Kinematics_q.sto'],...
    [],coordinates,MatchWord);
%ID 
Data = importdata([DirRRA fp trialName fp 'RRA' fp trialName '_Kinematics_q.sto']);
TimeWindow = round([Data.data(1,1) Data.data(end,1)],2);
[IK,Labels] = LoadResults_BG ([DirRRA fp trialName fp 'RRA' fp 'IK.mot'],...
    TimeWindow,coordinates,MatchWord);

%% plot IK 


figure
Xlab = '% GaitCycle';
x =[1:101];
Ylab = 'Angle (deg)';
nrows = 2;
for kk = 2: length(Labels)
    subplot(nrows,nrows,kk-1)
    hold on
    plot(x,IK(:,kk))
    plot(x,IK_rra(:,kk))
    title(Labels{kk},'Interpreter','none')
    mmfn
     % x Labels and x ticks
    if kk-1 > 2
        xlabel(Xlab)
    else
        xticks('')
    end
    
    %y ticks
    if kk-1 ~= [1:nrows:length(Labels)-1]
        yticks('')
    else
        ylabel(Ylab);
    end
    
end
legend('IK','RRA')
mmfn
% save in the RRA file folder
cd([DirRRA fp trialName fp 'RRA'])
saveas(gcf,'IKafterRRA.jpeg')
% save in the ID file folder
cd([DirID fp trialName])
saveas(gcf,'IKafterRRA.jpeg')


close all


