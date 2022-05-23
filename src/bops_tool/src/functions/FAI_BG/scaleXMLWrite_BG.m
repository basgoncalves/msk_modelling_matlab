%% scaleXMLWrite_BG(Dir,Temp,SubjectInfo,Trials) by Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% This function will create a Setup_Scale.xml file for use with OpenSIM
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS (check if they are in the path)
%   xml_read
%   xml_write
%% Start function
function [Scale, setup_scale_file] = scaleXMLWrite_BG(Dir,Temp,SubjectInfo,Trials)
fp = filesep;

Scale = xml_read(Temp.ScaleTool);
ScalePath = Dir.Scale;
setup_scale_file = [ScalePath fp 'Setup_Scale.xml'];

StaticTRCfile = [Dir.staticElaborations fp Trials.Static{1} '.trc'];
TRC = load_trc_file(StaticTRCfile);
% determine subject subject demographics
Scale.ScaleTool.mass = SubjectInfo.Weight;
Scale.ScaleTool.height = SubjectInfo.Height*10;
Scale.ScaleTool.age = SubjectInfo.Age;

%% static trial parameters

Scale.ATTRIBUTE.Version = '30000';
Scale.ScaleTool.ATTRIBUTE.name = SubjectInfo.ID;
Scale.ScaleTool.GenericModelMaker.ATTRIBUTE.name = '';
if contains(SubjectInfo.ID,'030')
    Scale.ScaleTool.GenericModelMaker.model_file = relativepath(strrep(Temp.Model,'.osim','_030.osim'),ScalePath);
elseif contains(SubjectInfo.ID,'077')
    Scale.ScaleTool.GenericModelMaker.model_file = relativepath(strrep(Temp.Model,'.osim','_077.osim'),ScalePath);    
else
    Scale.ScaleTool.GenericModelMaker.model_file = relativepath(Temp.Model,ScalePath);
end
Scale.ScaleTool.ModelScaler.ATTRIBUTE.name = '';
Scale.ScaleTool.ModelScaler.marker_file = relativepath(StaticTRCfile,ScalePath);
Scale.ScaleTool.ModelScaler.time_range = [TRC.Time TRC.Time];
Scale.ScaleTool.ModelScaler.output_scale_file = relativepath([Dir.Scale fp 'Scale_output.xml'],ScalePath);
Scale.ScaleTool.ModelScaler.output_scale_file = relativepath([Dir.Scale fp 'Scale_output.xml'],ScalePath);
% 
Scale.ScaleTool.MarkerPlacer.output_motion_file = relativepath([Dir.staticElaborations fp 'static_output.mot'],ScalePath);
Scale.ScaleTool.MarkerPlacer.output_marker_file = relativepath([Dir.staticElaborations fp 'static_output.trc'],ScalePath);
% Scale.ScaleTool.MarkerPlacer.output_motion_file = struct;
% Scale.ScaleTool.MarkerPlacer.output_marker_file = struct;
Scale.ScaleTool.MarkerPlacer.output_model_file = relativepath([Dir.OSIM_LinearScaled],ScalePath);
Scale.ScaleTool.MarkerPlacer.marker_file = relativepath(StaticTRCfile,ScalePath); 
Scale.ScaleTool.MarkerPlacer.time_range = [TRC.Time TRC.Time];

Scale.ScaleTool.COMMENT=[];
Scale.ScaleTool.MarkerPlacer.COMMENT=[];
Scale.ScaleTool.GenericModelMaker.COMMENT=[];
Scale.ScaleTool.ModelScaler.COMMENT=[];
Nmeasurments = length([Scale.ScaleTool.ModelScaler.MeasurementSet.objects.Measurement]);
for n=1:Nmeasurments
    Scale.ScaleTool.ModelScaler.MeasurementSet.objects.Measurement(n).COMMENT=[]; 
    
    Npairs = length([Scale.ScaleTool.ModelScaler.MeasurementSet.objects.Measurement(n).MarkerPairSet.objects.MarkerPair]);
    for n2=1:Npairs
        Scale.ScaleTool.ModelScaler.MeasurementSet.objects.Measurement(n).MarkerPairSet.objects.MarkerPair(n2).COMMENT=[];
    end
end

root = 'OpenSimDocument';
Pref = struct;
Pref.StructItem = false;
xml_write([Dir.Scale fp 'Setup_Scale.xml'], Scale, root,Pref);
cd(ScalePath)
        