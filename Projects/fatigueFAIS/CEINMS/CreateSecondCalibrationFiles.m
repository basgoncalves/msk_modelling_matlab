
function CEINMSSettings = CreateSecondCalibrationFiles(Dir,CEINMSSettings,SubjectInfo,SimulationDir)
fp = filesep;

[~,trialName] = DirUp(SimulationDir,1);

dofList = split(CEINMSSettings.dofList ,' ')';
Settings = getOSIMVariablesFAI(SubjectInfo.TestedLeg,CEINMSSettings.osimModelFilename,dofList);

exctGern = xml_read([Dir.CEINMSexcitationGenerator fp 'excitationGenerator.xml']);
inputEMG = struct;
for m = 1:length(exctGern.mapping.excitation)
    muscle = exctGern.mapping.excitation(m).ATTRIBUTE.id;
    if contains(muscle,Settings.AllMuscles) && ~isempty(exctGern.mapping.excitation(m).input)
       inputEMG.(muscle) = exctGern.mapping.excitation(m).input.CONTENT;
    end
end
Settings.RecordedMuscles = fields(inputEMG);

load([Dir.sessionData fp 'Rates.mat'])
% TimeWindow = TimeWindow_FatFAIS(Dir,trialName); cd(SimulationDir);
if ~exist([SimulationDir fp 'OptimalGamma.mat'])
    OptimalGamma = OptimalGammaCEINMS_BG(Dir,SimulationDir,SubjectInfo);
 
    CEINMSexe_BG (Dir,CEINMSSettings,trialName,...
        OptimalGamma.Alpha,OptimalGamma.Beta,OptimalGamma.Gamma_MinDiff);
else
    load([SimulationDir fp 'OptimalGamma.mat'])
end
BestItrDir = OptimalGamma.DirSum;


%% create a new EMG mot file
MeasuredEMG = load_sto_file([Dir.dynamicElaborations fp trialName fp 'emg.mot']);
AdjustedEMG = load_sto_file([BestItrDir fp 'AdjustedEmgs.sto']);
MuscleNames = Settings.AllMuscles;
for k = 1:length(MuscleNames)
    
    if contains(MuscleNames{k},Settings.RecordedMuscles) || ...
            ~contains(MuscleNames{k},fields(AdjustedEMG))
        continue
    else
        
        TimeCEINMS = AdjustedEMG.time; TimeAnalog=MeasuredEMG.time;
        MuscleEMG = AdjustedEMG.(MuscleNames{k});
        rows = [find(TimeAnalog==TimeCEINMS(1,1)):find(TimeAnalog==TimeCEINMS(end,1))];
        InterpEMG = interp1(TimeCEINMS,MuscleEMG,TimeCEINMS(1):1/Rates.AnalogFrameRate:TimeCEINMS(end));
        
        current_muscle = strrep(MuscleNames{k},['_' lower(SubjectInfo.TestedLeg)],'');
        MeasuredEMG.(current_muscle) = zeros(length(TimeAnalog),1);
        MeasuredEMG.(current_muscle)(rows,1) = InterpEMG;
        for input = 1:length({exctGern.mapping.excitation.ATTRIBUTE})
            if contains(exctGern.mapping.excitation(input).ATTRIBUTE.id,MuscleNames{k})
                exctGern.mapping.excitation(input).input.CONTENT = current_muscle;
                exctGern.mapping.excitation(input).input.ATTRIBUTE = struct;
                exctGern.mapping.excitation(input).input.ATTRIBUTE.weight = '1';
            end
        end
    end
end
inputSignals=char;
EMGsLabels = fields(MeasuredEMG)';
time = MeasuredEMG.time;
EMGsLabels(1)=[];
for m = 1:length(EMGsLabels)
    inputSignals = [inputSignals EMGsLabels{m} ' '];
end
exctGern.inputSignals.CONTENT = inputSignals;

for m = 1:length(EMGsLabels)
    EMGsData(:,m)= MeasuredEMG.(EMGsLabels{m});
end

newEMGsto = [Dir.dynamicElaborations fp trialName fp 'emg_2ndcal.mot'];
folder = [Dir.dynamicElaborations fp trialName ]; 
printEMGmot(folder,time,EMGsData,EMGsLabels, '_2ndcal.mot')

%% New excitation generations xml
newExcGenFile = CEINMSSettings.excitationGeneratorFilename2ndCal;
xml_write(newExcGenFile, exctGern, 'excitationGenerator');

%% new trials xml 
XML = xml_read([Dir.CEINMStrials fp trialName '.xml']);
XML.excitationsFile = relativepath(newEMGsto,DirUp(newExcGenFile,1));
XML.startStopTime = num2str(XML.startStopTime);
newXMLfile = [Dir.CEINMStrials fp trialName '_2ndcal.xml'];
xml_write(newXMLfile, XML,'inputData');

