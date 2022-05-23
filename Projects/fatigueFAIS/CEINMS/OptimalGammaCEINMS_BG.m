% OptimalGamma = OptimalGammaCEINMS_BG(Dir,SimulationsDir,SubjectInfo)

% Compare all iterations of CEINMS exe and check best RMSE with torque
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS (check if they are in the path)
%   GCOS
%   LoadResults_BG
%
%INPUT
%   SimulationsDir = [char] directory of the your ceinms simulations for one trial
%       e.g. = 'E:\3-PhD\Data\MocapData\ElaboratedData\subject\session\ceinms\execution\simulations'
%-------------------------------------------------------------------------
%OUTPUT
%   OptimalGamma
%--------------------------------------------------------------------------
% NOTE - you may need to change the names of the motions and muslces
% written by Basilio Goncalves (2020) - https://www.researchgate.net/profile/Basilio_Goncalves
%% CompareCEINMSIterations
function OptimalSettings = OptimalGammaCEINMS_BG(Dir,SimulationDir,SubjectInfo)

fp = filesep;
if exist([SimulationDir fp 'OptimalSettings.mat'])
    load([SimulationDir fp 'OptimalSettings.mat'])
    
    if ~contains(OptimalSettings.Dir(1:3),Dir.Main(1:3))  % replace the location of the file with the current main dir
        OptimalSettings.Dir(1:3) = Dir.Main(1:3);
    end
    OptimalSettings.Activations = [OptimalSettings.Dir fp 'Activations.sto'];
    OptimalSettings.AdjustedEmgs = [OptimalSettings.Dir fp 'AdjustedEmgs.sto'];
    OptimalSettings.ContactForces = [OptimalSettings.Dir fp 'ContactForces.sto'];
    OptimalSettings.MusclesContribution = [OptimalSettings.Dir fp 'MusclesContribution.sto'];
    OptimalSettings.MuscleForces = [OptimalSettings.Dir fp 'MuscleForces.sto'];
    OptimalSettings.NormFibreLengths = [OptimalSettings.Dir fp 'NormFibreLengths.sto'];
    OptimalSettings.NormFibreVelocities = [OptimalSettings.Dir fp 'NormFibreVelocities.sto'];
    OptimalSettings.NormTendonLengths = [OptimalSettings.Dir fp 'NormTendonLengths.sto'];
    OptimalSettings.PennationAngles = [OptimalSettings.Dir fp 'PennationAngles.sto'];
    OptimalSettings.Torques = [OptimalSettings.Dir fp 'Torques.sto'];
    return
end
%% organise folders and directories
cd(SimulationDir)
[~,trialName]  = fileparts(SimulationDir);
ConvetedTrialName = getstrials({trialName},SubjectInfo.TestedLeg);ConvetedTrialName=ConvetedTrialName{1};

%% define labels
s = lower(SubjectInfo.TestedLeg);
dofList = {['hip_flexion_' s];['knee_angle_' s];['ankle_angle_' s]};
Settings = getOSIMVariablesFAI(SubjectInfo.TestedLeg,Dir.OSIM_LO,dofList);

exctGern = xml_read([Dir.CEINMSexcitationGenerator fp 'excitationGenerator.xml']);
inputEMG = struct;
for m = 1:length(exctGern.mapping.excitation)
    muscle = exctGern.mapping.excitation(m).ATTRIBUTE.id;
    if contains(muscle,Settings.AllMuscles) && ~isempty(exctGern.mapping.excitation(m).input)
        inputEMG.(muscle) = exctGern.mapping.excitation(m).input.CONTENT;
    end
end
Settings.RecordedMuscles = fields(inputEMG);

%%  load ID, IK and measaured EMG
OSfiles = getosimfilesFAI(Dir,trialName); % directories of all the files related to this trial
TrialsXML = xml_read([Dir.CEINMStrials fp trialName '.xml']);
TimeWindow = TrialsXML.startStopTime;
MatchWord = 1; % 1= yes; 0 = no;
[ID_os,~] = LoadResults_BG (OSfiles.IDresults,TimeWindow,Settings.moments,MatchWord);
[MeasuredEMG,~] = LoadResults_BG (OSfiles.emg,TimeWindow,Settings.RecordedEMG,MatchWord);

