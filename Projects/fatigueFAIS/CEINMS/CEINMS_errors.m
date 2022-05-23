
% DOFmuscles = struct with muscles per DoF
function [RMSE,R2,FullData] = CEINMS_errors(emg,ID,CEINMSdir,excitationGeneratorFilename,exeCfg,DOFmuscles)

fp = filesep;

EMGdata = importdata(emg);
AdjEMGdata = importdata([CEINMSdir fp 'AdjustedEmgs.sto']);

TimeWindow = [AdjEMGdata.data(1,1) AdjEMGdata.data(end,1)];

exctGern = xml_read(excitationGeneratorFilename);
exeCFG = xml_read(exeCfg);
synthMTUs = split(exeCFG.NMSmodel.type.hybrid.synthMTUs,' ');

dofList =  split(exeCFG.NMSmodel.type.hybrid.dofSet ,' ')';
MusclesOfInterest = {};
for i=1:length(dofList)
    MusclesOfInterest =  unique([MusclesOfInterest DOFmuscles.(dofList{i})]);
end

inputEMG = struct;
for m = 1:length(exctGern.mapping.excitation)
    muscle = exctGern.mapping.excitation(m).ATTRIBUTE.id;
    if sum(contains(synthMTUs,muscle))>0
        continue
    end
    if contains(muscle,MusclesOfInterest) && ~isempty(exctGern.mapping.excitation(m).input)
        inputEMG.(muscle) = char;
        for i = 1:length(exctGern.mapping.excitation(m).input)
            inputEMG.(muscle) = [inputEMG.(muscle) ' ' exctGern.mapping.excitation(m).input(i).CONTENT];
        end
    end
end

RMSE = struct; RMSE.exc =struct; RMSE.mom =struct; RMSE.excPerRange =struct; RMSE.momPerRange =struct;
R2=struct;R2.exc = struct; R2.mom = struct;
FullData=struct; FullData.exc=struct; FullData.mom=struct;

%% Errors EMG
RecordedEMGNames = EMGdata.colheaders(2:end);
[MeasuredEMG,~] = LoadResults_BG (emg,TimeWindow,RecordedEMGNames,1);
dofList_all = [dofList 'All'];
DOFmuscles.All = MusclesOfInterest;
for d = 1:length(dofList_all)
    currentDof = dofList_all{d};
    RMSE.exc.(currentDof) = []; RMSE.excPerRange.(currentDof) = [];
    R2.exc.(currentDof) = [];
    FullData.exc.(currentDof).measured=[]; FullData.exc.(currentDof).estimated=[]; FullData.muscles.(currentDof) ={};
    
    [AdjEMG,MusclesDOF] = LoadResults_BG ([CEINMSdir fp 'AdjustedEmgs.sto'],TimeWindow,DOFmuscles.(currentDof),0);
    for pos = 1:length(MusclesDOF)
        currentAdjEMG = AdjEMG(:,pos);
        if isfield(inputEMG,MusclesDOF{pos})
            EMGnames = split(inputEMG.(MusclesDOF{pos}),' ')'; idx =[];
            
            for i = 1:length(EMGnames); idx = [idx find(strcmp(strtrim(RecordedEMGNames),EMGnames(i)))]; end
            currentMeasuredEMG = mean(MeasuredEMG(:,idx),2);
            rmse = round(rms(currentMeasuredEMG-currentAdjEMG),3);
            rmseRange = rmse/range(currentMeasuredEMG);
            [r, ~] = corrcoef(currentMeasuredEMG,currentAdjEMG); r2=round(r(1,2)^2,3);
        else
            currentMeasuredEMG=NaN(101,1); rmse=NaN; rmseRange=NaN; r2=NaN;
        end
            FullData.exc.(currentDof).measured(:,end+1)=currentMeasuredEMG;
            FullData.exc.(currentDof).estimated(:,end+1)=currentAdjEMG;
            FullData.muscles.(currentDof){end+1} =MusclesDOF{pos};
            RMSE.exc.(currentDof)(end+1) = rmse;
            RMSE.excPerRange.(currentDof)(end+1) = rmseRange;
            R2.exc.(currentDof)(end+1) = r2;
    end
end

%% Error moments
[ID_os,~] = LoadResults_BG (ID,TimeWindow,strcat(dofList,'_moment'),1);
[ID_CEINMS,~] = LoadResults_BG ([CEINMSdir fp 'Torques.sto'],TimeWindow,dofList,1);

for d = 1:length(dofList)
    currentDof = dofList{d};
    MeasuredMom=ID_os(:,d); EstimatedMom=ID_CEINMS(:,d);
    
    FullData.mom.(currentDof).measured=MeasuredMom;
    FullData.mom.(currentDof).estimated=EstimatedMom;

    rmse = round(rms(EstimatedMom-MeasuredMom),1);
    RMSE.mom.(currentDof) = rmse;
    RMSE.momPerRange.(currentDof) = rmse/range(MeasuredMom);
    [r, ~] = corrcoef(EstimatedMom,MeasuredMom);
    R2.mom.(currentDof)= round(r(1,2)^2,2);
end

