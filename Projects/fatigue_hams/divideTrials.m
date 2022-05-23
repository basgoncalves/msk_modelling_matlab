%  This script 
% INPUT
%   data = structure where each field is a double with each columns
%   representing one channel. In this case n*38 double where channels 1 to
%   5 represent triggers and force channels and 6 to 38 represent EMG
%
%   NOTE: channel 1 an 5 reprent the index of the triggers in channels 2
%   and 6 respectively.
%


Pix_SS = get(0,'screensize');                                           % get the screen dimensions [
forceCH = 3;                                                            % column that contain force data
emgCH = 7:38;                                                           % columns that contain emg data
forceFreq = 2000;
emgFreq = 2048; 

Data = raw_data;
trials = fields (Data);              % name of each trial
nTrials = length (trials);           % number of trials

for t = 1:nTrials
currentTrial = Data.(trials{t});
    
gc = figure ('Position', ...
    [Pix_SS(3)/4 Pix_SS(4)/4 Pix_SS(3)/2 Pix_SS(4)/2]);                 % create figure [Xposition Yposition Xsize Ysize] 

 %% force plot parameters
    subplot(2,1,2);
    plot (currentTrial(:,forceCH));                % plot force
    s1 = length(currentTrial (:,forceCH));         % Sample Indices Vector
    Fs = 2048;                                     % Sampling Frequency (Hz)
    time1 = s1/Fs;                                 % Time (seconds)
    axis tight
    xticklabels(0:time1/length(xticklabels):time1)
    title(sprintf('%s', trials{t}),'Interpreter', 'none')

%%
Ans = questdlg('Divide trial');                                         % ask if you want to divide this
Alphabet = 'abcdefghijklmnopqrstuvwxyz';                                % use this to add letters at the end of each divided trial (eg. trial_1a, trial_1b)
    
    if contains(Ans,'Yes')
        
        while contains(Ans,'Yes')
            startCut = round(ginput (1));
            endCut = round(ginput (1));
            goodTrials{count,1} = sprintf('%s_%s', trials{t},Alphabet(count));
            goodTrials{count,2} = currentTrial(startCut(1):endCut(1),:);  %cut original data from selection to the end
            plot (currentTrial(:,forceCH)); axis tight;
            count = count +1;
            startCut = endCut(1);
            Ans = questdlg('Devide trial');
        end
        
    elseif contains(Ans,'No')
        goodTrials{count,1} = sprintf('%s_%s', trials{t},Alphabet(count));
        goodTrials{count,2} = currentTrial; 
        
    end
    
end
