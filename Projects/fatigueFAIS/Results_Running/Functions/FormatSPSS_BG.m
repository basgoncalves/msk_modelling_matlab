% format data to SPSS - Joint Work Running
% Basilio Goncalves 2020

%create directories
DirC3D ='E:\3-FatigueFAIS\MocapData\InputData\029\pre';
OrganiseFAI;
cd(DirResults)
%load Mean Joint works
load('MaxRuningVelocity.mat')
load('MeanJointWork.mat');
load('SpatioTemporal.mat')
    
SPSSdata_work=[];
description = {};

Variables = {'PosWork','NegWork'};
[idx,~] = listdlg('PromptString',{'Choose ONLY ONE varibale to plot'}...
    ,'ListString',Variables);


WorkType = Variables{idx};
%% hip flexion positive work
joint = 'hip_flexion';
data = WorkPercentage.(joint).(WorkType)';
data (isnan(data))= 0;
data = deleteZeros(data,2);  %1 = all columns / 2= all rows 
Nrows = size(data,1);
% Hip flexion trial 1-2
newCol = data(:,1:2);
SPSSdata_work(1:Nrows,end+1) = (SubsCol(newCol));
description{1,end+1} = {sprintf('%s_1_2',joint)};


% Hip flexion trial 13-14
newCol = flip(data(:,13:14),2);  %flip horizontaly so last column comes fisrt
SPSSdata_work(1:Nrows,end+1) = (SubsCol(newCol));
description{1,end+1} = {sprintf('%s_13_14',joint)};

%% knee work
joint = 'knee';
data = WorkPercentage.(joint).(WorkType)';
data (isnan(data))= 0;
data = deleteZeros(data,2);  %1 = all columns / 2= all rows 
Nrows = size(data,1);
% trial 1-2
newCol = data(:,1:2);
SPSSdata_work(1:Nrows,end+1) = (SubsCol(newCol));
description{1,end+1} = {sprintf('%s_1_2',joint)};

% trial 13-14
newCol = flip(data(:,13:14),2);  %flip horizontaly so last column comes fisrt
SPSSdata_work(1:Nrows,end+1) = (SubsCol(newCol));
description{1,end+1} = {sprintf('%s_13_14',joint)};

%% ankle work
joint = 'ankle';
data = WorkPercentage.(joint).(WorkType)';
data (isnan(data))= 0;
data = deleteZeros(data,2);  %1 = all columns / 2= all rows 
Nrows = size(data,1);
% trial 1-2
newCol = data(:,1:2);
SPSSdata_work(1:Nrows,end+1) = (SubsCol(newCol));
description{1,end+1} = {sprintf('%s_1_2',joint)};

% trial 13-14
newCol = flip(data(:,13:14),2);  %flip horizontaly so last column comes fisrt
SPSSdata_work(1:Nrows,end+1) = (SubsCol(newCol));
description{1,end+1} = {sprintf('%s_13_14',joint)};

%%  Running velocity
joint = 'vel';
data = MaxRuningVelocity';
data (isnan(data))= 0;
data = deleteZeros(data,2);  %1 = all columns / 2= all rows 
Nrows = size(data,1);
% trial 1-2
newCol = data(:,1:2);
SPSSdata_work(1:Nrows,end+1) = (SubsCol(newCol));
description{1,end+1} =sprintf('%s_1_2',joint);
vel_1 = SPSSdata_work(1:Nrows,end);

% trial 13-14
newCol = flip(data(:,13:14),2);  %flip horizontaly so last column comes fisrt
SPSSdata_work(1:Nrows,end+1) = (SubsCol(newCol));
description{1,end+1} = sprintf('%s_13_14',joint);
vel_end = SPSSdata_work(1:Nrows,end);

% deltaVel
newCol = (vel_end - vel_1)./vel_1*100;
SPSSdata_work(1:Nrows,end+1) = (SubsCol(newCol));
description{1,end+1} = sprintf('deltaVel');



%% hip flexion burst 1 
if contains(WorkType,'PosWork') && sum(contains(fields(WorkPercentage),'hip_flexion_1'))==1
load('MeanJointWork_HipBursts.mat')
joint = 'hip_flexion_1';
data = WorkPercentage.(joint).(WorkType)';
data (isnan(data))= 0;
data = deleteZeros(data,2);  %1 = all columns / 2= all rows 
Nrows = size(data,1);
% trial 1-2
newCol = data(:,1:2);
SPSSdata_work(1:Nrows,end+1) = (SubsCol(newCol));
description{1,end+1} = {sprintf('%s_1_2',joint)};

