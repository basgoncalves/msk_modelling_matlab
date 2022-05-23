
function RemoveBadEMGfromSessionData(Dir)
fp = filesep;
muscleString = {'        VM','        VL','        RF','       GRA',...
    '        TA','   ADDLONG','   SEMIMEM','      BFLH','        GM',...
    '        GL','       TFL','   GLUTMAX','   GLUTMED','      PIRI','    OBTINT','    QF'}; % the spaces are part of the name

% channels to look for in the c3dfile
ChannelNames = {'Voltage.1-VM';'Voltage.2-VL';'Voltage.3-RF';'Voltage.4-GRA';
    'Voltage.5-TA';'Voltage.6-AL';'Voltage.7-ST';'Voltage.8-BF';'Voltage.9-MG';...
    'Voltage.10-LG';'Voltage.11-TFL';'Voltage.12-Gmax';'Voltage.13_Gmed-intra';...
    'Voltage.14-PIR-intra';'Voltage.15-OI-intra';'Voltage.16-QF-intra';};

cd(Dir.Input)
load ('BadTrials.mat')
BadTrials = cell2mat(BadTrials);
for col = 1:length(trialNames)
    for row = 1:length(ChannelNames)
       cd(Dir.sessionData)
       if BadTrials(row,col) == 2
           cd(strrep(trialNames{col},'.c3d',''))
           load('AnalogData.mat')
           idx = find(contains(AnalogData.Labels,ChannelNames(row)));
           AnalogData.RawData(:,idx)= 0;
           save AnalogData AnalogData
       end
    end
end
