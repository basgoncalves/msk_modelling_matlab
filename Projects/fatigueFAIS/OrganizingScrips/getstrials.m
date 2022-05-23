
% get struct formated trials
function Strials = getstrials(DynamicTrials,TestedLeg)


for k = 1:length(DynamicTrials)
    
    if contains(DynamicTrials{k},'baselineB','IgnoreCase',1) && contains(DynamicTrials{k},'1','IgnoreCase',1)
        Strials{k} = 'RunStraight2';
        
    elseif contains(DynamicTrials{k},'baselineB','IgnoreCase',1) && contains(DynamicTrials{k},'2','IgnoreCase',1)   % 2nd cut with the right
        if contains(TestedLeg,'R'); Strials{k} = 'CutTested2';
        else; Strials{k} = 'CutOposite2'; end
        
    elseif contains(DynamicTrials{k},'baselineB','IgnoreCase',1) && contains(DynamicTrials{k},'3','IgnoreCase',1)   % 2nd cut with the left
        if contains(TestedLeg,'R'); Strials{k} = 'CutOposite2';
        else; Strials{k} = 'CutTested2'; end
        
    elseif contains(DynamicTrials{k},'baseline','IgnoreCase',1) && contains(DynamicTrials{k},'1','IgnoreCase',1)
        Strials{k} = 'RunStraight1';
        
    elseif contains(DynamicTrials{k},'baseline','IgnoreCase',1) && contains(DynamicTrials{k},'2','IgnoreCase',1)    % 1st cut with the right
        if contains(TestedLeg,'R'); Strials{k} = 'CutTested1';
        else; Strials{k} = 'CutOposite1'; end
        
    elseif contains(DynamicTrials{k},'baseline','IgnoreCase',1) && contains(DynamicTrials{k},'3','IgnoreCase',1)    % 1st cut with the left
        if contains(TestedLeg,'R'); Strials{k} = 'CutOposite1';
        else; Strials{k} = 'CutTested1'; end
        
    else
        Strials{k} = DynamicTrials{k};
    end
    
end