% trial 13-14
newCol = flip(data(:,13:14),2);  %flip horizontaly so last column comes fisrt
SPSSdata_work(1:Nrows,end+1) = (SubsCol(newCol));
description{1,end+1} = {sprintf('%s_13_14',joint)};

end

%% hip flexion burst 2
if contains(WorkType,'PosWork') && sum(contains(fields(WorkPercentage),'hip_flexion_2'))==1
load('MeanJointWork_HipBursts.mat')
    
joint = 'hip_flexion_2';
data = WorkPercentage.(joint).(WorkType)';
data (isnan(data))= 0;
data = deleteZeros(data,2);  %1 = all columns / 2= all rows 
Nrows = size(data,1);
% trial 1-2
newCol = data(:,1:2);
SPSSdata_work(1:Nrows,end+1) = (SubsCol(newCol));
description{1,end+1} = {sprintf('%s_1_2',joint)};

% trial 13-14
newCol = flip(data(:,13:14),2);  %flip horizontaly so last column comes fisrt
SPSSdata_work(1:Nrows,end+1) = (SubsCol(newCol));
description{1,end+1} = {sprintf('%s_13_14',joint)};

end

%% delta hip 
First = SPSSdata_work(:,1);
Last = SPSSdata_work(:,2); 

newCol = (Last - First)./First*100;
SPSSdata_work(1:Nrows,end+1) = (SubsCol(newCol));
description{1,end+1} = sprintf('deltaHip');

% hip burst 1
First = SPSSdata_work(:,10);
Last = SPSSdata_work(:,11); 

newCol = (Last - First)./First*100;
SPSSdata_work(1:Nrows,end+1) = (SubsCol(newCol));
description{1,end+1} = sprintf('deltaHip_B1');

% hip burst 1
First = SPSSdata_work(:,12);
Last = SPSSdata_work(:,13); 

newCol = (Last - First)./First*100;
SPSSdata_work(1:Nrows,end+1) = (SubsCol(newCol));
description{1,end+1} = sprintf('deltaHip_B2');

%%  Step Length
joint = 'StepLength';
data = StepLength';
data (isnan(data))= 0;
data = deleteZeros(data,2);  %1 = all columns / 2= all rows 
Nrows = size(data,1);
% trial 1-2
newCol = data(:,1:2);
SPSSdata_work(1:Nrows,end+1) = (SubsCol(newCol));
description{1,end+1} =sprintf('%s_1_2',joint);


% trial 13-14
newCol = flip(data(:,13:14),2);  %flip horizontaly so last column comes fisrt
SPSSdata_work(1:Nrows,end+1) = (SubsCol(newCol));
description{1,end+1} = sprintf('%s_13_14',joint);

%%  Step Frequency
joint = 'StepFreq';
data = StepFreq';
data (isnan(data))= 0;
data = deleteZeros(data,2);  %1 = all columns / 2= all rows 
Nrows = size(data,1);
% trial 1-2
newCol = data(:,1:2);
SPSSdata_work(1:Nrows,end+1) = (SubsCol(newCol));
description{1,end+1} =sprintf('%s_1_2',joint);


% trial 13-14
newCol = flip(data(:,13:14),2);  %flip horizontaly so last column comes fisrt
SPSSdata_work(1:Nrows,end+1) = (SubsCol(newCol));
description{1,end+1} = sprintf('%s_13_14',joint);


%% save data

filename = sprintf ('SPSSdata_%s',WorkType);
save (filename, 'SPSSdata_work', 'description') 

%% figures pos work 
load('SPSSdata_PosWork.mat')
MeanWork = mean (SPSSdata_work);
SEWork = 1.96*(std(SPSSdata_work)./sqrt(size(SPSSdata_work,1)));

HipColor =  (convertRGB ([0, 252, 161]));
KneeColor = (convertRGB ([7, 162, 245]));
AnkleColor = (convertRGB ([158, 38, 38]));

