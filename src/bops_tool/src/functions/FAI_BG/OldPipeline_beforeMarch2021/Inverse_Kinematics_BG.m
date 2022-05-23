% create the Inverse kinematics xml for dynamic trials
%
% Basilio Goncalves 2019
% AnalysisType = 2;                % 1= run all analysis / 2 = run only xml and gait cycles
% Logic = 1 (default); 1 = re-run trials / 2 = do not rerun the trial 
function Inverse_Kinematics_BG (DirC3D,model_file,accuracy,AnalysisType,Logic)

OrganiseFAI             % organise folders

if AnalysisType==1
disp('Running Inverse Kinematics & determining Gait Cycles...')
elseif AnalysisType==2
disp('determining Gait Cycles only...')
end

if ~exist('Logic') 
    Logic = 1;
end

%% select dynamic trials

c3dFiles = dir ([DirC3D fp '*.c3d']);
OriginalFiles = dir(sprintf('%s\\%s',DirMocap,'*.xml'));
TemplateIK_xml = [DirMocap fp 'IK_setup' suffix '.xml'];
Elabxml = xml_read([ElaborationFilePath fp 'elaboration.xml']);
TrialList = DynamicTrials;
%%  create IK xml for different dynamic trials and run Kinematics using opensim API
