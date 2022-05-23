function [ output_args ] = generateRapidAcquisitionFile( c3dDir )
%GENERATERAPIDACQUISITIONFILE Summary of this function goes here
%   Detailed explanation goes here

    addpath('shared');
    fp = getFp();
    motonmspath = getMOtoNMSpath();
    
    Pref.ReadAttr=false;
    
    laboratoryPath = [motonmspath fp 'SetupFiles' fp 'AcquisitionInterface' fp 'Laboratories'];
    laboratoryName = 'GU_Undercroft.xml';
    Laboratory=xml_read([laboratoryPath fp laboratoryName],Pref);
    
    Staff.PersonInCharge='David Lloyd';
    Staff.Operators.Name{1}='Claudio Pizzolato'; %char needed if answer is empty({[]})
    Staff.Operators.Name{2}='David Saxby';    
    Staff.Physiotherapists.Name='None';

    Subject.FirstName=' ';
    Subject.LastName=' ';
    Subject.Code=' ';
    Subject.BirthDate=' ';
    Subject.Age=' ';
    Subject.Weight=' ';
    Subject.Height=' ';
    Subject.FootSize=' ';
    Subject.Pathology=' ';
    
    AcquisitionDate = '0000-00-00';

    VideoFrameRate = 200;
    
    
    markersProtocolPath = [motonmspath fp 'SetupFiles' fp 'AcquisitionInterface' fp 'MarkersProtocols'];
    markersProtocolName = 'GU-RealTime_HAT.xml';
    
    MarkersProtocol=xml_read([markersProtocolPath fp markersProtocolName],Pref);
    
    EMGSystem(1).Name='Cometa';
    EMGSystem(1).Rate=2000;
    EMGSystem(1).NumberOfChannels=16;
    
    EMGsProtocolPath = [motonmspath fp 'SetupFiles' fp 'AcquisitionInterface' fp 'EMGsProtocols'];
    EMGsProtocolName = 'GU-16muscles-real-time-bug.xml';
   
    EMGsProtocol=xml_read([EMGsProtocolPath fp EMGsProtocolName],Pref);
    cwd = pwd;
    cd([motonmspath fp 'src' fp 'AcquisitionInterface' fp 'private']);
    for j=1:length(EMGsProtocol.MuscleList.Muscle)
        MuscleList{j}=EMGsProtocol.MuscleList.Muscle{j};
    end
    
    for i=1:length(MuscleList)
        def_channel=setChannelFromFile(i,MuscleList);
        Channel(i).ID=def_channel{1}; %#ok<*AGROW>
        Channel(i).Muscle=def_channel{2};
        Channel(i).FootSwitch.ID=def_channel{3};
        Channel(i).FootSwitch.Position=def_channel{4}; 
    end
    Channels.Channel=Channel';
    cd(cwd);
    
    c3dFiles = dir ([c3dDir filesep '*.c3d']);


nRep{1}='1';
nRep{2}='2';
nRep{3}='3';
nRep{4}='4';
nRep{5}='5';
nRep{6}='6';
nRep{7}='7';
nRep{8}='8';
nRep{9}='9';
nRep{10}='0';


for k=1:length(c3dFiles)
    
    ind=[];
    %Name correction/check: after standadization it will not be necessary
    trialsName{k} = regexprep(regexprep((regexprep(c3dFiles(k).name, ' ' , '')), '-',''), '.c3d', '');
    
    for i=1:length(nRep)
        c=strfind(trialsName{k},nRep{i});
        ind=[ind c];
    end
    
    %Trials TYPE and REPETITION
    if isempty(ind)==0
        Trial(k).Type=trialsName{k}(1:ind-1);
        Trial(k).RepetitionNumber=trialsName{k}(ind:end);
    else
        Trial(k).Type=trialsName{k};
        Trial(k).RepetitionNumber='';
        warning on
        warning('Filename of input C3D data does not include repetition number. Trials must be named as: trial type (walking, running, fastwalking, etc.) + sequential number. Examples: walking1, fastwalking5, etc. Please, refer to MOtoNMS User Manual.')
    end

    Trial(k).MotionDirection='backward';
    StanceOnFP(1).Forceplatform=1;
    StanceOnFP(1).Leg='Left';
    StanceOnFP(2).Forceplatform=2;
    StanceOnFP(2).Leg='Right';
    Trial(k).StancesOnForcePlatforms.StanceOnFP=StanceOnFP;
    clear StanceOnFP
end

Trials.Trial=Trial;
    

%% -----------------------------------------------------------------------%
%                         ACQUISITION STRUCT                              %
%-------------------------------------------------------------------------%
ATTRIBUTE.xmlns_COLON_xsi='http://www.w3.org/2001/XMLSchema';

acquisition.Laboratory=Laboratory;
acquisition.Staff=Staff;
acquisition.Subject=Subject;
acquisition.AcquisitionDate=AcquisitionDate;
acquisition.VideoFrameRate=VideoFrameRate;
acquisition.MarkersProtocol=MarkersProtocol;
%acquisition.EMGSystems.Number=nEMGSystem;
acquisition.EMGs.Systems.System=EMGSystem;
acquisition.EMGs.Protocol=EMGsProtocol;
acquisition.EMGs.Channels=Channels;
acquisition.Trials=Trials;
acquisition.ATTRIBUTE=ATTRIBUTE;

%% -----------------------------------------------------------------------%
%                     acquisition.xml WRITING                             %
%-------------------------------------------------------------------------%
Pref.StructItem=false;  %to not have arrays of structs with 'item' notation
Pref.ItemName='Muscle';
Pref.CellItem=false;

xml_write([c3dDir filesep 'acquisition.xml'],acquisition,'acquisition',Pref);
end

