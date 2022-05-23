%% Notes
for i = 1: length (indivData)
indivData(i).FinalForce = indivData(i).MaxTrial - indivData(i).MeanBaseline; 

end

for i = 1: length (indivData)
indivData(i).FinalForce2 = indivData(i).FinalForce * indivData(i).MomArm; 

end

subject= '016';

if contains(subject,'day1')
    day = 0;
else contains(subject,'day2')
    day = 1;
end


cd(sprintf('E:\\1-FAI\\1-ReliabilityRig\\Testing\\%s_day1',subject))
load ('outputData.mat')
indivData1 = indivData;
MaxTrials_1 = MaxTrials;
cd(sprintf('E:\\1-FAI\\1-ReliabilityRig\\Testing\\%s_day2',subject))
load ('outputData.mat')
indivData2 = indivData;
MaxTrials_2 = MaxTrials;

indData_Manual = indivData;
Max_Manual = MaxTrials;

indData_Manual2 = indivData;
Max_Manual2 = MaxTrials;


folder = dir;
for i=10: 42           %from subject 015_day1 to end
   subjectDir = sprintf('%s\\%s\\ElaboratedData',folder(i).folder,folder(i).name)
   cd(subjectDir);
   mkdir badfiles 
    
end
%% RETEST DATA

% Dir
subjectDir = uigetdir('','Select folder with all subjects');
cd (MainFolder);

if contains(subjectName,'day1')
    day = 0;
else contains(subjectName,'day2')
    day = 1;
end

cd(sprintf('%s\\ElaboratedData\\sessionData',subjectDir));
indivData = dir;
indivData (1:2)=[];

%% delete non Dir
deletedFiles = 0;
for i = 1:length (indivData)
    n = i - deletedFiles;
    if indivData(n).isdir == 0
        indivData(n)=[];
        deletedFiles = deletedFiles +1;
    end
end

%% Check data

for i = 1:length (indivData)
    for ii = 1: length (AnalogData.Labels)                   % loop thorugh the labels of the mat file
        if contains (AnalogData.Labels{ii},'Torque')          % find Torque = Biodex
            idBiodex = ii;
        elseif contains (AnalogData.Labels{ii},'Force')       % find Force = Rig
            idRig = ii;
        end
    end
    
    if startsWith(indivData(i).trial,'B_')
        ForceDataRaw =AnalogData.RawData(:,idBiodex);
    elseif startsWith(indivData(i).trial,'R_')                    % for rig trials
        ForceDataRaw = AnalogData.RawData(:,idRig); 
    end
    
    
end
%% Reanalise
MainFolder = uigetdir('','Select folder with all subjects');
cd (MainFolder);
subjects = dir;
subjects(1:2)=[];
for i = 1:42
    % get the code of the subject
                                                  % get the last backslash, prior to the folder name
    subjectName = subjects(i).name; 
       
    subjectDir = (sprintf('E:\\1-FAI\\1-ReliabilityRig\\Testing\\%s',subjectName));
    ForceRigScript
    
end

%% Normality TestDiff and identify outliers
description = TorqueDataAll.Labels;

for i= 1: 15
    [H, pValueSW, W] = swtest(TestDiff (:,i));
    NormalityDiff (i) = pValueSW;
    [Q,IQR,outliersQ1, outliersQ3] = quartile2(TestDiff (:,i));
    Outliers1{1,i} = description {i};
    Outliers1{2,i} = outliersQ1;
    Outliers1{3,i} = outliersQ3;
end

