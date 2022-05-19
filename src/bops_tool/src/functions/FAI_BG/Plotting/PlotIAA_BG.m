%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Select folder that contains individual
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS (check if they are in the path)
%   GCOS
%   findData
%   getMP
%   mmfn
%   TimeNorm
%   fullscreenFig
%
%INPUT
%   CEINMSdir = [char] directory of the your ceinms dta for one subject
%       e.g. = 'E:\3-PhD\Data\MocapData\ElaboratedData\subject\session\ceinms'
%-------------------------------------------------------------------------
%OUTPUT
%  
%--------------------------------------------------------------------------
% NOTE - you may need to change the names of the motions and muslces
%
%

function PlotIAA_BG(SubjectFoldersElaborated, sessionName)


fp = filesep;


%generate the first subject
folderParts = split(SubjectFoldersElaborated{1},filesep);
Subject = folderParts{end};
DirC3D = [strrep(SubjectFoldersElaborated{1},'ElaboratedData','InputData') filesep sessionName];
OrganiseFAI;



for ff = 1:length(SubjectFoldersElaborated)
    OldSubject = Subject;
    folderParts = split(SubjectFoldersElaborated{ff},filesep);
    Subject = folderParts{end};
    DirC3D = strrep(DirC3D,OldSubject,Subject);
    
    OrganiseFAI
    Files = dir(DirIAA); % trials with IK
    for i = 3:length(Files)
        
        TrialName = Files(i).name;
        
        s = lower(side{1});
        
        %load
        
        % contribution to GRF
        ResultsDir = [DirIAA fp TrialName fp 'IndAccPI_Results'];
        C = load_sto_file([ResultsDir fp TrialName '_IndAccPI_GRF_Z_' s '.sto']);
        fs = 1/(C.time(2)-C.time(1));
        % muscle forces
        ResultsDir = [DirIAA fp TrialName fp 'SO_results'];
        F = load_sto_file([ResultsDir fp TrialName '_StaticOptimization_force_CEINMS.sto']);
        %Joint moments
        ResultsDir = [DirID fp TrialName fp 'inverse_dynamics.sto'];
        M = load_sto_file([ResultsDir]);
        T = find(ismember(round(M.time,3),round(C.time,3))); %time window
        
        % runing speed 
        ResultsDir = [DirIK fp TrialName fp 'IK.mot'];
        Q = load_sto_file([ResultsDir]);
        Vmax = max(movmean(calcVelocity (Q.pelvis_tx ,fs),fs/10)); %max sepeed (100ms window)
        
        % GRF
        ResultsDir = [DirIAA fp TrialName fp TrialName '.mot'];
        GRF = load_sto_file([ResultsDir]);
        Tgrf = find(ismember(round(GRF.time,4),round(C.time,4))); %time window
        GRFz = sum([GRF.ground_force1_vy, GRF.ground_force2_vy,GRF.ground_force3_vy,GRF.ground_force4_vy],2);
        GRFz = TimeNorm(GRFz(Tgrf),fs);
  %%       
        muscles = {['gaslat_' s],['vaslat_' s],['soleus_' s]};
        JointMom = {['hip_flexion_' s '_moment'],['knee_angle_' s '_moment'],...
            ['ankle_angle_' s '_moment']};
        figure
        for ii = 1: length(muscles)
            % Muscle forces
            subplot(311)
            hold on
            plot(TimeNorm(F.(muscles{ii}),fs)./MassKG,'LineWidth',2)
            ylabel('Muscle force (N/Kg)')
            legend(muscles,'Interpreter', 'none')
            mmfn
            % Muscle contributions
            subplot(312)
            hold on
            plot(TimeNorm(C.(muscles{ii}),fs),'LineWidth',2)
            ylabel('Muscle contributions (%??)')
            legend(muscles,'Interpreter', 'none')
            mmfn
            % Joint Moments
            subplot(313)
            hold on
            plot(TimeNorm(M.(JointMom{ii})(T),fs),'LineWidth',2)
            ylabel('Moment (N.m)')
            legend(JointMom,'Interpreter', 'none')
            mmfn
            
        end
        
            subplot(311)
            ax = gca;
            ax.Position =[0.25 0.7 0.6 0.2];
            xticklabels([])
            
            subplot(312)
            ax = gca;
            ax.Position =[0.25 0.4 0.6 0.2];
            xticklabels([])
%             plot(GRFz)
            
            subplot(313)
            ax = gca;
            ax.Position =[0.25 0.11 0.6 0.2];
            xlabel('% stance')
            
            suptitle([TrialName ' (running speed = ' num2str(round(Vmax,2)) 'm/s)'])
    end
end

