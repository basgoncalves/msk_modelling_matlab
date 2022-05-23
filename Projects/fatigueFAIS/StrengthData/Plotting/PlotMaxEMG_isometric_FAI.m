%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Plot data for each muscle group with mean EMG 
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS
%   E:\MATLAB\DataProcessing-master\src\emgProcessing\Functions
%   ImportEMGc3d
%   GetMaxForce
%INPUT
%   strengthDir
%-------------------------------------------------------------------------
%OUTPUT
%   MaxTrials = cell matrix maximum Force value
%--------------------------------------------------------------------------

%% PlotMaxEMG_isometric_FAI

close all
 
% mean EMG pre - select folders
cd(SubjFolder)
prompt = sprintf('select all subject folders with EMG analysed');
[Subjects] = uigetmultiple(DirInput,prompt);
Nsubjects = length (Subjects);

DiC3D = [Subjects{1} filesep SessionFolder];
OrganiseFAI

DirInput = Subjects{1}(1:end-4);
cd(DirMocap)

cd(DirInput)
EMGAnalysied = checkFileExists ('maxEMG.mat',Subjects);
% delete subjects without EMG analysed
% DeleteSubjects = ~contains (Subjects,EMGAnalysied);
% Subjects(DeleteSubjects)= [];
Nsubjects = length (Subjects);

%% Plot EMGs 
muscles = {'VM','VL','RF','GRA','TA','AL','ST','BF','MG','LG','TFL','Gmax','Gmed','PIR','OI','QF'};

muscleGroups = {'VM','VL','RF'};                        % Knee extensors
muscleGroups(end+1,1:2)={'ST','BF'};                    % Knee flexors
muscleGroups(end+1,1:2)={'Gmax','TFL'};                 % Hip abductors
muscleGroups(end+1,1:2)={'AL','GRA'};                   % Hip adductors
muscleGroups(end+1,1:3)={'Gmax','ST','BF'};             % Hip extensors
muscleGroups(end+1,1:2)={'RF','TFL'};                   % Hip flexors
muscleGroups(end+1,1:4)={'Gmed','Pir','OI','QF'};       % Deep hip muscles

EMGTrials = {'KE';'KF';'HAB';'HAD';'HE';'HF';'HE'};

SaveName = {'EMG_kneeExtensors.jpeg'};
SaveName(end+1,1) = {'EMG_kneeFlexors.jpeg'};
SaveName(end+1,1) = {'EMG_hipAbductors.jpeg'};
SaveName(end+1,1) = {'EMG_hipAdductors.jpeg'};
SaveName(end+1,1) = {'EMG_hipExtensors.jpeg'};
SaveName(end+1,1) = {'EMG_hipFlexors.jpeg'};
SaveName(end+1,1) = {'EMG_hipDeep.jpeg'};


for mm = 1:size(muscleGroups,1)
    
    idxNonEmpty = find(~cellfun(@isempty,muscleGroups(mm,:)));
    plotMuscles = find(contains (muscles,muscleGroups(mm,idxNonEmpty)));
    
    MaxEMGTrial = EMGTrials{mm};
    
    plotMeanEMG_FAI
    
    DirResults = ([DirResults filesep 'HipIsometric']);
    mkdir(DirResults)
    cd(DirResults);
    saveas(gcf, SaveName{mm,:})
end