% hip
col = [1:2];
x = [1,2];
y = MeanWork(col);
er = errorbar(x,y,SEWork(col), '.', 'color','k');
hold on
h1 = plot(x,y,'-ok','MarkerSize',8,'Color',HipColor);
set(h1,'MarkerFaceColor',HipColor);

% er = errorbar(x,y, zeros(size(y)),SEWork(col), '.', 'color','k'); % without the bottom error bars 


% knee
col = [3:4];
x = [1,2];
y = MeanWork(col);
er = errorbar(x,y, SEWork(col), '.', 'color','k');
h2 = plot(x,y,'-ob','MarkerSize',8,'Color',KneeColor);
 set(h2,'MarkerFaceColor',KneeColor);


% ankle
col = [5:6];
x = [1,2];
y = MeanWork(col);
er = errorbar(x,y, SEWork(col), '.', 'color','k');
h3= plot(x,y,'-or','MarkerSize',8,'Color',AnkleColor);
set(h3,'MarkerFaceColor',AnkleColor);


xlim ([0 3]); xticks([1 2]); xticklabels ({'Baseline','Last Set'})
ylim ([0 100])
ylabel ('% of total positive limb work')
mmfn
lh = legend([h1 h2 h3 er],'Hip','Knee','Ankle','95%CI', 'Location','best');
title ('Joint Positive Work (%)')

%% figures neg work 
load('SPSSdata_NegWork.mat')
MeanWork = mean (SPSSdata_work);
SEWork = 1.96*(std(SPSSdata_work)./sqrt(size(SPSSdata_work,1)));

% hip
col = [1:2];
x = [1,2];
y = MeanWork(col);
er = errorbar(x,y,SEWork(col), '.', 'color','k');
hold on
h1 = plot(x,y,'-ok','MarkerSize',8,'Color',HipColor);
set(h1,'MarkerFaceColor',HipColor);

% knee
col = [3:4];
x = [1,2];
y = MeanWork(col);
er = errorbar(x,y, SEWork(col), '.', 'color','k');
h2 = plot(x,y,'-ob','MarkerSize',8,'Color',KneeColor);
 set(h2,'MarkerFaceColor',KneeColor)


% ankle
col = [5:6];
x = [1,2];
y = MeanWork(col);
er = errorbar(x,y, SEWork(col), '.', 'color','k');
h3= plot(x,y,'-or','MarkerSize',8,'Color',AnkleColor);
set(h3,'MarkerFaceColor',AnkleColor);


xlim ([0 3]); xticks([1 2]); xticklabels ({'Baseline','Last Set'})
ylim ([0 100])
ylabel ('% of total negative work')
mmfn
lh = legend([h1 h2 h3 er],'Hip','Knee','Ankle','95%CI', 'Location','best');
title ('Joint negative limb work (%)')


%% correlation  Total vs Burst 1

[x,SelectedLabels,IDxData] = findData (SPSSdata_work,description,{'deltaHip'});
x = x(:,1);
[y,SelectedLabels,IDxData] = findData (SPSSdata_work,description,{'deltaHip_B1'});

[R,P]= corrcoef(x,y);

