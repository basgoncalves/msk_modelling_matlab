
function MatFile_Muscle_Contributions_to_HCF(PlotData)

if nargin < 1
    PlotData = false;
elseif ~islogical(PlotData)
    error('plot data must be a logical value (true or false)')
end

trials_of_interest = {'RunStraight1','RunStraight2'};                                                               % trials of interest

saveDir = check_existing_mat_file;                                                                                  % check if want to save a copy of the last mat file for comparisons

[Subjects,contributions2HCF] = create_struct_with_NaNs(trials_of_interest);                                         % create the struct of HCF with all NaNs

for isub = 1:length(Subjects)
    
    currect_subject = Subjects{isub};
    [Dir,~,SubjectInfo,Trials] = getdirFAI(currect_subject);                                                        % load subject directories and other settings
    
    leg = lower(SubjectInfo.TestedLeg);                                                                             % find muscles used in CEINMS
    modelname = Dir.OSIM_LO_HANS_originalMass;
    s = getOSIMVariablesFAI(upper(leg),modelname);
    muscles_of_interest = strcat(s.muscles_of_interest.All,['_' leg]);                                              % select only the muscles from the tested leg
    
    disp(SubjectInfo.ID)
    trialList = Trials.MuscleContributions2HCF;
    trialList = trialList(contains(trialList,Trials.RunStraight));
    
    GenericTrialList = getstrials(trialList,SubjectInfo.TestedLeg);
    
    for iTrial = 1:length(trialList)                                                                                % loop through all the trials
        trialName = trialList{iTrial};
        genericTrialName = GenericTrialList{iTrial};
        
        if ~contains(genericTrialName,trials_of_interest)
            continue
        end
        
        [trialDirs] = getosimfilesFAI(Dir,trialName);                                                               % get directories for all the different pipeline files
        for imusc = 1:length(muscles_of_interest)
            
            muscleName = muscles_of_interest{imusc};
            muscleName_no_Leg = strrep(muscleName,'_r','');                                                         % remove "_r" and "_l" from muscle name
            muscleName_no_Leg = strrep(muscleName_no_Leg,'_l','');
            
            sto_file = [trialDirs.MC fp muscleName '_InOnParentFrame_ReactionLoads.sto'];                           % load sto file
            
            try force_data = load_sto_file(sto_file);
            catch e; disp(e.message)
            end
            
            time_vector = force_data.time;                                                                          % calculate sample frequency
            fs = 1/(time_vector(2,1)-time_vector(1,1));
            
            header_name = ['hip_' leg '_on_pelvis_in_pelvis_f'];
            
            x = TimeNorm(force_data.([header_name 'x']),fs);                                                        % time normalise forces
            y = TimeNorm(force_data.([header_name 'y']),fs);
            z = TimeNorm(force_data.([header_name 'z']),fs);
            resultant = sum3Dvector(x,y,z);
            
            if contains(leg,'l')
                z = -z;
            end
            
            contributions2HCF.hip_x.(muscleName_no_Leg).(genericTrialName)(:,isub) = x;
            contributions2HCF.hip_y.(muscleName_no_Leg).(genericTrialName)(:,isub) = y;
            contributions2HCF.hip_z.(muscleName_no_Leg).(genericTrialName)(:,isub) = z;
            contributions2HCF.hip_resultant.(muscleName_no_Leg).(genericTrialName)(:,isub) = resultant;
        end
    end
end

contributions2HCF = MeanAcrossTrials(contributions2HCF,trials_of_interest);

cd(saveDir)
save MuscleContributions contributions2HCF 

Add_muscle_contributions_to_Paper4_results(contributions2HCF)

if PlotData==true
    Plot_MuscleContributions_Average
end

function saveDir = check_existing_mat_file                                                                          % check if want to save a copy of the last mat file for comparisons

Dir = getdirFAI;
saveDir = Dir.Results_JCFFAI;
mkdir(saveDir);
cd(saveDir)

