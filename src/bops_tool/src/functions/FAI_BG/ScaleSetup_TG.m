% Scale Setup FAI project
% Basilio Goncalves 2019 

if exist('DirMocap')==0 && exist('demographics')==0
    OrganiseFAI
end
cd  ([DirMOtoNMS filesep 'src' filesep 'StaticElaboration']);

ScalePath = ([DirElaborated,filesep, 'Scale']);
mkdir (ScalePath);

if exist('setupScaleName')==0 || ~contains(class(setupScaleName),'char')
    [setupScaleName,oldScaleSetupPath] = uigetfile...
        ([DirMocap filesep '*.xml'],'Select setup_scale.xml file to load');
end

%get data from the static .c3d file
staticXML = xml_read([StaticElaborationFilePath filesep 'static.xml']);
staticName = staticXML.TrialName;
data = btk_loadc3d([DirC3D filesep staticName '.c3d']);
[a,b,c]=fileparts(data.sub_info.Filename);

%change the name of the TRC file to matach location of the static .TRC
data.TRC_Filename = ([DirElaborated filesep 'staticElaborations' filesep b '.trc']);  

% location of the Model 
ModelName = 'FAI_linearScaled';
ModelFile = ([DirMocap filesep ModelName '.osim']);

% info fro, the old setupScale file (create a basic one for each project
% and go from there)
oldScaleSetup = xml_read([DirMocap , filesep, setupScaleName]);

OutputModelFile = [DirElaborated filesep ModelName Subject '.osim'];

% Edit the old Scale .xml based based on subject demographics data  
[Scale,setup_scale_file]  = scaleXMLWrite_BG(oldScaleSetup,ModelFile,SubjectsDemogr,labelsDemographics,ScalePath,OutputModelFile,data);

disp('Scale xml complete')

% scale model (dir = E:\MATLAB\DataProcessing-master\src\matlabOpenSimPipeline_LS

[ newModel ] = scale_osim (setup_scale_file);
disp('Model Scaled')
