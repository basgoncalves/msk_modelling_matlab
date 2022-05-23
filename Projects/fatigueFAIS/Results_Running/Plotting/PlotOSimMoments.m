%% Description - Goncalves, BM (2019)
% plot Inverse kinematics results from OpenSim
%
%Select folder that contains individual
% CALLBACK FUNTIONS
%   mmfn = make my figure nice
%   findData
%   combineForcePlates_multiple
%   fullscreenFig
%INPUT
%   DirIKResults
%   DirC3D
%   TestedLeg: 1 = Right, 2 = Left
%   GaitCycleType:  1 = Foot Strike to Foot strike, 2 = Toe off to Toe off
%   JointMotions: 
%-------------------------------------------------------------------------
%OUTPUT

%--------------------------------------------------------------------------

function [IDresults,IDresultsNormalized,GaitCycle,BadTrials,Labels] = PlotOSimMoments (DirIDResults,DirIKResults,DirC3D,TestedLeg,GaitCycleType,JointMotions,MassKG,Height,axisRange)
%% Variables assignment
if nargin <1
    DirIDResults = uigetdir(cd,'Select directory of the Inverse dynamics results form openSim');
end


Slashes   = strfind(DirIDResults,'\');

SplitNames = split(DirIDResults, filesep);
IdxElaboratedSession = find(contains(SplitNames,'ElaboratedData'));             % in which position in the directory is "Elaborated Data"
DirElaborated = DirIDResults(1:Slashes(IdxElaboratedSession+2)-1);
DirC3D = strrep(DirElaborated,'ElaboratedData','InputData');

mydir  = DirC3D;
idcs   = strfind(mydir,'\');
SubjFolder = mydir(1:idcs(end)-1);                      % Subject dir
idcs   = strfind(SubjFolder,'\');   
Subject = SubjFolder(idcs(end)+1:end);                  % subject ID




DirIKResults = [DirElaborated filesep 'inverseKinematics' filesep 'Results'];

if  ~exist(DirIKResults)
    DirIKResults = uigetdir(cd,'Select directory of the Kinematics results form openSim');
    
end

if ~exist(DirC3D)
    DirC3D = uigetdir(cd,'Select directory of the c3dData for the same subject');
end

if ~exist('TestedLeg')
    definput = {'1 = Right', '2 = Left'};
    [idx,~] = listdlg('PromptString',{'Please choose the tested leg (1 = Right, 2 = Left)'},'ListString',definput);
    TestedLeg = idx;
elseif contains(TestedLeg,'R','IgnoreCase',true)
    TestedLeg=1;
elseif contains(TestedLeg,'L','IgnoreCase',true)
    TestedLeg=2;
end

if nargin <4
    definput = {'1 = Foot Strike to Foot strike', '2 = Toe off to Toe off'};
    [idx,~] = listdlg('PromptString',{'Please choose the tested leg (1 = Right, 2 = Left)'},'ListString',definput);
    GaitCycleType = idx;

end
if nargin <5
VariablesOsim = {'time','pelvis_tilt_moment','pelvis_list_moment','pelvis_rotation_moment',...
    'pelvis_tx_force','pelvis_ty_force','pelvis_tz_force',...
    'hip_flexion_r_moment','hip_adduction_r_moment','hip_rotation_r_moment',...
    'knee_angle_r_moment','knee_angle_r_beta_moment','ankle_angle_r_moment',...
    'subtalar_angle_r_moment','mtp_angle_r_moment',...
    'hip_flexion_l_moment','hip_adduction_l_moment','hip_rotation_l_moment',...
    'knee_angle_l_moment','knee_angle_l_beta_moment','ankle_angle_l_moment',...
    'subtalar_angle_l_moment','mtp_angle_l_moment',...
    'lumbar_extension_moment','lumbar_bending_moment','lumbar_rotation_moment',...
    'arm_flex_r_moment','arm_add_r_moment','arm_rot_r_moment',...
    'elbow_flex_r_moment','pro_sup_r_moment','wrist_flex_r_moment','wrist_dev_r_moment',...
    'arm_flex_l_moment','arm_add_l_moment','arm_rot_l_moment',...
    'elbow_flex_l_moment','pro_sup_l_moment','wrist_flex_l_moment','wrist_dev_l_moment'};


[idx,~] = listdlg('PromptString',{'Choose the varibales to plot kinematics'},'ListString',VariablesOsim);

JointMotions = VariablesOsim (idx);
end


FilesID = dir([DirIDResults filesep '*.sto']);
FilesIK = dir([DirIKResults filesep '*.mot']);

if isempty(FilesID)
    error('Inverse Dynamics results directory dos not contain any .sto file')
elseif isempty(FilesIK)
    error('Inverse Kinematics results directory dos not contain any .mot file')
end

oldChar='_';
newChar='-';
FilesID = replaceCharacters (oldChar,newChar,FilesID);    % Replace chanrarcters and reorganise alphabetically
FilesIK = replaceCharacters (oldChar,newChar,FilesIK);    % Replace chanrarcters and reorganise alphabetically


cd(DirIDResults)
%% Create titles and labels

Labels = strrep(JointMotions,'_',' ');

Title = struct;
for pp = 1: length(JointMotions)
    Title.(JointMotions{pp}) = [Labels{pp} '(Nm/KG)'];
    
    if contains(JointMotions{pp},'pelvis_tilt','IgnoreCase',1)
        TxtUp.(JointMotions{pp}) = 'posterior';
        TxtDown.(JointMotions{pp}) = 'anterior';
       
    elseif contains(JointMotions{pp},'pelvis_list','IgnoreCase',1)
        TxtUp.(JointMotions{pp}) = sprintf('right \ndown');
        TxtDown.(JointMotions{pp}) = sprintf('left \ndown');
        
    elseif contains(JointMotions{pp},'pelvis_rotation','IgnoreCase',1)
        TxtUp.(JointMotions{pp}) = sprintf('right \nforward');
        TxtDown.(JointMotions{pp}) = sprintf('left \nforward');
        
    elseif contains(JointMotions{pp},'hip_flexion','IgnoreCase',1)
        TxtUp.(JointMotions{pp}) = 'flexion';
        TxtDown.(JointMotions{pp}) = 'extension';
        
    elseif contains(JointMotions{pp},'hip_adduction','IgnoreCase',1)
        TxtUp.(JointMotions{pp}) = 'adduction';
        TxtDown.(JointMotions{pp}) = 'abduction';
        
    elseif contains(JointMotions{pp},'hip_rotation','IgnoreCase',1)
        TxtUp.(JointMotions{pp}) = sprintf('medial \nrotation');
        TxtDown.(JointMotions{pp}) =  sprintf('lateral\nrotation');
        
    elseif contains(JointMotions{pp},'knee','IgnoreCase',1)
        TxtUp.(JointMotions{pp}) = 'flexion';
        TxtDown.(JointMotions{pp}) = 'extension';
        
    elseif contains(JointMotions{pp},'ankle','IgnoreCase',1)
        TxtUp.(JointMotions{pp}) = 'dorsiflexion';
        TxtDown.(JointMotions{pp}) = 'plantarflexion';
    
    elseif contains(JointMotions{pp},'lumbar_extension','IgnoreCase',1)
        TxtUp.(JointMotions{pp}) = 'extension';
        TxtDown.(JointMotions{pp}) = 'flexion';    
    
    elseif contains(JointMotions{pp},'lumbar_bending','IgnoreCase',1)
        TxtUp.(JointMotions{pp}) = sprintf('right \nflexion');
        TxtDown.(JointMotions{pp}) = sprintf('left \nflexion'); 
        
    elseif contains(JointMotions{pp},'lumbar_rotation')
        TxtUp.(JointMotions{pp}) = sprintf('right \nforward');
        TxtDown.(JointMotions{pp}) = sprintf('left \nforward');   
    else
        TxtUp.(JointMotions{pp}) = '+';
        TxtDown.(JointMotions{pp}) = '-';
        
    end
end

%% set all the plots for all the different kinematics


startColor = [jet]; colorSpace = length(startColor)/14;
colors = round(1:colorSpace:length(startColor));
startColor = [jet; hot];
colors = [colors round(colors(end)+colorSpace:colorSpace:length(startColor))];

IDData = struct;
JointWork = struct;
LegendNames = {};
BadTrials={};
loops = size(FilesID,1);
% MainFig = figure;
deleteRows = [];
%% check if trials have a gait cycle
for ff = 1:loops
     if ~contains (FilesID(ff).name, '_inverse_dynamics.sto') && ~exist('sufixIKResukts')
        msg = sprintf ('ID trial %s does not contain "_inverse_dynamics.sto", pelase change name of the results file or edit the function',FilesID(ff).name);
        sufixIKResukts = inputdlg(msg);
        
        continue
        else
            sufixIKResukts = '_inverse_dynamics.sto';
     end
         CurrentTrial = erase(FilesID(ff).name, sufixIKResukts);
         %% find gait cycle form the kinematics data 
        DirIK = split(DirIKResults,filesep);
        DirIK = erase(DirIKResults,DirIK{end});
        if isfile([DirIK 'GaitCycle-' CurrentTrial '.mat'])
        GC = load([DirIK filesep 'GaitCycle-' CurrentTrial]);               % gait cycle trial originates when running "Inverse_Kinematics_BG"
        GaitCycle.(CurrentTrial) = GC.GaitCycle.ToeOff-GC.GaitCycle.FirstFrameOpenSim-GC.GaitCycle.FirstFrameC3D;
        GaitCycle.(CurrentTrial)(3) = GC.GaitCycle.foot_contacts-GC.GaitCycle.FirstFrameOpenSim-GC.GaitCycle.FirstFrameC3D;
        end
% use this to find gait cycle if didn't run "Inverse_Kinematics_BG"
        if ~exist('GaitCycle')
            filename = [DirC3D filesep CurrentTrial '.c3d'];
            [foot_contacts, ToeOff] = FindGaitCycle_Running (filename,TestedLeg,GaitCycleType);
            if length(foot_contacts)<2 && length(ToeOff)<2
                GaitCycle.(CurrentTrial) = [1:2];
            elseif GaitCycleType==1
                GaitCycle.(CurrentTrial) = foot_contacts;
            elseif GaitCycleType==2
                GaitCycle.(CurrentTrial) = ToeOff;
            end
        end
        
          if length(GaitCycle.(CurrentTrial))<2 || GaitCycle.(CurrentTrial)(1) < 1 
            fprintf('no gait cycle data for %s \n', CurrentTrial)
            deleteRows(end+1) = ff;
            BadTrials{end+1}=CurrentTrial;
            continue
          end
         LegendNames{end+1}= CurrentTrial;
end

%delete trials without a gait cycle
FilesID(deleteRows)=[];
loops = size(FilesID,1);
%% Loop through all the kinematic variables
for pp = 1: length(fields(Title))
    

    MomentName = erase(sprintf('%s',Title.(JointMotions{pp})),' angle r');
    MomentName = erase(MomentName,' angle l');
    MomentName = strrep(MomentName,'on l','on');
    MomentName = strrep(MomentName,'on r','on');
%     FigCurrentTrial(pp)=figure;
%     hold on
%     title (MomentName)
    HeelStrike = [];
  % loop through all the trials in the results folder
    for ff = 1:loops
        
        
       
        CurrentTrial = erase(FilesID(ff).name, sufixIKResukts);
        IDData = importdata ([FilesID(ff).folder filesep FilesID(ff).name]); 
        LabelsIK = IDData.colheaders;
        IDData = IDData.data;
        [MomentData,SelectedLabels,IDxData] = findData (IDData,LabelsIK,JointMotions);            % callback function
        
        

%% Cut and plot data based on the gait cycle  
            

        if GaitCycle.(CurrentTrial)(2) > length(MomentData)
            fprintf('gait cycle wrongly computed %s \n', CurrentTrial)
            BadTrials{end+1}=CurrentTrial;
            continue
        end
       
        MomentData_cut  = MomentData(GaitCycle.(CurrentTrial)(1):GaitCycle.(CurrentTrial)(2),:);
        IDresults.(CurrentTrial) = MomentData_cut;
        
        if ~exist('MassKG')
            answer = inputdlg('please type the body weight of the participant in KG');
            MassKG = str2num(answer{1});
        end
        MomentData_Norm = TimeNorm(MomentData_cut,2000)/MassKG;
        IDresultsNormalized.(CurrentTrial) = MomentData_Norm;
        
        NormalizedGC = GaitCycle.(CurrentTrial)-GaitCycle.(CurrentTrial)(1);
        HeelStrike(end+1) = NormalizedGC(3)*100/NormalizedGC(2);
        
        if HeelStrike(end)> 80
            warning('Heel Strike for trial %s not well calculated',CurrentTrial)
        end
%         
%         if contains(CurrentTrial,'baseline')
%             p1 = plot (MomentData_Norm(:,pp),':','Color', (startColor(colors(ff),:)),...
%                 'LineWidth',3);
%         elseif contains(CurrentTrial,'K1')
%                   p1 = plot (MomentData_Norm(:,pp),':','Color',(startColor(colors(13),:)),...
%                 'LineWidth',3);
%         elseif contains(CurrentTrial,'L1') 
%             p1 = plot (MomentData_Norm(:,pp),':','Color',(startColor(colors(14),:)),...
%                 'LineWidth',3);
%         else
%             p1 = plot (MomentData_Norm(:,pp),'-','Color', (startColor(colors(ff),:)),...
%                 'LineWidth',1);
%         end
%         
        
      
           
    end
    
    GaitCycle.PercentageHeelStrike = HeelStrike;
    
%     mmfn    % callback function
%     fullscreenFig % callback function
%     a = get(gca,'ylabel');
%     FS = 18;
%     %define y axis limits 
%     if exist('axisRange')
%         ylim(axisRange);
%     end
%     xlb = xlabel('');
%     xlbPos = xlb.Position;
%     YaxisSize = ylim;
%     YPositionTextUp = YaxisSize(2);
%     YPositionTextDown = YaxisSize(1);
%     if mod(pp,2) == 1           % if subplot is odd number
%     XPositionTxt = a.Position(1)*3;
%     elseif mod(pp,2) == 0       % if subplot is even number
%     XPositionTxt = a.Position(1)*3;    
%     end
%     
%     Textup = text(XPositionTxt,YPositionTextUp,TxtUp.(JointMotions{pp}));
%     Textdown = text(XPositionTxt,YPositionTextDown,TxtDown.(JointMotions{pp}));
%     
%     set(Textup,'Rotation',0,'FontSize',FS*0.85,'HorizontalAlignment','right','VerticalAlignment','middle');
%     set(Textdown,'Rotation',0,'FontSize',FS*0.85,'HorizontalAlignment','right','VerticalAlignment','middle');
%     figure(FigCurrentTrial(pp))
%     ax = gca;
%     ax.XAxisLocation = 'origin';
%     ax.YAxisLocation = 'origin';
%     ax.FontSize = FS;
%     ax.Position = [0.25, 0.3, 0.6, 0.5];            %[Xpos,Ypos, Xlength,Ylength]
%     
%     p2 = plot([mean(HeelStrike) mean(HeelStrike)],[YaxisSize(1) YaxisSize(2)],'--','Color','k');
%     b = get(gca,'xlabel');
%     
%     xlb = xlabel ('Gait Cycle (%)');
%     xlb.Position= xlbPos;
%     set (xlb,'FontSize',FS*0.85,'VerticalAlignment','top','HorizontalAlignment','center')
%     
%     Arrow = text(mean(HeelStrike)*1.02,YaxisSize(1),'\leftarrow');
%     TextHS = text(mean(HeelStrike)*1.05,YaxisSize(1),'FC');
%     set(Arrow,'Position',[mean(HeelStrike) YaxisSize(2)],'Rotation',0,'FontSize',FS,'HorizontalAlignment','left','VerticalAlignment','top');
%     set(TextHS,'Position',[mean(HeelStrike)*1.075 YaxisSize(2)],'Rotation',0,'FontSize',FS,'HorizontalAlignment','center','VerticalAlignment','top');
%     
%     mergeFigures (FigCurrentTrial(pp), MainFig,[length(fields(Title)),1],pp)
end


% ST = suptitle(sprintf('Joint Moments Participant %s',Subject));
% ST.FontSize = FS; ST.FontWeight = 'bold';
%  % place legend at 80% of the length and centered in height 
% lhd = legend (LegendNames,'Interpreter','none','Location','best');
% pos = get(lhd,'Position'); pos(1)= 0.8; pos(2)=(1-pos(4))/2;       
% set(lhd,'Position',pos)
% set(lhd,'FontSize',15)