p = polyfit(x,y,1);                 % polynomial fucntion (https://au.mathworks.com/help/matlab/ref/polyfit.html#bue6sxq-1-y)

xPol = min(x):1:max(x);
PoliFunct = polyval(p,xPol)';
figure
plot(x,y,'.','MarkerSize',20,'Color', [0.25 0.25 0.25] )

hold on
plot(xPol,PoliFunct)
hold off
mmfn

xlabel('\Delta Hip Total Work(%)')
ylabel('\Delta Hip 1st Burst Work(%)')
title('(Hip Work) Pearson correlation Total vs Burst 1')
txt = sprintf('R = %.2f',R(1,2));
   TextR = text(max(xlim)*0.8,max(ylim)*0.8,txt);
set(TextR,'Rotation',0,'FontSize',20,'HorizontalAlignment','right','VerticalAlignment','top');

%% correlation  Hip Total vs Burst 2

[x,SelectedLabels,IDxData] = findData (SPSSdata_work,description,{'deltaHip'});
x = x(:,1);
[y,SelectedLabels,IDxData] = findData (SPSSdata_work,description,{'deltaHip_B2'});

[R,P]= corrcoef(x,y);

p = polyfit(x,y,1);                 % polynomial fucntion (https://au.mathworks.com/help/matlab/ref/polyfit.html#bue6sxq-1-y)

xPol = min(x):1:max(x);
PoliFunct = polyval(p,xPol)';
figure
plot(x,y,'.','MarkerSize',20,'Color', [0.25 0.25 0.25] )

hold on
plot(xPol,PoliFunct)
hold off
mmfn

xlabel('\Delta Hip Total Work(%)')
ylabel('\Delta Hip 2nd Burst Work(%)')
title('(Hip Work) Pearson correlation Total vs Burst 2')
txt = sprintf('R = %.2f',R(1,2));
   TextR = text(max(xlim)*0.8,max(ylim)*0.8,txt);
set(TextR,'Rotation',0,'FontSize',20,'HorizontalAlignment','right','VerticalAlignment','top');


%% correlation  Hip Total vs deltaVel

[x,SelectedLabels,IDxData] = findData (SPSSdata_work,description,{'deltaHip'});
x = x(:,1);
[y,SelectedLabels,IDxData] = findData (SPSSdata_work,description,{'deltaVel'});

[R,P]= corrcoef(x,y);

p = polyfit(x,y,1);                 % polynomial fucntion (https://au.mathworks.com/help/matlab/ref/polyfit.html#bue6sxq-1-y)

xPol = min(x):1:max(x);
PoliFunct = polyval(p,xPol)';
figure
plot(x,y,'.','MarkerSize',20,'Color', [0.25 0.25 0.25] )

hold on
plot(xPol,PoliFunct)
hold off
mmfn

xlabel('\Delta Hip Work(%)')
ylabel('\Delta Running speed(%)')
title('Pearson correlation Total Hip Work vs Speed')
txt = sprintf('R = %.2f',R(1,2));
   TextR = text(max(xlim)*0.8,max(ylim)*0.8,txt);
set(TextR,'Rotation',0,'FontSize',20,'HorizontalAlignment','right','VerticalAlignment','top');

%% correlation  Hip Burst 1 vs deltaVel

[x,SelectedLabels,IDxData] = findData (SPSSdata_work,description,{'deltaHip_B1'});
x = x(:,1);
[y,SelectedLabels,IDxData] = findData (SPSSdata_work,description,{'deltaVel'});

[R,P]= corrcoef(x,y);

p = polyfit(x,y,1);                 % polynomial fucntion (https://au.mathworks.com/help/matlab/ref/polyfit.html#bue6sxq-1-y)

xPol = min(x):1:max(x);
PoliFunct = polyval(p,xPol)';
figure
plot(x,y,'.','MarkerSize',20,'Color', [0.25 0.25 0.25] )

hold on
plot(xPol,PoliFunct)
hold off
mmfn

xlabel('\Delta Hip Work Burst 1(%)')
ylabel('\Delta Running speed(%)')
title('Pearson correlation Hip Work Burst 1 vs Speed')
txt = sprintf('R = %.2f',R(1,2));
   TextR = text(max(xlim)*0.8,max(ylim)*0.8,txt);
set(TextR,'Rotation',0,'FontSize',20,'HorizontalAlignment','right','VerticalAlignment','top');


%% correlation  Hip Burst 2 vs deltaVel

[x,SelectedLabels,IDxData] = findData (SPSSdata_work,description,{'deltaHip_B2'});
x = x(:,1);
[y,SelectedLabels,IDxData] = findData (SPSSdata_work,description,{'deltaVel'});

[R,P]= corrcoef(x,y);

p = polyfit(x,y,1);                 % polynomial fucntion (https://au.mathworks.com/help/matlab/ref/polyfit.html#bue6sxq-1-y)

xPol = min(x):1:max(x);
PoliFunct = polyval(p,xPol)';
figure
plot(x,y,'.','MarkerSize',20,'Color', [0.25 0.25 0.25] )

hold on
plot(xPol,PoliFunct)
hold off
mmfn

xlabel('\Delta Hip Work Burst 2(%)')
ylabel('\Delta Running speed(%)')
title('Pearson correlation Hip Work Burst 2 vs Speed')
txt = sprintf('R = %.2f',R(1,2));
   TextR = text(max(xlim)*0.8,max(ylim)*0.8,txt);
set(TextR,'Rotation',0,'FontSize',20,'HorizontalAlignment','right','VerticalAlignment','top');

