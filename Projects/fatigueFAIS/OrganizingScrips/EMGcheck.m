% use after running "InspectEMG_Running.m"
%
% check assign the a value of Good, average or bad to each EMG trial
% (manually) and make the bad trials = 0 in the sessionData folder (not
% to be used when estimating max EMG


function EMGcheck(DirMocap,Subject,trialList)

fp = filesep;
cd(DirMocap)
demographics = importParticipantData('ParticipantData and Labelling.xlsx', 'Demographics');
SubjectCodes = demographics(:,1);
DirC3D = [DirMocap fp 'InputData' fp Subject fp 'pre'];
DirElaborated = [DirMocap fp 'ElaboratedData' fp Subject fp 'pre'];

muscleString = {'        VM','        VL','        RF','       GRA',...
    '        TA','   ADDLONG','   SEMIMEM','      BFLH','        GM',...
    '        GL','       TFL','   GLUTMAX','   GLUTMED','      PIRI','    OBTINT','    QF'}; % the spaces are part of the name
f = checkEMGdata_simple (DirC3D,muscleString,trialList); %single participant
uiwait(f)

%% make bad trials = 0
% load ([DirC3D fp 'BadTrials.mat'])
% 
% ChannelNames = {'Voltage.1-VM';'Voltage.2-VL';'Voltage.3-RF';'Voltage.4-GRA';
%     'Voltage.5-TA';'Voltage.6-AL';'Voltage.7-ST';'Voltage.8-BF';'Voltage.9-MG';...
%     'Voltage.10-LG';'Voltage.11-TFL';'Voltage.12-Gmax';'Voltage.13-Gmed-intra';...
%     'Voltage.14-PIR-intra';'Voltage.15-OI-intra';'Voltage.16-QF-intra';};
% 
% cmdmsg(['Deleting bad trials from "sessionData"' Subject '...'])
% BadTrials = cell2mat(BadTrials);
% for col = 1:length(trialNames)
%     cd([DirElaborated fp 'sessionData'])
%     cd(strrep(trialNames{col},'.c3d',''))
%     load('AnalogData.mat')
%     for row = 1:length(ChannelNames)
%        if BadTrials(row,col) == 2
%            idx = find(contains(AnalogData.Labels,ChannelNames(row)));
%            AnalogData.RawData(:,idx)= 0;
%        end
%     end
%     save AnalogData AnalogData
% end
% 
% cmdmsg('bad trials from deleted ')
% 
% %% Rerun Elabration to get max EMG
% 
