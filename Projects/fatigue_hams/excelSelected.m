clc
clear

%get all the files in the folder
subjectDir = uigetdir...
    ('\\staff.ad.griffith.edu.au\ud\fr\s5109036\Documents\Fatigue_hams',...
    'Select subject folder');
cd(subjectDir);
Files = dir;

% select the names with selectedTrials

DeletedFiles =0;                                                           % use the number of deleted files to correct for deleted items in the loop
for i = 1: length (Files)                                                  % check all the files in the folder
    n = i-DeletedFiles;
    if contains (Files(n).name,'selected') ~= 1                            % check if names of files contain the word "selected'
        Files(n)=[];                                                       % IF NOT, delete row
        DeletedFiles = DeletedFiles +1;
    end
    
end



for ss = 1 : length (Files)                                                % loop through each subject
    subjectDir = sprintf('%s\\%s', Files(ss).folder, Files(ss).name);           % get the directory of each subject's data
    subjectName = Files(ss).name(1:4);                                          % get subject's name (only first 4 letters, eg " s002")
    load (subjectDir)                                                           % load selectedTrials
    conditions = fields (selectedTrials);
    classification = cell(1,39);
    
    for c = 1: length (conditions)                                              % loop through each condition (eg post_25_1)
        [Ntrials,Ncol] = size (selectedTrials.(conditions{c}));                     % get the number of trials per condition
        
        if Ncol < 3                                                                 % if there is no 3rd column in this trial
           selectedTrials.(conditions{c}){1,3}=[];                                  % add a balnk cell. This avoids error in next loop                
        end
        
        for t = 1: Ntrials                                                          % loop trhough the number of trials
            classification{end+1,1}= selectedTrials.(conditions{c}){t,1};               % name the next row based on the trial analysed
            badChannels = cell2mat(selectedTrials.(conditions{c}){t,3});                % create double vector from the bad channels
            
            for i = 1:38                                                                % loop throught the 38 channels for the EMG in the classiication variable
                if find (badChannels== i)                                                 % check if each channel is in the "bad channels"
                    classification{end,i+1} = 'Bad';                                      % if YES, classify as bad
                    
                else
                    classification{end,i+1} = 'Good';                                     %if NO, classify as good
                end
            end
        end
    end
excelName = sprintf('%sclassification.xls',subjectName);
xlswrite (excelName,classification);    
msgbox(sprintf('end of %s ',subjectName))   

end


