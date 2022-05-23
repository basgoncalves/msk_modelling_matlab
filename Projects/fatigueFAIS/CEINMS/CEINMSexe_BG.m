function log_mes = CEINMSexe_BG (Dir,CEINMSSettings,trialName,A,B,G)

fp = filesep;
fileSetupCeinms = [Dir.CEINMSsetup fp trialName '.xml'];
[~,Subject] = DirUp(Dir.Input,2);
[Dir,~,SubjectInfo,~] = getdirFAI(Subject);

%% set up xmls
SetupXML = xml_read (fileSetupCeinms);
ExeCfgXML = xml_read (CEINMSSettings.exeCfg);

prefXmlWrite.StructItem = false; prefXmlWrite.CellItem = false; % allow arrays of structs to use 'item' notation

Iteration = sprintf('A%.f%sB%.f%sG%.f',A,fp,B,fp,G);
results_directory = [Dir.CEINMSsimulations fp trialName fp Iteration];
if~exist(results_directory);mkdir(results_directory);end
if A==1 && B==2 && G == 0
    SetupXML.excitationGeneratorFile = relativepath(CEINMSSettings.excitationGeneratorFilenameStaicOpt,Dir.CEINMSsetup);
else
    SetupXML.excitationGeneratorFile = relativepath(CEINMSSettings.excitationGeneratorFilename,Dir.CEINMSsetup);
end
%                  results_directory = [Dir.CEINMSsimulations fp trialList{k}];
SetupXML.outputDirectory = relativepath(results_directory,Dir.CEINMSsetup);
xml_write(fileSetupCeinms, SetupXML, 'ceinms', prefXmlWrite);

ExeCfgXML.NMSmodel.activation.exponential = struct;
ExeCfgXML.NMSmodel.type.hybrid.alpha = A;
ExeCfgXML.NMSmodel.type.hybrid.beta = B;
ExeCfgXML.NMSmodel.type.hybrid.gamma = G;
ExeCfgXML.NMSmodel.type.hybrid.dofSet = CEINMSSettings.dofList;
xml_write(CEINMSSettings.exeCfg, ExeCfgXML, 'execution', prefXmlWrite);

%% run CEINMS exe
command=[Dir.CEINMSexePath fp 'CEINMS -S ' fileSetupCeinms];
cd(results_directory)
fprintf('CEINMS execution for %s A%.f_B%.f_G%.f ...\n',trialName,A,B,G)
[~,log_mes]= dos(command);

% check if adjustem EMGs, Contact forces, Muscle forces and pennation angle were calculated
act = importdata([results_directory fp 'AdjustedEmgs.sto']);
CF = importdata([results_directory fp 'ContactForces.sto']);
MF = importdata([results_directory fp 'MuscleForces.sto']);
PA = importdata([results_directory fp 'PennationAngles.sto']);

% if not run execution until they are(some bug with CEINMS)
while isempty(act)||isempty(CF)||isempty(MF)||isempty(PA)
    cmdmsg(sprintf('re-running CEINMS execution for %s A%.f_B%.f_G%.f ...',trialName,A,B,G))
    [~,log_mes]= dos(command);
    act = importdata([results_directory fp 'AdjustedEmgs.sto']);
    CF = importdata([results_directory fp 'ContactForces.sto']);
    MF = importdata([results_directory fp 'MuscleForces.sto']);
    PA = importdata([results_directory fp 'PennationAngles.sto']);
end

%% Moment and EMG errors
load(Dir.ErrorsCEINMS)               % load variables to store R2 and RMSE for moments and excitations
OS = getosimfilesFAI(Dir,trialName); % get directories of files in the FAIS running project
DofMuscles = CEINMSSettings.vars.DOFmuscles;
[rmse,r2, ~] = CEINMS_errors(OS.emg,OS.IDresults,results_directory,CEINMSSettings.excitationGeneratorFilename,CEINMSSettings.exeCfg,DofMuscles);
ConvetedTrialName = getstrials({trialName},SubjectInfo.TestedLeg);ConvetedTrialName=ConvetedTrialName{1};
dof = fields(DofMuscles);
dofsimple = CEINMSSettings.vars.dofsimple;

if ~ischar(A)
    A= ['A' num2str(A)];
    B= ['B' num2str(B)];
    G= ['G' num2str(G)];
end

for d = 1:length(dofsimple)
    for m = 1:length(DofMuscles.(dof{d}))
        currentDof= dofsimple{d};
        Muscle = DofMuscles.(dof{d}){m}(1:end-2); % remove last two letters (i.e. "_r" or "_l")
        try R2.moments.(ConvetedTrialName).(currentDof).(A).(B);  % if error variables do not have current Interation (e.g. A1_B1_G1)
        catch
            R2.moments.(ConvetedTrialName).(currentDof).(A).(B) = table;
            RMSE.moments.(ConvetedTrialName).(currentDof).(A).(B) = table;
        end
            
        try R2.excitations.(ConvetedTrialName).(Muscle).(A).(B);  % if error variables do not have current Interation (e.g. A1_B1_G1)
        catch
            R2.excitations.(ConvetedTrialName).(Muscle).(A).(B) = table;
            RMSE.excitations.(ConvetedTrialName).(Muscle).(A).(B) = table;
        end        
        
        R2.moments.(ConvetedTrialName).(currentDof).(A).(B).(G)(SubjectInfo.Row) = r2.mom.(dof{d});             % update moments
        RMSE.moments.(ConvetedTrialName).(currentDof).(A).(B).(G)(SubjectInfo.Row) = rmse.mom.(dof{d});
        
        R2.excitations.(ConvetedTrialName).(Muscle).(A).(B).(G)(SubjectInfo.Row) = r2.exc.(dof{d})(m);          % update excitations (for each muscle)
        RMSE.excitations.(ConvetedTrialName).(Muscle).(A).(B).(G)(SubjectInfo.Row) = rmse.exc.(dof{d})(m);
        
        %sort tables by column headings (alphanumerically)
        R2.moments.(ConvetedTrialName).(currentDof).(A).(B) = natsorttable(R2.moments.(ConvetedTrialName).(currentDof).(A).(B));
        RMSE.moments.(ConvetedTrialName).(currentDof).(A).(B) = natsorttable(RMSE.moments.(ConvetedTrialName).(currentDof).(A).(B));
        R2.excitations.(ConvetedTrialName).(Muscle).(A).(B) = natsorttable(R2.excitations.(ConvetedTrialName).(Muscle).(A).(B));
        RMSE.excitations.(ConvetedTrialName).(Muscle).(A).(B) = natsorttable(RMSE.excitations.(ConvetedTrialName).(Muscle).(A).(B));
    end 
end

save(Dir.ErrorsCEINMS, 'R2','RMSE')