
[SelectedData,SelectedLabels,idx] = findData (meanPosWork,description,{'Speed 1-2' 'Speed 13-14'})
deltaVel = (meanPosWork(:,idx(2))-meanPosWork(:,idx(1)))./meanPosWork(:,idx(1))*100;
ADJmean=[];

% Hip 1-2
ii = find(contains(description,'Hip 1-2'));
ADJmean(2,end+1) = CalcADJmean(meanPosWork(:,ii),deltaVel);
ADJmean(1,end) = mean(meanPosWork(:,ii));

% Hip 13-14
ii = find(contains(description,'Hip 13-14'));
ADJmean(2,end+1) = CalcADJmean(meanPosWork(:,ii),deltaVel);
ADJmean(1,end) = mean(meanPosWork(:,ii));

% Knee 1-2
ii = find(contains(description,'Knee 1-2'));
ADJmean(2,end+1) = CalcADJmean(meanPosWork(:,ii),deltaVel);
ADJmean(1,end) = mean(meanPosWork(:,ii));

% Knee 13-14
ii = find(contains(description,'Knee 13-14'));
ADJmean(2,end+1) = CalcADJmean(meanPosWork(:,ii),deltaVel);
ADJmean(1,end) = mean(meanPosWork(:,ii));

% Ankle 1-2
ii = find(contains(description,'Ankle 1-2'));
ADJmean(2,end+1) = CalcADJmean(meanPosWork(:,ii),deltaVel);
ADJmean(1,end) = mean(meanPosWork(:,ii));

% Ankle 13-14
ii = find(contains(description,'Ankle 13-14'));
ADJmean(2,end+1) = CalcADJmean(meanPosWork(:,ii),deltaVel);
ADJmean(1,end) = mean(meanPosWork(:,ii));

groups = {'Hip 1-2','Hip 13-14','Knee 1-2','Knee 13-14','Ankle 1-2','Ankle 13-14'};
mybar = plotBar (ADJmean', groups,{'Mean', 'Adjusted mean'});
ylabel ('% of total work')
title ('Positive joint work')

[SelectedData,SelectedLabels,idx] = findData (meanPosWork,description,groups)
figure
for row = 1:size(SelectedData,1)
    pp(row)=plot(SelectedData(row,1:2));
    hold on
end