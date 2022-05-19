function trialParams = extractTrialParametersFromConditionName(trialname, expressionToSplit)
% Extract walking speed and trial number from a given trial
% name

% Specify expression used to split
expression = expressionToSplit;

% Split string into walking speed and trial number
splitStr = regexp(trialname, expression, 'split');

% Loop through parameters and assign them to structure
for n = 1:length(splitStr)
	trialParams.(['param', num2str(n)]) = splitStr{n};
end

end

