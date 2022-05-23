
% run anova with all the data grouped 

function [p,t] = ANOVAIsomStrengthFAI_all(TorqueData,Groups,Conditions)



[Nrow,Ncol] = size(TorqueData);
t = struct;
p =[];

y = [];
group =[];
task = [];
for c = 1:Ncol % loop throught each col (each condition "Conditions")
    
    Cond = Conditions{c};
    
    for G = 1:length(Groups)
        n = length(Groups{G});
        LastCell = length(group);
        % torque data 
        y(LastCell+1:LastCell+n,1) =  TorqueData(Groups{G},c);
        
        % group data [CON,FAIS,FAIM] and
        group(LastCell+1:LastCell+n,1)= zeros(n,1);
        group(LastCell+1:LastCell+n,1)= G;
        
        % task [HE, HF, HADD...]
        task(LastCell+1:LastCell+n,1)= zeros(n,1);
        task(LastCell+1:LastCell+n,1)= c;
        
    end
    
    
end

% ANOVA with 2 factors (Group [CON,FAIS,FAIM] and task [HE, HF, HADD...])
y (y==0) = NaN; % change zeros to NaN
[p,t,~,~] = anovan(y,{group},'varnames',strvcat('Group'));
% [p,t,~,~] = anovan(y,{group task},'varnames',strvcat('Group', 'Task'));