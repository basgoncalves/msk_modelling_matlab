function emgProcessingMain(pname, c3dFile_name, sessionData, motoDir, dynamicFolders, times)
%Main function to process Load Sharing EMG data
%   Input the relevant directories and process EMG depending on whether max
%   data exists, if current file is a max file, and output the EMG mot
%   files for future use.

% Check to see if  trial will be used as maximum for normalisation.
% Inline function to determine if string exists
% cellfind = @(string)(@(cell_contents)(strcmp(string, cell_contents)));
% cell_array = dynamicFolders;
% string = maxName;
% isMaxExist = cellfun(cellfind(string), cell_array);

% % Set isMax based on the trial being a max trial (or not)
% isMax = ismember(dynamicFolders(any(isMaxExist,2)), c3dFile_name(1:end-4));

emgMaxFileLoc = [sessionData, filesep, 'emgMax'];
emgMaxFile = [emgMaxFileLoc, filesep, 'maxEMG.txt'];

% Create folder to put max EMG if it doesn't exist already
if ~isdir(emgMaxFileLoc)
     mkdir(emgMaxFileLoc);
end

% --Check to see if EMG data is from txt file or from .c3d to
% know if we need to apply a notch filter--

% Initialise
asciiNames = {'Subject 6', 'Subject 8', 'Subject 13', 'Subject 14',...
     'Subject 15', 'Subject 16', 'Subject 17'};

% Loop through subject names known have txt files
for ii = 1:length(asciiNames)
     k = regexp(pname, asciiNames, 'once');
end

tf = isempty(k);

if tf == 0
	
	if ~exist(emgMaxFile, 'file')
		
		% Load data for max trial so we can process this first
		% without notch filter
		emgProcessingMaxMultiple('no', sessionData, dynamicFolders, motoDir);
		disp('Max processing done, loading for EMG processing...');
		
		% Only run on walking trials - not kneeFJC trials
		if ~strcmp(c3dFile_name(1:4), 'Knee')
		[emgMax] = importMaxEMGFile(emgMaxFile);
		emgProcessingLS('no', sessionData, times, c3dFile_name(1:end-4), emgMax, motoDir);
%  		emgProcessingLS_v2('no', sessionData, c3dFile_name(1:end-4), emgMax, motoDir, dynamicFolders);
		end
	
	else
		% Load max trial value and process
		if ~strcmp(c3dFile_name(1:4), 'Knee')
		[emgMax] = importMaxEMGFile([emgMaxFileLoc, filesep, 'maxEmg.txt']);
% 		emgProcessingLS_v2('no', sessionData, c3dFile_name(1:end-4), emgMax, motoDir, dynamicFolders);
		emgProcessingLS('no', sessionData, times, c3dFile_name(1:end-4), emgMax, motoDir);
		end
	end
	
else
	
	% If not ASCII file then we need to apply notch filter
	if ~exist(emgMaxFile, 'file')
		
		% Load data for max trial so we can process this first
		% with notch filter
		emgProcessingMaxMultiple('yes', sessionData, dynamicFolders, motoDir);
		disp('Max processing done, loading for EMG processing...');
		
		if ~strcmp(c3dFile_name(1:4), 'Knee')
		[emgMax] = importMaxEMGFile([emgMaxFileLoc, filesep, 'maxEmg.txt']);
% 		emgProcessingLS_v2('yes', sessionData, c3dFile_name(1:end-4), emgMax, motoDir, dynamicFolders);
		emgProcessingLS('yes', sessionData, times, c3dFile_name(1:end-4), emgMax, motoDir);
		end
		
	else
		% Load max trial value and process
		if ~strcmp(c3dFile_name(1:4), 'Knee')
		[emgMax] = importMaxEMGFile([emgMaxFileLoc, filesep, 'maxEmg.txt']);
% 		emgProcessingLS_v2('yes', sessionData, c3dFile_name(1:end-4), emgMax, motoDir, dynamicFolders);
		emgProcessingLS('yes', sessionData, times, c3dFile_name(1:end-4), emgMax, motoDir);
		end
	end
	
end

disp(' EMG Processing complete');

clearvars

% 
% % Use isMax comparison to see if EMG processing will be performed
% if any(isMax(:) == 1)
%      
%      % Check to see if max file already exists
%      if ~exist(emgMaxFile, 'file')
%           % Load data for max trial so we can process this first
%           emgProcessingMaxLS('no', sessionData, maxc3dFile_name(1:end-4), motoDir);
%           disp('Maximum trial finished processing');
%      else
%           disp('Maximum trial has already been analysed for this session, continuing with analysis...');
%      end
%      
%      
% else
%      
%      % Check to see if max file already exists
%      if ~exist(emgMaxFile, 'file')
%           
%           disp('EMG max does not exist, processing this max trial first...');
%           
%           if tf == 0
%                
%                % Load data for max trial so we can process this first
%                % without notch filter
%                emgProcessingMaxLS('no', sessionData, maxName, motoDir);
%                disp('Max trial done, loading for EMG processing...');
%                [emgMax] = importMaxEMGFile([emgMaxFileLoc, filesep, 'maxEmg.txt']);
%                emgProcessingLS('no', sessionData, times, c3dFile_name(1:end-4), emgMax, motoDir);
%                
%           else
%                
%                % Processing for EMG data collected directly in nexus, this includes a
%                % notch filter
%                emgProcessingMaxLS('yes', sessionData, maxName, motoDir);
%                disp('Max trial done, loading for EMG processing...');
%                
%                % Load Max file
%                [emgMax] = importMaxEMGFile([emgMaxFileLoc, filesep, 'maxEmg.txt']);
%                
%                % Then process
%                emgProcessingLS('yes', sessionData, times, c3dFile_name(1:end-4), emgMax, motoDir);
%                
%           end
%           
%           % If it's the other KneeFJC trial then skip this
%      elseif strcmp(c3dFile_name, maxc3dFileOther)
%           disp([c3dFile_name, ' is the other max trial, but we''re using ', maxc3dFile_name]);
%           
%      else
%           disp('Maximum trial exists, running EMG processing...');
%           
%           % Load max trial data
%           [emgMax] = importMaxEMGFile([emgMaxFileLoc, filesep, 'maxEmg.txt']);
%           
%           if tf == 0
%                % Run EMG processing for .txt data
%                emgProcessingLS('no', sessionData, times, c3dFile_name(1:end-4), emgMax, motoDir);
%                
%           else
%                % Processing for EMG data collected directly in nexus, this includes a
%                % notch filter
%                emgProcessingLS('yes', sessionData, times, c3dFile_name(1:end-4), emgMax, motoDir);
%           end
%           
%           disp(' EMG Processing complete');
%      end
% end
% clearvars
% end
% 
