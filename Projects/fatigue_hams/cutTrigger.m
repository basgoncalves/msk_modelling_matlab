% cut trigger is a function that removes all the data before a trigger.
%
% INPUT
%   data = structure where each field is a double with each columns
%   representing one channel. In this case n*38 double where channels 1 to
%   5 represent triggers and force channels and 6 to 38 represent EMG
%
%   NOTE: channel 1 an 5 reprent the index of the triggers in channels 2
%   and 6 respectively.
%
% OUTPUT
%   cutData = structure with the same size as data but in each double, data
%   before each trigger has been removed
%
%
function cutData = cutTrigger (data)


% Ans = questdlg('Divide trial');                                             %ask if you want to devide this
% Alphabet = 'abcdefghijklmnopqrstuvwxyz';                                    % use this to add l

Trials = fields (data);                                                     % get the name of all trials
[nTrials,~] = size (Trials);                                                % get the number of trials                                                              % count the number of new trials after dividing trials

for t = 1 : nTrials                                                         % loop through all the trials
    currentTrial = Trials{t};
    
    forceTriggerIdx = data.(Trials{t})(1,1);                                  % get the force trigger index
    
    if forceTriggerIdx == 0                                                 % if there is no trigger
        forceTriggerIdx = 1;                                                % cut from first frame
    end
    
    cutForce = data.(Trials{t})(forceTriggerIdx:end,2:4);                     % cut the force vector
    lengthNewForce = length (cutForce);                                       % get the length of the new force vector
    data.(Trials{t})(lengthNewForce:end,2:4) = 0;                             % delete data after the new force vector length
    data.(Trials{t})(1:lengthNewForce,2:4) = cutForce;                        % replace force with cutForce
    
    
    
    emgTriggerIdx = data.(Trials{t})(1,5);                                 % get the EMG trigger index
    
    if emgTriggerIdx == 0                                                 % if there is no trigger
        emgTriggerIdx = 1;                                                % cut from first frame
    end
    
    cutEMG = data.(Trials{t})(emgTriggerIdx:end,6:38);                     % cut the EMG vector
    lengthNewEMG = length (cutEMG);                                        % get the length of the new EMG vector
    data.(Trials{t})(lengthNewEMG:end,6:38) = 0;                           % delete data after the new EMG vector length
    data.(Trials{t})(1:lengthNewEMG,6:38) = cutEMG;                        % replace EMG with cutForce
    
end

cutData = data;