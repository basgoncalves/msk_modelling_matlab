%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Results for PhD paper 2 - Joint work before and after repeated sprints
% written to be used within "OpenSimPipeline_FatFAI.m"
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS (check if they are in the path)
%   OrganiseFAI
%   FindGaitCycle_Running
%   btk_loadc3d
%   TimeNorm
%INPUT
%   SubjectFoldersElaborated = cell vector containing the directories of
%                               the ElaboratedData for all participants
%   sessionName = string with the name of the session 
%   Trials = (optional) cell vector 
%   Logic = 1 (default); 1 = re-run trials / 2 = do not re-run trials 
%-------------------------------------------------------------------------
%OUTPUT
%   
%--------------------------------------------------------------------------

%% Function/Script name
function [Motions,GroupData] = ResultsJointWork_RS (SubjectFoldersElaborated,Trials,Logic)
fp = filesep;

if ~exist ('Logic')|| isempty(Logic);Logic = 1;end

Dir = getdirFAI(SubjectFoldersElaborated{1});
DirResults = Dir.Results_JointWorkRS;

Motions = {'hip_flexion','knee','ankle'};
fprintf ('\n');fprintf ('Checking motion: \n %s \n', Motions{1:end});fprintf ('\n')

%% generate basic structure
GroupData = struct;
NewLabels={};

for jj = 1: length(Motions)
    for tt = 1:length(Trials)
        
        % angle
        GroupData.(Motions{jj}).Angle.(Trials{tt}) = [];
        % moments
        GroupData.(Motions{jj}).Moments.(Trials{tt}) = [];
        % angular velocity
        GroupData.(Motions{jj}).AngularVelocities.(Trials{tt}) = [];
        % power
        GroupData.(Motions{jj}).Power.(Trials{tt}) = [];
        GroupData.(Motions{jj}).PowerNorm.(Trials{tt}) = [];
        
        % Absolute work
        % positive flexion
        GroupData.(Motions{jj}).AbsoluteWork.PosFlexStance.(Trials{tt}) = [];
        GroupData.(Motions{jj}).AbsoluteWork.PosFlexSwing.(Trials{tt}) = [];
        % positive extension
        GroupData.(Motions{jj}).AbsoluteWork.PosExtStance.(Trials{tt}) = [];
        GroupData.(Motions{jj}).AbsoluteWork.PosExtSwing.(Trials{tt}) = [];
        % negative flexion
        GroupData.(Motions{jj}).AbsoluteWork.NegFlexStance.(Trials{tt}) = [];
        GroupData.(Motions{jj}).AbsoluteWork.NegFlexSwing.(Trials{tt}) = [];
        % negative extension
        GroupData.(Motions{jj}).AbsoluteWork.NegExtStance.(Trials{tt}) = [];
        GroupData.(Motions{jj}).AbsoluteWork.NegExtSwing.(Trials{tt}) = [];
        
        % Relative work
        % positive flexion
        GroupData.(Motions{jj}).RelativeWork.PosFlexStance.(Trials{tt}) = [];
        GroupData.(Motions{jj}).RelativeWork.PosFlexSwing.(Trials{tt}) = [];
        % positive extension
        GroupData.(Motions{jj}).RelativeWork.PosExtStance.(Trials{tt}) = [];
        GroupData.(Motions{jj}).RelativeWork.PosExtSwing.(Trials{tt}) = [];
        % negative flexion
        GroupData.(Motions{jj}).RelativeWork.NegFlexStance.(Trials{tt}) = [];
        GroupData.(Motions{jj}).RelativeWork.NegFlexSwing.(Trials{tt}) = [];
        % negative extension
        GroupData.(Motions{jj}).RelativeWork.NegExtStance.(Trials{tt}) = [];
        GroupData.(Motions{jj}).RelativeWork.NegExtSwing.(Trials{tt}) = [];
    end
end


% Total work
for tt = 1:length(Trials)
    GroupData.TotalPosWork.(Trials{tt}) = [];
    GroupData.TotalNegWork.(Trials{tt}) = [];
end

GroupData.Subjects ={};

if Logic == 2 && exist([DirResults fp 'JointWork_RS' fp 'ExternaBiomechanics.mat'])
    load([DirResults fp 'JointWork_RS' fp 'ExternaBiomechanics.mat'])
end

%% loop through all participants to gather joint angles and moments as an output from 

