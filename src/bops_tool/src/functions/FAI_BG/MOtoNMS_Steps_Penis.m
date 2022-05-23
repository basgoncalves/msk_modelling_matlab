% Basilio Goncalves (2020)
% To be used under fatigueFAIS pipeline
%
% No copyright 

%% MOtoNMS_Steps_Penis

%Aquisition
DynamicTrials = {'Walk' 'staticCalibration'};
cd(DirMocap)
if exist('oldAcquisitionFilePath')==0 || ~contains(class(oldAcquisitionFilePath),'char')
    [oldAcquisitionFileName,oldAcquisitionFilePath] = uigetfile([ filesep '*.xml'],'Select acquisition.xml file to load', pwd);
end

%choose scale template xml
if exist('setupScaleName')==0 || ~contains(class(setupScaleName),'char')
    [setupScaleName,oldScaleSetupPath] = uigetfile...
        ([DirMocap filesep '*.xml'],'Select setup_scale.xml file to load');
end

% %rename trials and replace c3d name 
% RenameTrials (DirC3D,['FAS_' Subject], '*.c3d');

%remove eg. 0 form 01 etc...
StringToRemove={};
for ii = 1:9
    StringToRemove{ii} = sprintf('0%d',ii);
end
strNOTToRemove={};
for ii = 1:9
    strNOTToRemove{ii} = sprintf('%d0',ii);
end

RenameTrials_condition(DirC3D, StringToRemove,strNOTToRemove,'*.c3d')

oldAcquisition=xml_read([oldAcquisitionFilePath filesep oldAcquisitionFileName]);
AcquisitionInterface_TG(oldAcquisition,SubjectsDemogr,labelsDemographics,DirC3D,DynamicTrials);

% C3D3MAT
PathName= DirC3D;
cd ([DirMOtoNMS, filesep,'src',filesep,'C3D2MAT_btk']);
C3D2MAT_BG(PathName)

disp ('C3D2MAT completed');
% Dynamic Elaboration
% ElaboratedData> SubjectXX > date > dynamicElaborations >
% - Elaboration.xml
DynamicElaborationsSetup_TG

% Static Elaboration
StaticElaborationSetup_BG

% Set up scale file
ScaleSetup_TG
