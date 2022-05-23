%% split Joint powers

OrganiseFAI
cd([DirMocap filesep 'Results'])

load('JointPowers.mat');
load('JointWorks.mat')
Power_joints = fields (JointPowers);
PowerBursts = struct;

%% Manual analysis - ONLY POISITVE POWER
cd(DirResults)
if exist('PowerBursts.mat')
    load('PowerBursts.mat')
    
    Rewrite = questdlg('do you want to rewrite the Power Bursts?');
else
    PowerBursts = struct;
end


for ff = 1%:length(Power_joints)
    TotalPower_All = JointPowers.(Power_joints{ff}).TotalPower;      % joint power for this joint
   
    
    for pp= 1:length(TotalPower_All)                                 % loop every columns (participant)
        
        if ~isempty (TotalPower_All{pp})                               % if cell is not empty
            for tt =  1: size(TotalPower_All{pp},2)                      % loop through every columns (trial)
                
                
                
                trialData = TotalPower_All{pp}(:,tt);
                trialNumber = sprintf('trial_%d',tt);
                
                % if the current trial number is not part of the struct  AND
                % the size of number of columns is smaller  AND
                % Rewrite = YES
                                  
                    
                    threshold = 0.5*max(trialData);
                    Title = sprintf('%s - %s - subject %d',Power_joints{ff},trialNumber,pp);
                    [SplitData,IdxBursts] = findBursts (trialData,threshold,Title);             %calback function to find POSITIVE bursts based on a threshold
                    
                    
                    % assign bursts
                    count = 1;
                    for fn = fieldnames(SplitData)'
                       
                        
                        SplitJoint = sprintf ('%s_%d',Power_joints{ff},count);                                  % split name (e.g. hip_flexion_1)
                        
                        PowerBursts.(SplitJoint).PositivePower{pp}(1:length(SplitData.(fn{1})),tt) = SplitData.(fn{1}); % split data
                        BurstData = PowerBursts.(SplitJoint).PositivePower{pp};                                 
                        BurstData (BurstData ==0) = NaN;                                                        % remove ZEROS
                        PowerBursts.(SplitJoint).PositivePower{pp} = BurstData;                                 
                        
                        count = count +1;
                        
                        
                    end
                    % save all data
                    
                    folder = [DirFigure filesep 'RunningBiomechanics' filesep 'Power_split' filesep num2str(pp)];
                    mkdir(folder)
                    cd(folder)
                    filename = sprintf ('%s.jpeg',strtrim(Title));
                    saveas (gca, filename)
                    close gcf
            end
        end
    end
end


%% save data
cd(DirResults)
save PowerBursts PowerBursts

%% If needed to delete a single participant
% 
% 
% for tt =  1: size(p{cc},2)                      % loop through every columns (trial)
%      trialNumber = sprintf('trial_%d',tt);
%      PowerBursts.(Power_joints{ff}).(trialNumber).TotalData(:,cc)= [];
%      PowerBursts.(Power_joints{ff}).(trialNumber).Burst_1(:,cc)= [];
%       PowerBursts.(Power_joints{ff}).(trialNumber).Burst_2(:,cc)= [];
%  end 