% add patches from two-way anova SPM
% run "AnovaSPM_RS_FAI.m" before to get the ShadedArea

% I = interaactions shaded with colors

function I = addShadeSPM_gray(PatchArea)

ax = gca;
I={};
% rows = 1(Main A) 2(Main B) 3(interaction)
for row = 1:size(PatchArea,1)
    for k = 1:size(PatchArea,2)
        x = PatchArea{row,k}';
        if ~isempty(x)
            I{end+1} = 'Effect Group';
            Lines(row)=AddShade(ax,x,ax.YLim, [0.1 0.1 0.1]); % purple - factor 1: treatment
        else
            Lines(row)=AddShade(ax,-2,0, [0.1 0.1 0.1]); % purple - factor 1: treatment X=-2;Y=0;
        end
    end
end
