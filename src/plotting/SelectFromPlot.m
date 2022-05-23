% select data based on plot
% selectType = 1 crop horizonally / 2 = crop vertically
function SelectedData = SelectFromPlot(data,selectType)


plot(data)
if ~exist('selectType')
    [x,~]=ginput(2);
elseif selectType==2
    [~,x]=ginput(2);
else
    [x,~]=ginput(2);
end

SelectedData = data(round(x(1)):round(x(2)),:);