% EMG = EMG struct from "MeanEMG_perSubject"
% SS = string with subject name (eg 's002')
% Fch = scalar with the column number for the force channel
function [MVIC,TrialMax] = MVIC_hams(EMG, SS,MVICtrial,Fch,fsForce,Plotfig)


Conditions = fields(EMG.(SS))';

% find max force
MVIC = 0;
TrialMax ='';
if Plotfig == 1
    figure
    hold on
end
for CC = Conditions
    %current trial
    if contains (CC{1},MVICtrial)
        Trials = fields(EMG.(SS).(CC{1}))';
        for TT = Trials
            [CTmax,idx] = max(movmean(EMG.(SS).(CC{1}).(TT{1}).Data(:,Fch),fsForce/2));
            % find max
            MVIC = max([MVIC CTmax]);
            if MVIC == CTmax
                TrialMax = TT{1};
            end
            if Plotfig == 1
                plot(EMG.(SS).(CC{1}).(TT{1}).Data(:,Fch))
                plot(idx,CTmax,'.','MarkerSize',20)
            end
        end
    end
end
