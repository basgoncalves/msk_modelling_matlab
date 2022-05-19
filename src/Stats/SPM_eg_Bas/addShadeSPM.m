% add patches from two-way anova SPM
% run "AnovaSPM_RS_FAI.m" before to get the ShadedArea

% I = interaactions shaded with colors

function I = addShadeSPM(PatchArea)

ax = gca;
I={};
% interaction A
for k = 1:size(PatchArea,2)
    x = PatchArea{3,k}';
    if isempty(x)
        continue
    else
        I{end+1} = 'Effect Group';
        AddShade(ax,x,ax.YLim, [0.6 0.2 0.4]) % purple - factor 1: treatment
    end
end

% interaction B
for k = 1:size(PatchArea,2)
    x = PatchArea{2,k}';
    if isempty(x)
        continue
    else
        I{end+1} = 'Effect time';
        AddShade(ax,x,ax.YLim,[0.0 0.8 0.6]) % green - factor 2: time
    end
end


% interaction AB
for k = 1:size(PatchArea,2)
    x = PatchArea{1,k}';
    if isempty(x)
        continue
    else
        I{end+1} = 'Group X Time';
        AddShade(ax,x,ax.YLim,[1.0 1.0 0.1]) % yellow - interaction between treatment and time
    end
end


