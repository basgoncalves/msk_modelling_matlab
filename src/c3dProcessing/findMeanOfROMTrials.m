function [anglesJointMean] = findMeanOfROMTrials(anglesJoint, sessionConditions, matFileDir, subjectName)
%Evaluate the ROM trials to obtain mean of all trials
%   Detailed explanation goes here

% Check if structure exists
if ~exist([matFileDir, 'romData.mat'], 'file')
	anglesJointMean = struct();
else
	load([matFileDir, 'romData.mat']);
end

trials = {'HF', 'ShoulderFF', 'UUA', 'TF'};
names = fieldnames(anglesJoint);
subjectName = regexprep(subjectName, ' ', '_');


% Loop through conditions in session
for t = 1:length(sessionConditions)
	
	% Loop through possible ROM trials
	for i = 1:length(trials)
		
		% Determine the angle of interest based on trial name.
		if strcmp(trials{i}, 'HF')
			angle = 'RHip_Flex';
			
		elseif strcmp(trials{i}, 'ShoulderFF')
			angle = 'RShld_Add';
			
		elseif strcmp(trials{i}, 'UUA')
			angle = 'RShld_Add';
			
		elseif strcmp(trials{i}, 'TF')
			angle = 'LumbarExtension';
			
		else
			
		end
		
		% Find how many trials are in session
		expression = [trials{i}, '\d\w', sessionConditions{t}];
		numInSession = regexp(names, expression);
		idx = find(~cellfun(@isempty,numInSession));
		
		% Check to make sure the trials exist
		if ~isempty(idx)
			
			% Check if the angles were calculated
			if isfield(anglesJoint.(names{idx(1)}), angle)
				
				% Find mean based on number of trials
				if length(idx) == 3
					trial1 = anglesJoint.(names{idx(1)}).(angle).Range;
					
					trial2 = anglesJoint.(names{idx(2)}).(angle).Range;
					
					trial3 = anglesJoint.(names{idx(3)}).(angle).Range;
					
					anglesJointMean.(subjectName).(sessionConditions{t}).(trials{i}) = mean([trial1, trial2, trial3]);
					
				elseif length(idx) == 2
					trial1 = anglesJoint.(names{idx(1)}).(angle).Range;
					
					trial2 = anglesJoint.(names{idx(2)}).(angle).Range;
					
					anglesJointMean.(subjectName).(sessionConditions{t}).(trials{i}) = mean([trial1, trial2]);
					
				elseif length(idx) == 1
					trial1 = anglesJoint.(names{idx(1)}).(angle).Range;
					
					anglesJointMean.(subjectName).(sessionConditions{t}).(trials{i}) = trial1;
					
				end
			end
		end
	end
end

