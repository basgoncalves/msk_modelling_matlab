% add patches from two-way anova SPM
% run "AnovaSPM_RS_FAI.m" before to get the ShadedArea

% I = interaactions shaded with colors

% shades for the results of FAI_RS study
function I = addShadeSPM_TTest(PatchArea)

ax = gca;
I={};
cMat = colorBG; % color scheme 2 (Bas)
% Controls
for k = 1:size(PatchArea,2)
    x = PatchArea{3,k}';
    if isempty(x)
        continue
    else
        I{end+1} = 'Control';
        AddShade(ax,x,ax.YLim, cMat(1,:)) % purple - factor 1: treatment
    end
end

% FAIS
for k = 1:size(PatchArea,2)
    x = PatchArea{2,k}';
    if isempty(x)
        continue
    else
        I{end+1} = 'FAIS';
        AddShade(ax,x,ax.YLim,cMat(2,:)) % green - factor 2: time
    end
end


% CAM
for k = 1:size(PatchArea,2)
    x = PatchArea{1,k}';
    if isempty(x)
        continue
    else
        I{end+1} = 'CAM';
        AddShade(ax,x,ax.YLim,cMat(3,:)) % yellow - interaction between treatment and time
    end
end


