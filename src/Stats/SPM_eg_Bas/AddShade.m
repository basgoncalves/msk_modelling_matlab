% ax = axis (use "gca")
% x = x values for the shade
% y = y data in your axis
function f1=AddShade(ax,x,y,Color)

if ~exist('Color');Color ='k'; end
axes(ax);hold on
Top = NaN(1,length(x));
Top(:) = max(ylim);
Bottom = NaN(1,length(x));                 % create bottom of shaded
Bottom(:) = min(ylim);
X=[x,fliplr(x)];                            % create continuous x value array for plotting
Y=[Bottom,fliplr(Top)];                     % create y values for out and then back
f1 = fill(X,Y,'m');
set(f1,'FaceColor', Color)
f1.EdgeColor = 'none';
f1.FaceAlpha= 0.1;

