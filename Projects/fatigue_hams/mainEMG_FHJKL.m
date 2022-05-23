% Analysie EMG data hamstings fatigue

clc
clear
%%

addpath(genpath(matlab.desktop.editor.getActiveFilename));  % directory of the currect script 


MainDir = 'E:\2-Fatigue_hams\EMGdata';
Files = dir ([MainDir filesep '*.mat']);

for ii = 1:size(Files,1)
    
    if contains(Files(ii).name,'s0') && ~contains(Files(ii).name,'maxforce')
        
        load (Files(ii).name)
        Trials = fields(selectedTrials);
        % loop through every trial
        for tt = 1: size(Trials,1)
            CurrTrial = Trials{tt};
            % loop through muliple trials of the same name
            for ss = 1: size(selectedTrials.(CurrTrial),1)
                ForceData = selectedTrials.(CurrTrial){ss,2}(:,3);
                GoodChannels = selectedTrials.(CurrTrial){ss,3}(:,3);
                GoodChannels = selectedTrials.(CurrTrial)(:,3);
            end
        end        
    end    
end