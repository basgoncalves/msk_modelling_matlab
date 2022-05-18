%% Basilio Goncalves 2019
%Example
%   OriginalFiles =  dir(sprintf('%s\\%s',Folder,'*.c3d'))
%   destination = C:\CopiedTrials
%   TrialsToCopy = {'Name1','Name2'}

function copyTrials (OriginalFiles,destination,TrialsToCopy) 

%if no Trials to copy selected just copy all the trials
if nargin <3
nameIDX = 1;
TrialsToCopy = struct2cell(OriginalFiles)';
TrialsToCopy = TrialsToCopy(:,nameIDX);
end
copiedTrials=0;

%     LoadBar = waitbar(0,'Copying Trials...');
    for ff = 1:length (OriginalFiles)
%         waitbar(ff/length (OriginalFiles),LoadBar,'Copying Trials...');
        for ii = 1:length(TrialsToCopy)
            LogicTrial = TrialsToCopy{ii};
            if contains(OriginalFiles(ff).name,LogicTrial,'IgnoreCase',true)
                source =[OriginalFiles(ff).folder filesep OriginalFiles(ff).name];
                copyfile (source, destination)
                copiedTrials = copiedTrials+1;
            end
        end
    end

close all

%sprintf('%d trials copied',copiedTrials)