for Subj = 1:length(SubjectFoldersElaborated)
 
   [Dir,Temp,SubjectInfo,~]=getdirFAI(SubjectFoldersElaborated{ff});           % get directories and subject info
    Subject = SubjectInfo.ID;
    
    fprintf('Gathering results for participant %s... \n',Subject)
    
    Motions = cleanOSName (Motions); %remove _l or _r from the names
    GroupData.Subjects{Subj}= Subject;

    for tt = 1:length(Trials)
        trialName = Trials{tt};
        
        if  exist([Dir.IK fp Trials{tt}])
            
            % sample frequency
            c3dData = btk_loadc3d([Dir.Input filesep trialName '.c3d']); % "Files" from OrganiseFAI
            fs = c3dData.marker_data.Info.frequency;
            
            fprintf('%s... \n',trialName)
            
            fileDir = [Dir.Input fp trialName '.c3d'];
            GCtype = 2;     % from toe off to toe off (1 = foot contatc to foot contact; 2 = Foot-off to foot off )
            [foot_contacts, ToeOff,GaitCycle] = FindGaitCycle_Running(fileDir,SubjectInfo.TestedLeg,GCtype);
           
            s = lower(SubjectInfo.TestedLeg);
            motions = {['hip_flexion_' s];['knee_angle_' s];['ankle_angle_' s]};
            
            % import IK
            IKresults = importdata([Dir.IK fp trialName fp 'IK.mot']);
            [IK,~] = findData(IKresults.data,IKresults.colheaders, motions,1);
            
            % import ID
            IDresults = importdata([Dir.ID fp trialName fp 'inverse_dynamics.sto']);
            [ID,MotionLabels] = findData(IDresults.data,IDresults.colheaders, motions,2);
            ID(:,3) = []; % delete Beta
            MotionLabels(3) = [];
            ID = ID./SubjectInfo.Weight;
            
            % crop data based on Gait cycle 
            if contains(trialName,'Run')&&contains(trialName,'1')
                T = IKresults.data(:,1);
                T_initial = find(T==GaitCycle.TO_time(1));
                T_final = find(T==GaitCycle.TO_time(2));
                % foot contact frame relative to the IK file
                FootContact_frame = round((T_final-T_initial)*(GaitCycle.FCPercent/100));
                IK = IK(T_initial:T_final,:);
                ID = ID(T_initial:T_final,:);
            else
                fprintf ('\n')
                fprintf ('trial is not a striaght running trial')
                fprintf ('\n')

                continue
            end
            % StrideTime (seconds)  
            StrideTime(tt,Subj) = length(IK)/fs;
            % Step frequency (Hz)  
            StepFreq(tt,Subj) = 1/StrideTime(tt,Subj);
            % Contact time(seconds)
            ContactTime(tt,Subj) = (length(IK) - FootContact_frame)/fs;
            % step location
            FC_c3d = GaitCycle.foot_contacts(1)-GaitCycle.FirstFrameC3D;
            FileDir = [Dir.Input filesep trialName '.c3d'];
            Pos = FindStepPosition (FileDir, 'MT',SubjectInfo.TestedLeg,FC_c3d);
            StepLocation(tt,Subj) = 8.2-(Pos.AP);
            
            
            % angular velocity in rad/sec
            AV = calcVelocity(IK,fs);
            AV = AV.*pi./180;
            % power
            P = AV.*ID;
            
            % time Normalise
            IKnorm = TimeNorm(IK,fs);
            IDnorm = TimeNorm(ID,fs);
            AVnorm = TimeNorm(AV,fs);
            Pnorm =  TimeNorm(P,fs);
            
            % joint work calculation          
            [pfW,nfW,peW,neW] = SplitJointWork (P,ID,AV,fs); 
            TotalPosWork = sum(pfW + peW);
            TotalNegWork = sum(nfW + neW);
            
            % Stance phase  
            P_stance = P(FootContact_frame:end,:);
            ID_stance = ID(FootContact_frame:end,:);
            AV_stance = AV(FootContact_frame:end,:);
            %split joint works based on joint power, moment and angular velocity
            % (ST = stance; positive(p)/negative(n) flexion(f)/extension(e) work (W))
            [STpfW,STnfW,STpeW,STneW] = SplitJointWork (P_stance,ID_stance,AV_stance,fs);  
            
            % Swing phase            
            P_swing = P(1:FootContact_frame,:);
            ID_swing = ID(1:FootContact_frame,:);
            AV_swing = AV(1:FootContact_frame,:);
            %split joint works based on joint power, moment and angular velocity
            % (SW = swing; positive(p)/negative(n) flexion(f)/extension(e) work (W))
            [SWpfW,SWnfW,SWpeW,SWneW] = SplitJointWork (P_swing,ID_swing,AV_swing,fs);  

        else % if the trial does not have an IK file then call all the variables NaN
            
            fprintf('No IK file found for %s \n',trialName)
            IKnorm = NaN(101,3);
            IDnorm = NaN(101,3);
            AVnorm = NaN(101,3);
            P = NaN(length(GroupData.(Motions{jj}).Power),3);
            Pnorm =  NaN(101,3);
            
            % Total Work
            TotalPosWork = NaN;
            TotalNegWork = NaN;

            % Absolute work
            STpfW = NaN(1,3);   % positive flexion
            SWpfW = NaN(1,3);
            STpeW = NaN(1,3);   % positive extension
            SWpeW = NaN(1,3);
            STnfW = NaN(1,3);   % negative flexion
            SWnfW = NaN(1,3);
            STneW = NaN(1,3);   % negative extension
            SWneW = NaN(1,3);

        end
        
        %assign data
        GroupData.TotalPosWork.(Trials{tt})(:,Subj)  = TotalPosWork;
        GroupData.TotalNegWork.(Trials{tt})(:,Subj) = TotalNegWork;
            
        
        for jj = 1: length(Motions)
            GroupData.(Motions{jj}).Angle.(Trials{tt})(:,Subj)                      = IKnorm(:,jj);
            GroupData.(Motions{jj}).Moments.(Trials{tt})(:,Subj)                    = IDnorm(:,jj);
            GroupData.(Motions{jj}).AngularVelocities.(Trials{tt})(:,Subj)          = AVnorm(:,jj);
            GroupData.(Motions{jj}).Power.(Trials{tt})(1:length(P),Subj)            = P(:,jj);
            GroupData.(Motions{jj}).PowerNorm.(Trials{tt})(:,Subj)                  = Pnorm(:,jj);
            
            % Absolute work
            % positive flexion
            GroupData.(Motions{jj}).AbsoluteWork.PosFlexStance.(Trials{tt})(:,Subj) = STpfW(jj);
            GroupData.(Motions{jj}).AbsoluteWork.PosFlexSwing.(Trials{tt})(:,Subj)  = SWpfW(jj);
            % positive extension
            GroupData.(Motions{jj}).AbsoluteWork.PosExtStance.(Trials{tt})(:,Subj)  = STpeW(jj);
            GroupData.(Motions{jj}).AbsoluteWork.PosExtSwing.(Trials{tt})(:,Subj)   = SWpeW(jj);
            % negative flexion
            GroupData.(Motions{jj}).AbsoluteWork.NegFlexStance.(Trials{tt})(:,Subj) = STnfW(jj);
            GroupData.(Motions{jj}).AbsoluteWork.NegFlexSwing.(Trials{tt})(:,Subj)  = SWnfW(jj);
            % negative extension
            GroupData.(Motions{jj}).AbsoluteWork.NegExtStance.(Trials{tt})(:,Subj)  = STneW(jj);
            GroupData.(Motions{jj}).AbsoluteWork.NegExtSwing.(Trials{tt})(:,Subj)   = SWneW(jj);
            
            % Relative work
            % positive flexion
            GroupData.(Motions{jj}).RelativeWork.PosFlexStance.(Trials{tt})(:,Subj) = STpfW(jj)/TotalPosWork;
            GroupData.(Motions{jj}).RelativeWork.PosFlexSwing.(Trials{tt})(:,Subj)  = SWpfW(jj)/TotalPosWork;
            % positive extension
            GroupData.(Motions{jj}).RelativeWork.PosExtStance.(Trials{tt})(:,Subj)  = STpeW(jj)/TotalPosWork;
            GroupData.(Motions{jj}).RelativeWork.PosExtSwing.(Trials{tt})(:,Subj)   = SWpeW(jj)/TotalPosWork;
            % negative flexion
            GroupData.(Motions{jj}).RelativeWork.NegFlexStance.(Trials{tt})(:,Subj) = STnfW(jj)/TotalNegWork;
            GroupData.(Motions{jj}).RelativeWork.NegFlexSwing.(Trials{tt})(:,Subj)  = SWnfW(jj)/TotalNegWork;
            % negative extension
            GroupData.(Motions{jj}).RelativeWork.NegExtStance.(Trials{tt})(:,Subj)  = STneW(jj)/TotalNegWork;
            GroupData.(Motions{jj}).RelativeWork.NegExtSwing.(Trials{tt})(:,Subj)   = SWneW(jj)/TotalNegWork;
            
        end
    end
    
    cd([DirResults fp 'JointWork_RS'])
    if exist([DirResults fp 'JointWork_RS' fp 'ExternaBiomechanics.mat'])
        save ExternaBiomechanics_new GroupData Motions
    else
        save ExternaBiomechanics GroupData Motions
    end
end

cmdmsg ('ResultsJointWork_RS complete!')



