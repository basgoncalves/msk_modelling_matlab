% Scale Setup FAI project
% Basilio Goncalves 2019 
fp = filesep;

if exist('DirMocap')==0 && exist('demographics')==0
    OrganiseFAI
end

ScalePath = ([DirElaborated,filesep, 'Scale']);
mkdir (ScalePath);

if exist('TemplateScaleXMl')==0 || exist(TemplateScaleXMl)~=2
    [setupScaleName,oldScaleSetupPath] = uigetfile...
        ([DirMocap filesep '*.xml'],'Select setup_scale.xml file to load');
     TemplateScaleXMl = [oldScaleSetupPath setupScaleName];
end

%get data from the static .c3d file
staticXML = xml_read([StaticElaborationFilePath filesep 'static.xml']);
staticName = staticXML.TrialName;
data = btk_c3d2trc([DirC3D filesep staticName '.c3d']);
[a,b,c]=fileparts(data.TRC_Filename);

%change the name of the TRC file to matach location of the static .TRC
data.TRC_Filename = ([DirElaborated filesep 'staticElaborations' filesep b c]);  

% info fro, the old setupScale file (create a basic one for each project
% and go from there)
oldScaleSetup = xml_read(TemplateScaleXMl);

OutputModelFile = [DirElaborated fp Subject '_' ModelName];

% Edit the old Scale .xml based based on subject demographics data  
[Scale,setupScaleXML]  = scaleXMLWrite_BG(oldScaleSetup,DirTemplateModel,SubjectsDemogr,labelsDemographics,ScalePath,OutputModelFile,data);

disp('Scale xml complete')

cd(fileparts(setupScaleXML))
[~,log_mes] = dos(['scale -S ' setupScaleXML],'-echo');
    
movefile(['out.log'],[DirElaborated fp 'staticElaborations'])
movefile(['err.log'],[DirElaborated fp 'staticElaborations'])

[TSE,RMSE,MaxError] = plotMarkerErrStatic([DirElaborated fp 'staticElaborations' fp 'out.log']);

disp('Model Scaled')
