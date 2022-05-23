
ForceData = selectedTrials;                                 % Create a new variable from selectedTrials
peakForce = struct; 
peakForce.description = {'Fmax', 'RFD100', 'RFD50'};
trials = fields (ForceData);                                % name of the trials
fs = 2000;                                                  % sample frequency


for t = 1: length(fields (ForceData))                       % loop through all the cells in ForceData
    reps = size(ForceData.(trials{t}));                                  % number of resp per trial
    peakForce(t).trial =  (trials{t});
%%    
    for r = 1: reps
    
    dataRep = ForceData.(trials{t}){r,2}(:,3);                              %data for each repetition = 3rd columns for each rep    

    [FMax, RFD100, RFD50] = maxForceManual (dataRep,trials{t});
    peakForce(t).Fmax(r) =FMax;
    peakForce(t).RFD100(r) =RFD100;
    peakForce(t).RFD50(r) =RFD50;
    end


end

%% get maximum for each parameter

for t = 1: length(peakForce)                                     % loop through all the cells in ForceData

    peakForce(t).Fmax = max(peakForce(t).Fmax);                               % get the max of each columns for each parameter
    peakForce(t).RFD100 = max(peakForce(t).RFD100);
    peakForce(t).RFD50 = max(peakForce(t).RFD50);

end
%% save
peakForce_s003 = peakForce
save peakForce_s003 peakForce_s003