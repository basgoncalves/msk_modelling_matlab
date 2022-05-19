function  staticElabPath = staticElaboration_apm(subjectNames, motoDir, BasePath)
%Runs the MOtoNMS staticElaboration for CHESM apm project data
%   Loops through all subjects and sessions within the subject to process
%   the static trials for further analysis. This includes processing joint
%   centres, and generating a static.trc file for scaling and mkrplacer functions
%   to be run on an OpenSim model.

%%% INPUTS %%%

% 1: Cell array containing all subjects in analysis
% 2: Path to where MOtoNMS is stored on your computer
% 3: Path to the ElaboratedData folder on your computer

%%% OUTPUTS %%%

% 1: Path to the staticElaboration folder for each subject and session

%% Loop through subjects

for nS = 1:length(subjectNames)
     
     % Remove space from subject name if there is one
     subjectName = subjectNames{nS}(~isspace(subjectNames{nS}));
     
	 % Skip bad participants
	 badSubjects = {''};
	 
	 % Check if subject should not be processed
	 badSubjectCheck = strcmp(badSubjects, subjectNames{nS});
	 
	 if any(badSubjectCheck) % if no values in variable badSubjectCheck then we can continue with analysis
		 disp('Skipping participant because it matches one of those in badSubjects variable');
		 continue
	 end
	 
     % Create cell array containing session folders for chosen subject
     SessionDirs = dir([BasePath, filesep, subjectNames{nS}]);
     isub=[SessionDirs(:).isdir];
     sessionFolders={SessionDirs(isub).name}';
     sessionFolders(ismember(sessionFolders,{'.','..', 'ROM', 'EMG_columnplots'}))=[]; % dynamic subject folders
     
	 % Loop through sessions
     for nSess = 1:length(sessionFolders) 
		 
          % Remove space from session name if there is one
		 sessionName = sessionFolders{nSess}(~isspace(sessionFolders{nSess}));
		 
          % Define staticElabPath and folder with static c3d files
          staticElabPath.(subjectName).(sessionName) = [BasePath,...
               filesep, subjectNames{nS}, filesep, sessionFolders{nSess}, filesep, 'staticElaborations'];
		  InputDataPath = [regexprep(BasePath, 'ElaboratedData', 'InputData'), filesep, subjectNames{nS}, filesep, sessionFolders{nSess}]; 
          c3dFolderDirs = dir(regexprep(staticElabPath.(subjectName).(sessionName), 'staticElaborations', 'sessionData'));
          isubby=[c3dFolderDirs(:).isdir];
          c3dFolder={c3dFolderDirs(isubby).name}';
          
          % Extract only the Static file for subsequent processing
          TF2 = contains(c3dFolder, {'Static'});
          c3dStaticFolders = c3dFolder(TF2);
          
          % If not first session then I won't run the default static
          % Elaboration, instead skip to modified down below.
          if nSess == 1
               
               % Check to see if staticElaborations has already been performed
               if exist(staticElabPath.(subjectName).(sessionName), 'dir') == 7
				   
                    % If so print to screen and make dir of path
%                     fprintf('\nStatic elaboration exists for %s in %s\n', subjectNames{nS}, sessionFolders{nSess});
                    staticFileName='Static1';
                    staticFileFullPath=[staticElabPath.(subjectName).(sessionName) filesep staticFileName filesep 'StaticCal'];
                    
                    % Run staticElab on remaining conditions in session
                    
                    for nc3d = 1:length(c3dStaticFolders)
                         
                         % For remaining static trials use the first static.xml to
                         % run elaborations.
                         
                         if exist([staticElabPath.(subjectName).(sessionName) filesep c3dStaticFolders{nc3d}, filesep, 'StaticCal'], 'dir') == 7
                              fprintf('\nStatic elaboration exists already for %s in %s for trial: %s\n',...
                                   subjectNames{nS}, sessionFolders{nSess}, c3dStaticFolders{nc3d});
                         else
                              [foldersPaths,parameters] = StaticElaborationSettings_apm(staticFileFullPath,...
                                   sessionFolders{nSess}, c3dStaticFolders{nc3d});
                              
                              % Run static elaboration with updated info
                              cd([motoDir, filesep, 'src', filesep, 'StaticElaboration']);
                              runStaticElaboration_apm(staticFileFullPath, foldersPaths, parameters);
                         end
                    end
               else
                    
                    % Otherwise navigate to staticElaboration src in MOtoNMS and
                    % run staticElaboration main function
                    cd([motoDir, filesep, 'src', filesep, 'StaticElaboration']);
                    StaticInterface_apm('Static1', InputDataPath);
                    staticFileName='Static1';
                    staticFileFullPath=[staticElabPath.(subjectName).(sessionName) filesep staticFileName filesep 'StaticCal'];
                    
                    % Then run staticElab on remaining conditions in
                    % session
                    for nc3d = 1:length(c3dStaticFolders)
                         
                         % For remaining static trials use the first static.xml to
                         % run elaborations.
                         
                         if exist([staticElabPath.(subjectName).(sessionName) filesep c3dStaticFolders{nc3d}, filesep, 'StaticCal'], 'dir') == 7
                              fprintf('\nStatic elaboration exists already for %s in %s for trial: %s\n',...
                                   subjectNames{nS}, sessionFolders{nSess}, c3dStaticFolders{nc3d});
                         else
                              [foldersPaths,parameters] = StaticElaborationSettings_apm(staticFileFullPath,...
                                   sessionFolders{nSess}, c3dStaticFolders{nc3d});
                              
                              % Run static elaboration with updated info
                              cd([motoDir, filesep, 'src', filesep, 'StaticElaboration']);
                              runStaticElaboration_apm(staticFileFullPath, foldersPaths,...
                                   parameters);
                         end
                    end
                    
               end
               
               % Skip to modified elaboration for sessions 2+
		  else
			  
               % If other static trials for armour systems haven't been
               % processed then loop through them here and generate static.trc
               % files
               for nc3d = 1:length(c3dStaticFolders)
                    
                    % For remaining static trials use the first static.xml to
                    % run elaborations.
                    
                    if exist([staticElabPath.(subjectName).(sessionName) filesep c3dStaticFolders{nc3d}], 'dir') == 7
                         fprintf('\nStatic elaboration exists already for %s in %s for trial: %s\n',...
                              subjectNames{nS}, sessionFolders{nSess}, c3dStaticFolders{nc3d});
                    else
                         [foldersPaths,parameters] = StaticElaborationSettings_apm(staticFileFullPath,...
                              sessionFolders{nSess}, c3dStaticFolders{nc3d});
                         
% 						  staticFileFullPath=[staticElabPath.(subjectName).(sessionName) filesep staticFileName filesep 'StaticCal'];
                         % Run static elaboration with updated info
                         cd([motoDir, filesep, 'src', filesep, 'StaticElaboration']);
                         runStaticElaboration_apm(staticFileFullPath, foldersPaths,...
                              parameters);
                    end
               end
          end
          close all
     end
end

% Save variable with directories to static elab folders for each subject
% and session
cd(BasePath);
save('staticElabPathNames.mat', 'staticElabPath')

end

