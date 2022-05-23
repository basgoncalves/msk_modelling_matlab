

%% THIS FUNCTION IS MEANT TO RUN MULTIPLE TRIALS IN CEINMS TO ALLOW FOR A FASTER EXECUTION

function batchCEINMS_TG (baseDir, trialsDir, trialList, exeSetupDir,CeinmsExeDir,ReRun)

fp = filesep;
if nargin < 1 || ~exist('baseDir')
    baseDir = uigetdir('', 'Select seession folder in elaboratedData folder');
end

DirElaborated = strrep(baseDir,'ElaboratedData','InputData');

% getting number of trials and trial names
if nargin < 2 || ~exist('trialsDir')
    trialsDir = uigetdir('', 'Select "trials" folder in elaboratedData\ceinms folder');
end

% logical to re run trials
if nargin < 5 || ~exist('ReRun')
    ReRun = 1;
end

trials=dir(trialsDir);
j=1;
for k=3:length(trials)
    if (trials(k).isdir==0)
        trList{j}=trials(k).name;
        trID{j} =trList{j}(1:length(trList{j})-4);
        j=j+1;
    end
end
clear j k

% to change the name in the .xml file at each loop and execute on it


for k = 1:length(trList)
    
    results_directory = [fileparts(exeSetupDir) fp 'simulations' fp trList{k}(1:end-4)];
    
    if ~contains(trList{k},trialList)
        continue
    end
    
    if ~exist(results_directory) || ReRun == 1
        
        
        %         % intrapolate data to remove non-linearity arsing from RRA
        %         fprintf(' \n')
        %         fprintf('Adjusting timing of muscle parameters from MA to match emg.mot for %s ... \n', trList{k}(1:end-4))
        %         fprintf(' \n')
        %        % Make the Muscle analysis the same size as the kinematics and inverse dynamics
        %         XML = xml_read ([trialsDir filesep  trList{k}]);
        %         % length sto
        %         filename = XML.muscleTendonLengthFile;
        %         IntrapolateMA(filename)
        %         % moment arm sto's
        %         for kk = 1:length(XML.momentArmsFiles.momentArmsFile)
        %             filename = XML.momentArmsFiles.momentArmsFile(kk).CONTENT;
        %             IntrapolateMA(filename)
        %         end
        %
        
        SetupFilename = [exeSetupDir fp trList{k}];
        XML = xml_read (SetupFilename);
        EXE = xml_read (XML.executionFile);
        
        % edit these values to change the strengthCoefficeint in the
        % calibrated models (see "EditCalibratedSubject" for specific
        % mucles within each group)
        ADD =[];HMS =[];GLU=[];HFL=[];VAS=[];ANK=[];OTHER=[];
        
        EditCalibratedSubject(XML.subjectFile,ADD,HMS,GLU,HFL,VAS,ANK,OTHER)
        AddDannyTendon(XML.subjectFile)
        CheckCalibratedValues(XML.subjectFile)
        
        for kk = [200,500]
            prefXmlWrite.StructItem = false;  % allow arrays of structs to use 'item' notation
            prefXmlWrite.CellItem   = false;
            
            n = num2str(kk);
            XML.outputDirectory = [results_directory fp 'iteration_' n];
            
            xml_write(SetupFilename, XML, 'ceinms', prefXmlWrite);
            
            EXE.NMSmodel.activation.exponential = struct;
            EXE.NMSmodel.type.hybrid.alpha = 1;
            EXE.NMSmodel.type.hybrid.beta = 2;
            EXE.NMSmodel.type.hybrid.gamma = kk;
            xml_write(XML.executionFile, EXE, 'execution', prefXmlWrite);
            
            % run CEINMS
            command=['CEINMS -S ' SetupFilename];
            cd(CeinmsExeDir)
            dos(command);
            
            %Save the log file in a Log folder for each trial
            movefile([CeinmsExeDir '\out.log'],[XML.outputDirectory '\out.log'])
            movefile([CeinmsExeDir '\err.log'],[XML.outputDirectory '\err.log'])
            % save a copies in the results directoory
            copyfile([XML.subjectFile],results_directory)
            copyfile([XML.executionFile],results_directory)
            ImageStrCoef = [fileparts([XML.subjectFile]) fp 'StrengthCoeficients.jpeg'];
            copyfile(ImageStrCoef,results_directory) % Strength coefficients plot
            
            side = findLeg(DirElaborated,trList{k});
            plotMuscleForces(XML.outputDirectory,side)
        end
        
% 'E:\3-PhD\Data\MocapData\ElaboratedData\009\pre\ceinms\execution\simulations\Run_baseline1'
        CompareCEINMSIterations(results_directory)

    end
end
side = findLeg