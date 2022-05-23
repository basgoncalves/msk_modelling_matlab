function [ RMSE_sum , gamma_opt] = optimizeabc_intersect_BG(Subj_Code, dirFolders, trial_list, MuscleNamesOS, DeepHipMuscles)
%%% Script created by Kirsten Veerkamp 2018 %%%
%   finds gamma, based on balancing RMSE moments and RMSE activations
%   uses Newton's method
%   alfa and beta constrained to 1
%   Changes Evy Meinders 2020 % 
%   inputs: dir_main = output MOtoNMS; modeltype = idCEINMS; Subj_Code;
%   trial_type = trialname ('walking', 'SquatNorm', etc), trialnum = num of
%   the trials of interest, MuscleNamesOS = names muscles OpenSim included
%   in RMSE, R2; Phases; fignumer = nummer figure everything is plotted.
%   

%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
fp = filesep;
close all;
fignum = 1;
beta = 1;
gammas = 1:10:100;
disp(['optimising gamma range : ',num2str(min(gammas)) ,' - ', num2str(max(gammas))])
for w = 1:length(gammas)
    dirAssistedCfg = dirFolders;
    
    % load executionCfg file
    tree = xml_read(dirAssistedCfg);
    
    % change gamma
    tree.NMSmodel.type.hybrid.alpha  = 1;
    tree.NMSmodel.type.hybrid.beta  = beta;
    tree.NMSmodel.type.hybrid.gamma  = gammas(w);
    
    tree.NMSmodel.activation.exponential = struct;    

    prefXmlWrite.StructItem = false;
    prefXmlWrite.CellItem   = false;
    % save new executionCfg file
    xml_write(dirAssistedCfg, tree, 'execution', prefXmlWrite);
    RMSE_act_all = [];
    RMSE_mom_all = [];
    R2_act_all = [];
    R2_mom_all = [];    
    % run for one gamma
    for iTrial = 1:length(trial_list) % 
        [~,trialname] = fileparts(trial_list{iTrial});
        trial = trialname(1:end-1);
        disp(['execution trial: ', num2str(iTrial),' gamma: ', num2str(gammas(w))])

        dirExecutionOutput = [DirUp(dirFolders,2) fp 'simulations' fp trialname];
        dirAssistedSetupFile = [DirUp(dirFolders,2) fp 'Setup' fp trialname '.xml'];
        dirExecutionOutputOpt = [dirExecutionOutput fp 'optimization\gamma' num2str(gammas(w)) '\'];
        dirExecutionOutputOptRel = relativepath(dirExecutionOutputOpt,DirUp(dirFolders,1));
%         load setup file and write new one with right output directory
        ceinms = xml_read(dirAssistedSetupFile);
        ceinms.outputDirectory = dirExecutionOutputOptRel;
        xml_write(dirAssistedSetupFile, ceinms);
        
        if exist(dirExecutionOutputOpt,'dir') ==0
            k = 0;
        elseif ~exist(dirExecutionOutputOpt,'dir') == 0
            try
                [~, R2_emg_t, RMSE_emg_t] = check_trackingEMGs(dirFolders, dirExecutionOutputOpt, trialname, Phases, MuscleNamesOS);
                k = 1;
            catch 
                k = 0;
            end
        end
        
        if k ==0  % files don't exist yet.            
            % run EMG Assisted-modeling for this gamma
            DOS_EX = ['CEINMS -S ' dirAssistedSetupFile];
            
            CeinmsExeDir = 'C:\CEINMS_2';
            cd(CeinmsExeDir)
            [~,log_mes]=dos(DOS_EX); %'-echo'
            
             %Save the log file in a Log folder for each trial
             copyfile([CeinmsExeDir '\out.log'],dirExecutionOutputOpt)
             copyfile([CeinmsExeDir '\err.log'],dirExecutionOutputOpt)
            
     
        else
             
    
        end
        [~, ~ , Phases] = EventSelection(Subj_Code, dirFolders, {trial}, 0);

        [~, R2_emg_t, RMSE_emg_t] = check_trackingEMGs(dirFolders, dirExecutionOutputOpt, trialname, Phases, MuscleNamesOS); 
        [~, R2_mom_t, RMSE_mom_t] = check_trackingMoments(dirFolders, dirExecutionOutputOpt, trialname, Phases);
        
        RMSE_act_all(:,iTrial) = RMSE_emg_t;
        RMSE_mom_all(:,iTrial) = RMSE_mom_t;
        R2_act_all(:,iTrial) = R2_emg_t;
        R2_mom_all(:,iTrial) = R2_mom_t;    
        
    end
    
    % RMSE, R2 - mean over trials, joints/muscles
    RMSE_mom(w) = mean(mean(RMSE_mom_all));
    RMSE_act(w) = mean(mean(RMSE_act_all));     
    R2_mom(w) = mean(mean(R2_mom_all));
    R2_act(w) = mean(mean(R2_act_all));
end


% normalize RMSE moments
RMSE_mom_norm = RMSE_mom ./ max(RMSE_mom);

% normalize RMSE activations
RMSE_act_norm = RMSE_act ./ max(RMSE_act);

% sum RMSE
RMSE_sum = RMSE_mom_norm - 2*RMSE_act_norm;
% RMSE_sum = RMSE_mom_norm - RMSE_act_norm;

% plot sum RMSE vs gamma
figure(fignum);
plot(gammas,RMSE_mom_norm,'.r','markers',10 )
hold on
plot(gammas,RMSE_act_norm,'.b','markers',10)
hold on
plot(gammas,RMSE_sum,'ok')

p = polyfit(gammas,RMSE_sum,3);
y = polyval(p,gammas);
figure(fignum); hold on; plot(gammas,y,'g')
xlabel('gamma')
ylabel('normalized RMSE')
% legend('normalized RMSE moments','normalized RMSE activations','difference between RMSEs of both variables','fitted polynome')
k = polyder(p); % derivative of p. 

% Newton's method to find intersection
x = 5;
Tol = 0.0000001;
count = 0;
dx=1;   %this is a fake value so that the while loop will execute
% f=polyval(k,x);    % because f(-2)=-13
f=polyval(p,x);    % because f(-2)=-13

fprintf('step      x           dx           f(x)\n')
fprintf('----  -----------  ---------    ----------\n')
fprintf('%3i %12.8f %12.8f %12.8f\n',count,x,dx,f)
% xVec=x;fVec=f;
while (dx > Tol || abs(f)>Tol || count > 500)   %note that dx and f need to be defined for this statement to proceed
    count = count + 1;
    fprime = polyval(k,x);   
    xnew = x - (f/fprime);   % compute the new value of x
    dx=abs(x-xnew);          % compute how much x has changed since last step
    x = xnew;
    f =  polyval(p,x);       % compute the new value of f(x)

    fprintf('%3i %12.8f %12.8f %12.8f\n',count,x,dx,f)
end
if (x < 0 || count > 1000)
    x  = 1;
end

gamma_opt = abs(x);
figure(fignum);plot(gamma_opt,0,'xk','linewidth',15)
legend('nor.RMSE moments','nor.RMSE activations','diff.RMSEs mom&act','fitted polynome','opt.gamma')
hold on; plot(gammas(2):gammas(end),zeros(length(gammas(2):gammas(end)),1),':k')

% implement best gamma into execution cfg
tree = xml_read(dirAssistedCfg);

% change gamma
tree.NMSmodel.type.hybrid.alpha  = 1;
tree.NMSmodel.type.hybrid.beta  = beta;
tree.NMSmodel.type.hybrid.gamma  = gamma_opt;

tree.NMSmodel.activation.exponential = struct;    

prefXmlWrite.StructItem = false;
prefXmlWrite.CellItem   = false;
    % save new executionCfg file
 
% save new executionCfg file
xml_write(dirAssistedCfg, tree, 'execution', prefXmlWrite);

% make sure those results go into right folder
% run for one gamma
for iTrial = 1:length(trial_list)
    trialname = trial_list{iTrial};
    % load setup file
    dirAssistedSetupFile = [dirFolders.dirExecution '\AssistedSetup-',num2str(DeepHipMuscles),'-',trialname,'.xml'];
    dirExecutionOutput = [dirFolders.dirExecution '\Assisted\' trialname '\' dirFolders.idExecution ,'\'];

    dirExecutionOutputRel = relativepath(dirExecutionOutput,dirFolders.dirExecution);
    ceinms = xml_read(dirAssistedSetupFile);
    ceinms.outputDirectory = dirExecutionOutputRel;
    xml_write(dirAssistedSetupFile, ceinms);
end

dir_plotje = [dirFolders.dirExecution '\Assisted\figures\' dirFolders.idExecution, '\'];

if ~exist(dir_plotje,'dir')                                                   % see whether directory exist, otherwise create it
    mkdir(dir_plotje)
end

print(figure(fignum),[dir_plotje, '\optimization_gamma'],'-dpng')
close all
end

