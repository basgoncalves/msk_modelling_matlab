%% Description - Goncalves, BM (2019)
%
% Create inverse dynamics xml for each trial
% Run after creating inverse kinematics
%
% CALLBACK FUNTIONS
%
%-------------------------------------------------------------------------
%INPUT
%   DirElaborated = row vector used to normalize EMG data. Each columns should
%   TemplateSetupID =  directory of the Setup Inverse Dynamics xml
%   TemplateGRF = directory of the GRF xml
%   OsimModel = Scaled Open Sim model
%   Logic = 1 (default); 1 = re-run trials / 2 = do not re-run trials 
%-------------------------------------------------------------------------
%OUTPUT
%   RunningEMG = struct with all the Running trials and the labels of the
%   channels
%
%--------------------------------------------------------------------------


function InverseDynamics_FAI (DirElaborated,TemplateSetupID,TemplateGRF,TrialList,OsimModel,Logic)

%create directories
fp = filesep;
[~,Subject] = fileparts(fileparts(DirElaborated));
DirDynamic = [DirElaborated fp 'dynamicElaborations'];
DirIK = [DirElaborated fp 'inverseKinematics'];
DirID = [DirElaborated fp 'inverseDynamics'];
ElaborationXml =  xml_read([DirDynamic fp 'elaboration.xml']);
AcqXml = xml_read([strrep(DirElaborated,'ElaboratedData' ,'InputData') fp 'acquisition.xml']);

cd(DirElaborated);

IKfiles = dir([DirIK]);

% if Setup inverse dynamcics directory is not referenced
if nargin<2
    [FileName,FilePath] = uigetfile('*.xml','Select InverseDynamics .xml file to load', cd);
    TemplateSetupID= [FilePath FileName];
    
    [FileName,FilePath] = uigetfile('*.xml','Select GRF .xml file to load', cd);
    TemplateGRF= [FilePath FileName];
    
end

if ~exist('Logic') 
    Logic = 1;
end
%% Loop through all the files in the Dynamic Elaboration Folder 
for ff = 1: length(TrialList)
    
    CurrentTrial = TrialList{ff};
    
    if Logic ~= 1 && exist([DirID fp CurrentTrial fp 'inverse_dynamics.sto'])
        continue 
    end
    IKverify = 0;
    if sum(contains({IKfiles.name},CurrentTrial))>0
        IKverify = 1;
        iK = find(contains({IKfiles.name},CurrentTrial));
        DirIKxml = [IKfiles(iK).folder fp IKfiles(iK).name fp 'setup_IK.xml'];
        IKXml =  xml_read(DirIKxml);
    end

    
    % if the IK does not exist 
    if IKverify==0
        sprintf('Inverse Kinematics xml does not exist for %s',CurrentTrial);
        continue
    end
    
    IDxml = xml_read(TemplateSetupID);
    GRFxml = xml_read(TemplateGRF);
    
    
    DirIDResults = [DirID fp CurrentTrial];
    mkdir(DirIDResults);
    %GRF file
    GRFxml.ExternalLoads.datafile = [DirDynamic fp CurrentTrial fp CurrentTrial '.mot'];
    GRFxml.ExternalLoads.external_loads_model_kinematics_file = IKXml.InverseKinematicsTool.output_motion_file;
    nForcePlates = length(GRFxml.ExternalLoads.objects.ExternalForce);
    
    % find the index of the current trial in the Acq XML
    idx_type = find(strcmp({AcqXml.Trials.Trial.Type},CurrentTrial(1:end-1)));
    idx_number = find([AcqXml.Trials.Trial.RepetitionNumber]==str2num(CurrentTrial(end)));
    idxAcq = intersect(idx_type,idx_number);
    
    
    % check forceplates 
    deletePlate=[];
    for FP = 1:nForcePlates
        
        LegOnPlate = AcqXml.Trials.Trial(idxAcq).StancesOnForcePlatforms.StanceOnFP(FP).leg;
        GRFxml.ExternalLoads.objects.ExternalForce(FP).ATTRIBUTE.name = LegOnPlate;
        if contains(LegOnPlate,'Right')
            GRFxml.ExternalLoads.objects.ExternalForce(FP).ATTRIBUTE.name = 'Right';
            GRFxml.ExternalLoads.objects.ExternalForce(FP).applied_to_body = 'calcn_r';
        elseif contains(LegOnPlate,'Left')
            GRFxml.ExternalLoads.objects.ExternalForce(FP).ATTRIBUTE.name = 'Left';
            GRFxml.ExternalLoads.objects.ExternalForce(FP).applied_to_body = 'calcn_l';
        else
            deletePlate(end+1) = FP;
        end
        
    end
    % delete those that are not used
    GRFxml.ExternalLoads.objects.ExternalForce(deletePlate)=[];
    
    % results directory
    IDxml.InverseDynamicsTool.results_directory = DirIDResults;
    
    % find time window from elaboration xml   
    IDxml.InverseDynamicsTool.time_range =  IKXml.InverseKinematicsTool.time_range;
    % coordinates file
    cd(IKXml.InverseKinematicsTool.results_directory)
    copyfile(IKXml.InverseKinematicsTool.output_motion_file,DirIDResults)
    IDxml.InverseDynamicsTool.coordinates_file = IKXml.InverseKinematicsTool.output_motion_file;
    % output name
    IDxml.InverseDynamicsTool.output_gen_force_file = ['inverse_dynamics.sto'];
    
    % Model file
    IDxml.InverseDynamicsTool.model_file = OsimModel;
    
    %setup root and InverseKinematicsTool
    root = 'OpenSimDocument';
    
    fileout = ['setup_ID.xml'];
    fileout2 = ['grf.xml'];
    
    % external load xml
    IDxml.InverseDynamicsTool.external_loads_file =  [DirIDResults fp fileout2];
    
    cd(DirIDResults)
    Pref.StructItem = false;
    
    xml_write(fileout, IDxml, root,Pref);
    xml_write(fileout2, GRFxml, root,Pref);
    
    FullPathSetup_ID = [DirIDResults fp fileout];
    
    matlabdir=pwd;
    prefXmlRead.Str2Num = 'never';
    prefXmlWrite.StructItem = false;
    prefXmlWrite.CellItem   = false;
    import org.opensim.modeling.*
    
   
    [~,log_mes] = dos(['id -S ' FullPathSetup_ID],'-echo');
    
     disp([CurrentTrial ' ID Done.']);
end

disp('Inverse dynamics complete')
