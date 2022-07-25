%% adjust mass model (average of all the trials for each RRA iteration)
% Baasilio Goncalves(2020)
% see adjustmodelmass_BG
function [segment_mass,trials,bodyNames,MeanSegment_mass,original_mass,Adj] = adjustmodelmass_Mean(Dir,TrialList)

fp = filesep;
RRA_Log = {};
resid = [];
massAdj =[];
Adj =[];
for ii = flip(1:length(TrialList))
    trialName = TrialList{ii};
    NewIKDir = [Dir.RRA fp trialName fp trialName '_Kinematics_q.sto'];
    if ~exist(NewIKDir)
        TrialList(ii)=[];
    end
end

for ii = 1:length(TrialList)
    trialName = TrialList{ii};
    m = [];             % restrat m for each file (m = mass adjustmets for the whole body)
    OutLogDir = [Dir.RRA fp trialName fp 'out.log'];
    
    [m(:,end+1),residuals,~] = LoadResultsRRALog(OutLogDir);
    RRA_Log{ii} = OutLogDir;
    resid(:,ii) = residuals;
    Adj(:,ii) = m;
    % remove large mass adjustments
    %         if abs(m) > 30
    %             RRA_Log{ii} ={};
    %             resid(:,ii) = 0;
    %             continue
    %         end
    
    if ~isempty(m)          % add the mass to a variable with all the masses for each trial in each column
        massAdj(:,end+1) = m';
    end
end


%% adjust model mass
scaleFactor = 1;
cd(Dir.RRA)

if abs(sum(sum(resid)))>0
    RRA_Log = RRA_Log(~cellfun(@isempty,RRA_Log)); % delete empty cells
    [segment_mass,trials,bodyNames,MeanSegment_mass,original_mass] = adjustmodelmass_BG(scaleFactor,RRA_Log,Dir.OSIM_LinearScaled,Dir.OSIM_RRA);
    
else
    segment_mass= []; trials = {}; bodyNames = {}; MeanSegment_mass = []; original_mass = [];
    disp(' '); disp(['Mass adjustments  not performed - Residuals all above threshold'])
end




