
% run individual anova for each  [p,t] = ANOVAIsomStrengthFAI_PerTask(TorqueData,Groups,Conditions)

function [p,t] = ANOVAIsomStrengthFAI_PerTask(TorqueData,Groups,Conditions)


[Nrow,Ncol] = size(TorqueData);
t = struct;
p =[];


for c = 1:Ncol % loop throught each col (each condition "Conditions")
    
    Cond = Conditions{c};
    y = [];
    group =[];

    for G = 1:length(Groups)
        n = length(Groups{G});
        LastCell = length(group);
        % torque data 
        y(LastCell+1:LastCell+n,1) =  TorqueData(Groups{G},c);
        
        % group data [CON,FAIS,FAIM] and
        group(LastCell+1:LastCell+n,1)= zeros(n,1);
        group(LastCell+1:LastCell+n,1)= G;

        
    end
    [p(c),t.(Cond),stats,~] = anovan(y,{group},'varnames',strvcat('Group'),'display','off');
    [comparison,means,h,gnames] = multcompare(stats,'ctype','bonferroni');
    
    
    
end

% ANOVA with 2 factors (Group [CON,FAIS,FAIM] and task [HE, HF, HADD...])
y (y==0) = NaN; % change zeros to NaN
p = round(p,2);
% [p,t,~,~] = anovan(y,{group task},'varnames',strvcat('Group', 'Task'));