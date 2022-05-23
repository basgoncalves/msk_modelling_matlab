% plot each column on the Mean matrix with each column on the SD matrix
function p = plotShadedSD(YData,SD,COLOR,Xvalues)

if size(YData,2)~=size(SD,2)
    error('Number of columans in Mean and SD inputs must agree')
end

% [ cMat, cStruct, cNames] = getColorSet(30); % color blind friendly
if nargin<3 || isempty(COLOR)
    cMat = colorBG(0,size(YData,2)); % color scheme 2 (Bas)
else
    cMat = COLOR;
end
%line styles
style = {'-','--',':','-.'};
for k = 1:ceil(size(YData,2)/4)
    style = [style style];
end

for ii = 1:size(YData,2)
    hold on
    y1=YData(:,ii)';                             % create main curve
    if nargin <4
        x=1:length(y1);                             % initialize x row vector
    else
        x = Xvalues';
    end
    
    p(ii) = plot(x,y1,'LineWidth',1);
    set(p(ii),'Color',cMat(ii,:),'LineStyle',style{ii})
    color = p(ii).Color;
   
    Top= y1+SD(:,ii)';                          % create top of shaed area
    Bottom = y1-SD(:,ii)';                      % create bottom of shaded
    X=[x,fliplr(x)];                            % create continuous x value array for plotting
    Y=[Bottom fliplr(Top)];                     % create y values for out and then back
    f1 = fill(X,Y,color);
    alpha 0.3
    set(f1,'FaceColor', color,'EdgeColor','none')
    
end


