% plot joint work 
%
% NormalizedWork = N*M double matrix. 
%       N = number of condtions on the x axis
%       M = number of series (i.e. bars per condition)

function plotBarWork_4 (NormalizedWork,stdWork,AvgVelocityMax,StdVelocityMax,TitleName,YLabel)
figure
[Ntrials, Nparticipants] = size(NormalizedWork);
SEWork = stdWork./ sqrt(Nparticipants); 
SEVelocityMax = StdVelocityMax ./ sqrt(Nparticipants); 

x= 1:Ntrials;
PreNormalizedWork = NormalizedWork;
PreNormalizedWork(3:end,:)=NaN;
Pre = bar(x,PreNormalizedWork,'FaceColor','flat');
mmfn
set(gca,'box', 'off', 'FontSize', 18,'LineWidth',1.5);
EdgeLine = set(Pre, 'EdgeColor','k','LineWidth',1.5);

Pre(1).FaceColor =  (convertRGB ([0, 252, 161]));
Pre(2).FaceColor =  (convertRGB ([0, 150, 0]));
Pre(3).FaceColor = (convertRGB ([7, 162, 245]));
Pre(4).FaceColor = (convertRGB ([158, 38, 38]));

hold on
PostNormalizedWork = NormalizedWork;
PostNormalizedWork(1:2,:)=NaN;
Post = bar(x,NormalizedWork,'FaceColor','flat');

Post(1).FaceColor =  (convertRGB ([0, 252, 161]));
Post(2).FaceColor =  (convertRGB ([0, 150, 0]));
Post(3).FaceColor = (convertRGB ([7, 162, 245]));
Post(4).FaceColor = (convertRGB ([158, 38, 38]));

if exist('YLabel')ylabel(YLabel)
end

ylim ([0 120])
hold on
%% error bars for bar graph
ngroups = size(NormalizedWork, 1);
nbars = size(NormalizedWork, 2);

% Calculating the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));
for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, NormalizedWork(:,i), zeros(size(NormalizedWork(:,i))),SEWork(:,i), '.', 'color','k');
end

%% plot velocity
yyaxis right
ax = gca;
set(ax.YAxis, 'Color', 'k')
  
 y2 = AvgVelocityMax;
 y2(end+1:length(x)) =0;
 ylabel('Average horizontal velocity (m/s)')
 VelPlot =plot(y2,'.','color','k','MarkerSize', 30);
 x = 1:length(y2);
 Eb = errorbar(x, AvgVelocityMax, zeros(size(AvgVelocityMax)),SEVelocityMax, '.', 'color','k');
 ylim ([0 8])
 Pre(1).FaceColor =  (convertRGB ([255, 255, 255])); % create 
 
 %% Legend and axis
lh = legend([Post(1) Post(2) Post(3) Post(4) VelPlot(1) Eb(1)],...
    'Hip (Swing)', 'Hip (Stance)','Knee','Ankle',...
    'horizontal velocity','SE', 'Location','best');
set(lh, 'FontSize' ,10,'Box','off');

title(TitleName)
xticklabels({'Baseline 1', 'Baseline 2' , 'Sprint 1', 'Sprint 2', 'Sprint 3', 'Sprint 4',...
    'Sprint 5', 'Sprint 6', 'Sprint 7', 'Sprint 8', 'Sprint 9', 'Sprint 10', 'Sprint 11',...
    'Sprint 12'})
xtickangle (45)



