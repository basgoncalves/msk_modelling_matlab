%% scaleXMLWrite_BG(Dir,Temp,SubjectInfo,Trials) by Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% This function will create a Setup_Scale.xml file for use with OpenSIM
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS (check if they are in the path)
%   xml_read
%   xml_write
%% Start function
function [Scale, setup_scale_file] = runBOPS_Scale

bops = load_setup_bops;
subject = load_subject_settings;

Scale               = xml_read(bops.directories.templates.ScaleTool);
ScalePath           = subject.directories.Scale;
setup_scale_file    = [ScalePath fp 'Setup_Scale.xml'];

StaticTRCfile   = [subject.directories.staticElaborations fp 'static_input.trc'];
TRC             = load_trc_file(StaticTRCfile);

SubjectInfo             = subject.subjectInfo;                                                                      % determine subject subject demographics
Scale.ScaleTool.mass    = SubjectInfo.Mass_kg;
Scale.ScaleTool.height  = SubjectInfo.Height_cm*10;
Scale.ScaleTool.age     = SubjectInfo.Age;

% ----------------------------- CHECK MARKERS SCALE TOOL XML -----------------------------------------
trc             = load_trc_file(StaticTRCfile);
trc_markers     = fields(trc);
Measurements    = Scale.ScaleTool.ModelScaler.MeasurementSet.objects.Measurement;
Nmeasuremtns    = length(Measurements);
checkScaleXML   = 0;
pairs_to_check  = {};

for i = 1:Nmeasuremtns                                                                                              % loop through all the body segments to scale    
    iName  = Measurements(i).ATTRIBUTE.name;
    MarkerPair = Measurements(i).MarkerPairSet.objects.MarkerPair;
    NmarkerPairs = length(MarkerPair);
    for i = 1:NmarkerPairs       
        iMarkerNames  = split(MarkerPair(i).markers,' ');        
        if any(~contains(iMarkerNames,trc_markers))
            checkScaleXML = 1;
            pairs_to_check{end+1} = iName;
        end
    end
end

if checkScaleXML == 1                                                                                               % if markers in  current scale tool do not correspond
    msg = ['please check scale tool marker pairs for'];
    for i = 1:length(pairs_to_check)
        msg = [msg sprintf('\n %s',pairs_to_check{i})];
    end
    winopen(bops.directories.templates.ScaleTool);
    msgbox(msg)
    return
end

MarkerSet = Scale.ScaleTool.MarkerPlacer.IKTaskSet.objects.IKMarkerTask;
for i = flip(1:length(MarkerSet))                                                                                   % loop from the last marker so deletes do not affect indexes
    iName = MarkerSet(i).ATTRIBUTE.name;
    if ~contains(trc_markers,iName)
        MarkerSet(i) = [];
    end
end

% -------------------------------------------        define paths
generic_model_file  = relativepath(subject.directories.OSIM_generic,ScalePath);
marker_file         = relativepath(StaticTRCfile,ScalePath);
output_motion_file  = relativepath([subject.directories.staticElaborations fp 'static_output.mot'],ScalePath);
output_marker_file  = relativepath([subject.directories.staticElaborations fp 'static_output.trc'],ScalePath);
time_range          = [TRC.Time TRC.Time];
model_file          = relativepath([subject.directories.OSIM_LinearScaled],ScalePath);
% ------------------------------------------ create scale xml parameters
Scale.ATTRIBUTE.Version         = '30000';
Scale.ScaleTool.ATTRIBUTE.name  = SubjectInfo.ID;

Scale.ScaleTool.GenericModelMaker.ATTRIBUTE.name    = '';                                                           % GenericModelMaker
Scale.ScaleTool.GenericModelMaker.model_file        = generic_model_file;

Scale.ScaleTool.ModelScaler.ATTRIBUTE.name      = '';                                                               % ModelScaler
Scale.ScaleTool.ModelScaler.marker_file         = marker_file;
Scale.ScaleTool.ModelScaler.time_range          = time_range;
Scale.ScaleTool.ModelScaler.output_scale_file   = relativepath(['.' fp 'Scale_output.xml'],ScalePath);

Scale.ScaleTool.MarkerPlacer.output_motion_file = output_motion_file;                                               % MarkerPlacer
Scale.ScaleTool.MarkerPlacer.output_model_file  = model_file;
Scale.ScaleTool.MarkerPlacer.output_marker_file = output_marker_file;
Scale.ScaleTool.MarkerPlacer.marker_file        = marker_file;
Scale.ScaleTool.MarkerPlacer.IKTaskSet.objects.IKMarkerTask = MarkerSet;
Scale.ScaleTool.MarkerPlacer.time_range         = time_range;

Scale.ScaleTool.COMMENT                     = [];                                                                   % COMMENTS
Scale.ScaleTool.MarkerPlacer.COMMENT        = [];
Scale.ScaleTool.GenericModelMaker.COMMENT   = [];
Scale.ScaleTool.ModelScaler.COMMENT         = [];
Nmeasurments = length([Scale.ScaleTool.ModelScaler.MeasurementSet.objects.Measurement]);                            
for n=1:Nmeasurments
    Scale.ScaleTool.ModelScaler.MeasurementSet.objects.Measurement(n).COMMENT=[];
    Npairs = length([Scale.ScaleTool.ModelScaler.MeasurementSet.objects.Measurement(n).MarkerPairSet.objects.MarkerPair]);
    for n2=1:Npairs
        Scale.ScaleTool.ModelScaler.MeasurementSet.objects.Measurement(n).MarkerPairSet.objects.MarkerPair(n2).COMMENT=[];
    end
end

root = 'OpenSimDocument';                                                                                           % save xml 
Pref = struct;
Pref.StructItem = false;
Pref.CellItem = false;
setupScaleXML = [ScalePath fp 'Setup_Scale.xml'];
Scale = ConvertLogicToString(Scale);
xml_write(setupScaleXML, Scale, root,Pref);
cd(ScalePath)

M=dos(['scale -S ' setupScaleXML],'-echo');                                                                         % run scale tool

cmdmsg('Model Scaled')

% ---------------------------- print errors -------------------------------------
outlog = [subject.directories.Scale fp 'out.log'];
marker_file = Scale.ScaleTool.MarkerPlacer.marker_file;
output_marker_file = Scale.ScaleTool.MarkerPlacer.output_marker_file;

[TSE,RMSE,MaxError] = plotMarkerErrStatic(outlog,setupScaleXML,marker_file,output_marker_file);


function S = ConvertLogicToString(S)                                                                                
%% This function is need so the xml_write does not save values of 'true' as [true] logicals which will cause problems with running the scale tool in OpenSim.

if isstruct(S)                                                                                                      % recursive loop that checks all "apply" fields and changed them to a string
    F = fields(S);
    S = editApplyField(S,F);
    for i = 1:length(F)
        s = S.(F{i});
        for ii = 1:length(s)
            s(ii) = ConvertLogicToString(s(ii));
        end
        S.(F{i}) = s;
    end
    
end

function s = editApplyField(s,f)
%% converts "apply" flieds from [true] / [false] to 'true' / 'false'
if any(contains(f,'apply'))
    
    if s.apply == 1
        s.apply = 'true';
    elseif s.apply == 0
        s.apply = 'false';
    end
    
end
