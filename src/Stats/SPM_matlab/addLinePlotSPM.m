
%   LineLength = NxM cell array with N lines and M
%   colors (default= all black)
% ExampleData:
%       x = 1:101; y = sin(x/10); y2 = sin(x/20);LineLength={[1:10] [15:60] [];[] [20:25] [90:101];[] [10:85] [88]};
%       figure; hold on; plot(x,y); plot(x,y2); colors=[0.26,0.01,0.32;0.19,0.40,0.55;0.21,0.72,0.46];
%       YPositions = addLinePlotSPM(LineLength,colors)
%
function [YPositions,Lines] = addLinePlotSPM(LineLength,colors,Shade)

[Ncomparisons,NLines] = size(LineLength);
if nargin<2; colors=zeros(Ncomparisons,3); end

IntitalLimits = ylim; rangeY=range(IntitalLimits);SpaceBelow=0.03*Ncomparisons*rangeY*2;
ylim([min(ylim)-SpaceBelow , max(ylim)]);NewLimits = ylim;
YPositions = flip(NewLimits(1)+rangeY*0.05:SpaceBelow/Ncomparisons:IntitalLimits(1));
hold on
for row = 1:Ncomparisons
    for col = 1:NLines
        if ~isempty(LineLength{row,col})
        X = LineLength{row,col}(1):0.2:LineLength{row,col}(end);
        Y=repmat(YPositions(row),1,length(X));
        else; X=-2;Y=0;
        end
        
        if nargin<3||Shade==0
        Lines(row) = plot(X,Y,'o','LineWidth',2,...
            'Color',colors(row,:),...
            'MarkerSize',4,...
            'MarkerFaceColor',colors(row,:),...
            'MarkerEdgeColor',colors(row,:));
        else
            Lines(row)=AddShade(gca,X,Y,colors(row,:));
        end
    end
end
