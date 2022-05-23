

mean_velocity = [5 6 7; 8 9 10;1 2 3]; % mean velocity
std_velocity = randn(3,3);  % standard deviation of velocity
figure
hold on
hb = bar(1:3,mean_velocity');
% For each set of bars, find the centers of the bars, and write error bars
pause(0.1); %pause allows the figure to be created
for ib = 1:numel(hb)
    %XData property is the tick labels/group centers; XOffset is the offset
    %of each distinct group
    xData = hb(ib).XData+hb(ib).XOffset;
    errorbar(xData,mean_velocity(ib,:),std_velocity(ib,:),'k.')
end