cd(saveDir)
if exist('MuscleContributions.mat')
    LocationMatWindow = com.mathworks.mde.desk.MLDesktop.getInstance.getMainFrame.getLocation;
    SizeMatWindow = com.mathworks.mde.desk.MLDesktop.getInstance.getMainFrame.getSize;
    PositionQuest = [LocationMatWindow.x + SizeMatWindow.width/2 , LocationMatWindow.y + SizeMatWindow.height/2];
    
    Question = 'MuscleContributions.mat already exist, do you want to create a backup copy?';
    answer = MFquestdlg(PositionQuest,Question);
    
    if isequal(answer,'Yes')
        time = strrep(datestr(now,'dd:mmm:HH:MM:SS.FFF'),':','_');
        time = strrep(time,'.','_');
        movefile('MuscleContributions.mat',['MuscleContributions_' time '.mat'])
        
        if exist('MuscleContribution_plots','dir')
            movefile('MuscleContribution_plots',['MuscleContribution_plots_' time])
        end
    end
end

function [Subjects,contributions2HCF] = create_struct_with_NaNs(trials_of_interest)

Dir = getdirFAI;
Subjects = dir([Dir.Main fp 'ElaboratedData']);
Subjects = {Subjects.name}';
Subjects(1:2) = [];

osim_variables = getOSIMVariablesFAI;
muscles_of_interest = osim_variables.muscles_of_interest.All;

Ncols = length(Subjects);
Nrows = 101;

contributions2HCF = struct;
for imusc = 1:length(muscles_of_interest)
    for itrial = 1:length(trials_of_interest)
        
        curr_musc = muscles_of_interest{imusc};
        curr_trial = trials_of_interest{itrial};
        
        contributions2HCF.hip_x.(curr_musc).(curr_trial)(1:Nrows,1:Ncols) = NaN;
        contributions2HCF.hip_y.(curr_musc).(curr_trial)(1:Nrows,1:Ncols) = NaN;
        contributions2HCF.hip_z.(curr_musc).(curr_trial)(1:Nrows,1:Ncols) = NaN;
        contributions2HCF.hip_resultant.(curr_musc).(curr_trial)(1:Nrows,1:Ncols) = NaN;
        
    end
end

function Add_muscle_contributions_to_Paper4_results(contributions2HCF)

Dir = getdirFAI;
cd(Dir.Results_JCFFAI)
load('Paper4results.mat')
CEINMSData.MuscleContributions_ap = contributions2HCF.hip_x;
CEINMSData.MuscleContributions_vert = contributions2HCF.hip_y;
CEINMSData.MuscleContributions_ml = contributions2HCF.hip_z;
CEINMSData.MuscleContributions_resultant = contributions2HCF.hip_resultant;

save Paper4results CEINMSData JointWork Error Groups Weights Subjects BestGammaPerTrial ST Demographics
DataDir = [Dir.Results_JCFFAI fp 'Paper4results.mat'];
copyfile(DataDir,[Dir.Paper_JCFFAI fp 'Results']);
cd([Dir.Paper_JCFFAI fp 'Results'])

function contributions2HCF = MeanAcrossTrials(contributions2HCF,trials_of_interest)                                                
components_HCF = fields(contributions2HCF);
trial_types = unique(getTrialType_multiple(trials_of_interest));

for itype = 1:length(trial_types)
    for icomp = 1:length(components_HCF)
        curr_comp = components_HCF{icomp};
        curr_type = trial_types{itype};
        muscleNames = fields(contributions2HCF.(curr_comp));                                                        % loop through HCF components
        
        
        for imuscle = 1:length(muscleNames)
            curr_muscle = muscleNames{imuscle};
            muscle_sruct = contributions2HCF.(curr_comp).(curr_muscle);
            trialList = fields(muscle_sruct);  
            [time_points,N_subj] = size(muscle_sruct.(trialList{1}));
 
            TrialListToAverage = trialList(startsWith(trialList,curr_type));
            data_per_trial_type = [];
            for isub = 1:N_subj               
                
                SumValues = zeros(time_points,1);
                numberOfRecordedTrials = 0;
                for itrial = 1:length(TrialListToAverage)
                    currentTrial_data = muscle_sruct.(TrialListToAverage{itrial})(:,isub);
                    if  ~any(isnan(currentTrial_data))  
                        numberOfRecordedTrials = numberOfRecordedTrials+1;                                          % only count the trials that do not continain all NaNs
                    end
                    SumValues = nansum([SumValues, currentTrial_data],2);
                end
                data_per_trial_type(1:time_points,isub) = SumValues./numberOfRecordedTrials;
                
            end
            contributions2HCF.(curr_comp).(curr_muscle).(['Mean' curr_type]) = data_per_trial_type;
        end
    end
end