MeanRangeMom = mean(range(ID_os));
MeanRangeEMG = mean(range(MeasuredEMG));

err = load(Dir.ErrorsCEINMS);
R2exc = err.R2.excitations.(ConvetedTrialName);
RMSEexc = err.RMSE.excitations.(ConvetedTrialName);
R2mom = err.R2.moments.(ConvetedTrialName);
RMSEmom = err.RMSE.moments.(ConvetedTrialName);

muscles = fields(R2exc);
dofs = fields(R2mom);
Alphas = fields(R2exc.(muscles{1}))';
BestRMSE = [];
AlphaBetaGamma = {};
for k = 1:length(Alphas)
    A= Alphas{k};
    Betas = fields(R2exc.(muscles{1}).(A));
    for k = 1:length(Betas)
        B= Betas{k};
        AlphaBetaGamma{end+1,1} = str2double(strrep(A,'A',''));
        AlphaBetaGamma{end,2} = str2double(strrep(B,'B',''));
        Gammas = R2exc.(muscles{1}).(A).(B).Properties.VariableNames;
        Gammas = str2double(strrep(Gammas,'G',''));
        r2exc=[];rmseexc=[];
        r2mom=[];rmsmom=[];
        for k = 1:length(muscles)
            for d = 1:length(dofs)
                M = muscles{k};  D = dofs{d};
                r2mom(d,:) = meantable2array(R2mom.(D).(A).(B),SubjectInfo.Row);
                rmsmom(d,:) = meantable2array(RMSEmom.(D).(A).(B),SubjectInfo.Row);
                r2exc(k,:) = meantable2array(R2exc.(M).(A).(B),SubjectInfo.Row);
                rmseexc(k,:) = meantable2array(RMSEexc.(M).(A).(B),SubjectInfo.Row);
            end
        end
        [AlphaBetaGamma{end,3},BestRMSE(end+1,1)] = PlotErrorCEINMS(r2mom,rmsmom,r2exc,rmseexc,MeanRangeMom,MeanRangeEMG,Gammas,6);
        AB = ['Alpha' num2str(A) ' Beta' num2str(B)];
        suptitle (AB)
        saveas(gcf,[SimulationDir fp AB '_OptimalGamma.jpeg'])
        close all
    end
end

[~,k] = min(BestRMSE);
OptimalSettings.Alpha = AlphaBetaGamma{k,1};
OptimalSettings.Beta = AlphaBetaGamma{k,2};
OptimalSettings.Gamma =  AlphaBetaGamma{k,3};

OptimalSettings.Dir = [Dir.CEINMSsimulations fp trialName fp sprintf('A%.f\\B%.f\\G%.f',OptimalSettings.Alpha,OptimalSettings.Beta,OptimalSettings.Gamma)];
OptimalSettings.Activations = [OptimalSettings.Dir fp 'Activations.sto'];
OptimalSettings.AdjustedEmgs = [OptimalSettings.Dir fp 'AdjustedEmgs.sto'];
OptimalSettings.ContactForces = [OptimalSettings.Dir fp 'ContactForces.sto'];
OptimalSettings.MusclesContribution = [OptimalSettings.Dir fp 'MusclesContribution.sto'];
OptimalSettings.MuscleForces = [OptimalSettings.Dir fp 'MuscleForces.sto'];
OptimalSettings.NormFibreLengths = [OptimalSettings.Dir fp 'NormFibreLengths.sto'];
OptimalSettings.NormFibreVelocities = [OptimalSettings.Dir fp 'NormFibreVelocities.sto'];
OptimalSettings.NormTendonLengths = [OptimalSettings.Dir fp 'NormTendonLengths.sto'];
OptimalSettings.PennationAngles = [OptimalSettings.Dir fp 'PennationAngles.sto'];
OptimalSettings.Torques = [OptimalSettings.Dir fp 'Torques.sto'];

% save results
cd(SimulationDir)
save OptimalSettings OptimalSettings AlphaBetaGamma BestRMSE
close all

    function out=meantable2array(in,row)
        double = table2array(in); double(double==0) = NaN;
        
        try out = nanmean(double(row,:),1);
        catch
            out = NaN;
        end
    end


end
