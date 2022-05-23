% this script plots the force and EMG data and allows to 
%
%   INPUT 
%       Data = Sruct composed of individual doubles with 38 columns. See
%       example.mat file

% function selectedTrials = plotHams (Data)
tic;
clc
clear
close all                            % colse all opened figures

subjectDir = uigetfile('\\staff.ad.griffith.edu.au\ud\fr\s5109036\Documents\Fatigue_hams','Select subject folder');
load (subjectDir);

Data = FilteredData;
trials = fields (Data);              % name of each trial
nTrials = length (trials);           % number of trials


if exist ('selectedTrials','var')==0 %create the variable selected trials if it doesn't exist
selectedTrials = struct;
end

for t = 1: nTrials                  % loop through all the trials in
    if isfield (selectedTrials,(trials{t})) == 1
        if isempty(selectedTrials.(trials{t})) == 0
        continue
        end
    end
    gc = figure ('Position',...     % create figure [Xposition Yposition Xsize Ysize] 
        [100 50 1500 900]);
    data = Data.(trials{t});
    goodTrials = {};                 % cell array that contains the number of trials in each file (eg. post_25_1 may be devided in post_25_1a and post_25_1b)
    count=1;                         % counts the number of
    %% force plot parameters
    subplot(2,1,2);
    plot (data(:,3));                % plot force
    s1 = length(data (:,3));         % Sample Indices Vector
    Fs = 2048;                       % Sampling Frequency (Hz)
    time1 = s1/Fs;                   % Time (seconds)
    axis tight
    xticklabels(0:time1/length(xticklabels):time1)
    title(sprintf('%s', trials{t}),'Interpreter', 'none')
    %% check if there are more than one rep in the force curve
    Ans = questdlg('Divide trial');                                         %ask if you want to devide this
    Alphabet = 'abcdefghijklmnopqrstuvwxyz';
    
    if contains(Ans,'Yes')
        
        while contains(Ans,'Yes')
            startCut = round(ginput (1));
            endCut = round(ginput (1));
            goodTrials{count,1} = sprintf('%s_%s', trials{t},Alphabet(count));
            goodTrials{count,2} = data(startCut(1):endCut(1),:);  %cut original data from selection to the end
            plot (data(:,3)); axis tight;
            count = count +1;
            startCut = endCut(1);
            Ans = questdlg('Devide trial');
        end
        
    elseif contains(Ans,'No')
        goodTrials{count,1} = sprintf('%s_%s', trials{t},Alphabet(count));
        goodTrials{count,2} = data; 
        
    end
    
       
    %% loop thorugh all the trials to select the good EMGs
    [nGoodTrials,~] = size(goodTrials);
    
    for GT = 1: nGoodTrials                             % loop through the number of good trials
        subplot(2,1,2);
        plot (goodTrials{GT,2}(:,3))                    %plot Force
        countBad = 1;                                   % count the number of bad trials
        %% Force plot parameters
        axis tight
        s1 = length(goodTrials{GT,2}(:,3));         % Sample Indices Vector
        Fs = 2048;                                  % Sampling Frequency (Hz)
        time1 = s1/Fs;                              % Time (seconds)
        timeInt = time1/length(xticklabels);
        xticklabels(timeInt:timeInt:time1)
        title(sprintf('%s', goodTrials{GT,1}),'Interpreter', 'none')
        %% loop through the BF and ST EMG channels
        for ch=7:38                                     % loop through the BF and ST EMG channels
              
            if min(goodTrials{GT,2}(:,ch))/max(goodTrials{GT,2}(:,ch)) >= 0.5
                continue
            elseif mean(goodTrials{GT,2}(:,ch))==0
                continue
            end
           
            subplot(2,1,1);
            plot (goodTrials{GT,2}(:,ch));              %plot EMG      
            
            %% EMG plot parameters
            axis tight
            ylim([0,0.5]);
            s2 = length(goodTrials{GT,2}(:,ch));         % Sample Indices Vector
            Fs = 2048;                                   % Sampling Frequency (Hz)
            time2 = s2/Fs;                               % Time (seconds)
            timeInt = time2/length(xticklabels);
            xticklabels(timeInt:timeInt:time2)
            title(sprintf('%s - channel %d', trials{t},ch),'Interpreter', 'none')
            %% keep the EMG trial ??           
            Ans = questdlg('Keep this trial?');
            
            if contains (Ans,'No')                       % if answer is no
                goodTrials{GT,3}{countBad} = ch;         % write the number of the channels that were not good
                countBad = countBad+1;
            end
        end
    end
    selectedTrials.(trials{t})=  goodTrials;
    close (gcf);
end

msgbox('end of script');
totalTime = toc