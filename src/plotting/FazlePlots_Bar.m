muscle3 = [77.93, 0, 0, 0, 0]';
muscle4 = [78.11, 71.75, 0, 0,0]';
muscle5 = [77.13, 74.5, 67.1,0 ,0 ]';
muscle6 = [73.75, 74.6, 73.1, 62.2,0]';

muscle7 = [69.31, 70.7, 69.4, 72, 60.25]';
muscle0 = zeros(4,length(muscle7));

allMuscles = [muscle3(1,:) muscle4(1,:) muscle5(1,:) muscle6(1,:) muscle7(1,:);muscle0];
midPoint = median(1:size(allMuscles,2));
br = bar (allMuscles);
ylim([50,100])
hold on

% error bars 
m = allMuscles;
barSeries = 1;
ERROR = zeros(size(allMuscles));
ERROR(barSeries,:) = 1;
% Calculating the width for each bar group
ngroups = size(m, 1);
nbars = size(m, 2);
groupwidth = min(0.8, nbars/(nbars + 1.5));
for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, m(:,i), zeros(size(m(:,i))),ERROR(:,i), '.', 'color','k'); % only vertical error bars
%     errorbar(x, m(:,i),ERROR(:,i), '.', 'color','k'); % both error bars
end



%%

barSeries = 2;
muscle = [muscle3(barSeries,:) muscle4(barSeries,:) muscle5(barSeries,:) muscle6(barSeries,:) muscle7(barSeries,:)];
muscleidx = find(muscle);
muscle = muscle (muscleidx);
idx = 2;
idx = [idx:idx+length(muscle)-1];
m = zeros(size(allMuscles));
m(barSeries,idx) = muscle;
bb = bar (m);

for ii = 1:length(muscleidx)
bb(idx(ii)).FaceColor =  br(muscleidx(ii)).FaceColor;
end

% error bars 
ERROR = zeros(size(allMuscles));
ERROR(barSeries,idx) = 1;
% Calculating the width for each bar group
ngroups = size(m, 1);
nbars = size(m, 2);
groupwidth = min(0.8, nbars/(nbars + 1.5));
for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, m(:,i), zeros(size(m(:,i))),ERROR(:,i), '.', 'color','k'); % only vertical error bars
%     errorbar(x, m(:,i),ERROR(:,i), '.', 'color','k'); % both error bars
end





%% bars 3
barSeries = 3;
muscle = [muscle3(barSeries,:) muscle4(barSeries,:) muscle5(barSeries,:) muscle6(barSeries,:) muscle7(barSeries,:)];
muscleidx = find(muscle);
muscle = muscle (muscleidx);
idx = 2;
idx = [idx:idx+length(muscle)-1];
m = zeros(size(allMuscles));
m(barSeries,idx) = muscle;
bb = bar (m);
for ii = 1:length(muscleidx)
bb(idx(ii)).FaceColor =  br(muscleidx(ii)).FaceColor;
end

% error bars 
ERROR = zeros(size(allMuscles));
ERROR(barSeries,idx) = 1;
% Calculating the width for each bar group
ngroups = size(m, 1);
nbars = size(m, 2);
groupwidth = min(0.8, nbars/(nbars + 1.5));
for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, m(:,i), zeros(size(m(:,i))),ERROR(:,i), '.', 'color','k'); % only vertical error bars
%     errorbar(x, m(:,i),ERROR(:,i), '.', 'color','k'); % both error bars
end




%% bars 4

barSeries = 4;
muscle = [muscle3(barSeries,:) muscle4(barSeries,:) muscle5(barSeries,:) muscle6(barSeries,:) muscle7(barSeries,:)];
muscleidx = find(muscle);
muscle = muscle (muscleidx);
idx = 2;
idx = [idx:idx+length(muscle)-1];
m = zeros(size(allMuscles));
m(barSeries,idx) = muscle;
bb = bar (m);
for ii = 1:length(muscleidx)
bb(idx(ii)).FaceColor =  br(muscleidx(ii)).FaceColor;
end


% error bars 
ERROR = zeros(size(allMuscles));
ERROR(barSeries,idx) = 1;
% Calculating the width for each bar group
ngroups = size(m, 1);
nbars = size(m, 2);
groupwidth = min(0.8, nbars/(nbars + 1.5));
for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, m(:,i), zeros(size(m(:,i))),ERROR(:,i), '.', 'color','k'); % only vertical error bars
%     errorbar(x, m(:,i),ERROR(:,i), '.', 'color','k'); % both error bars
end


%% bars 5

barSeries = 5;
muscle = [muscle3(barSeries,:) muscle4(barSeries,:) muscle5(barSeries,:) muscle6(barSeries,:) muscle7(barSeries,:)];
muscleidx = find(muscle);
muscle = muscle (muscleidx);
idx = 3;
idx = [idx:idx+length(muscle)-1];
m = zeros(size(allMuscles));
m(barSeries,idx) = muscle;
bb = bar (m);
for ii = 1:length(muscleidx)
bb(idx(ii)).FaceColor =  br(muscleidx(ii)).FaceColor;
end


% error bars 
ERROR = zeros(size(allMuscles));
ERROR(barSeries,idx) = 1;
% Calculating the width for each bar group
ngroups = size(m, 1);
nbars = size(m, 2);
groupwidth = min(0.8, nbars/(nbars + 1.5));
for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, m(:,i), zeros(size(m(:,i))),ERROR(:,i), '.', 'color','k'); % only vertical error bars
%     errorbar(x, m(:,i),ERROR(:,i), '.', 'color','k'); % both error bars
end


%% labels and legend


lg = legend('Muscle 3','Muscle 4','Muscle 5','Muscle 6','Muscle 7');
set (lg, 'Box','off');

xticklabels ({'3 synergy','4 synergy','5 synergy','6 synergy','7 synergy'})
mmfn
