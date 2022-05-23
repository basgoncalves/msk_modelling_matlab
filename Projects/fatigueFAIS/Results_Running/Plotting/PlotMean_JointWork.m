% PlotMean_JointWork

cd(DirResults)
load('JointWorks.mat')
load ('SpatioTemporal.mat')

%% define which variables to use
Variables = {'hip_flexion','knee','ankle','hip_flexion_1','hip_flexion_2'};
    [idx,~] = listdlg('PromptString',{'Choose the correct peaks'}...
        ,'ListString',Variables);
    
JointMotion = Variables(idx);
if contains(JointMotion(2),'knee')
savefilename = 'MeanJointWork';
else 
savefilename = 'MeanJointWork_HipBursts';
end

%%
Nmoments = length(JointMotion);
fs = 200;

MeanJointWork = struct;
SDJointWork = struct;
variables = fields(JointWorks.(JointMotion{end}));
load([DirResults filesep 'MaxRuningVelocity.mat']);
MaxRuningVelocity(MaxRuningVelocity==0)=NaN;
MaxRuningVelocityPercentage = MaxRuningVelocity./max(MaxRuningVelocity(1:2,:));
MaxRuningVelocityPercentage(:, ~any(MaxRuningVelocityPercentage,1) ) = [];  % delete empty columns

AvgVelocityMax = nanmean(MaxRuningVelocity,2);
StdVelocityMax = nanstd(MaxRuningVelocity,0,2);

AvgStepLength = nanmean(StepLength,2);
StdStepLength = nanstd(StepLength,0,2);

AvgStepFreq = nanmean(StepFreq,2);
StdStepFreq = nanstd(StepFreq,0,2);

TotalWork = struct;
MeanWorkPercentage=struct;
SDWorkPercentage=struct;
WorkPercentage = struct;

for vv = 1:length(variables)
    VarName = variables{vv};
    PreviousVar = 0;
    for mm = 1:Nmoments                                        % loop through hip flexion, knee and ankle
        MomentName = JointMotion{mm};
        CurrentVar = JointWorks.(MomentName).(VarName);
        CurrentVar(isnan(CurrentVar))= 0;
        TotalWork.(VarName) = CurrentVar+PreviousVar;           % total positive/negative/net work = hip + knee + ankle
        PreviousVar = TotalWork.(VarName);
        
        MeanJointWork.Labels{mm} = MomentName;
        MeanJointWork.(VarName)(:,mm) = nanmean(CurrentVar,2);
        SDJointWork.(VarName)(:,mm) = nanstd(CurrentVar,0,2);
    end
    
    %Mean work in percentage
    for  mm = 1:Nmoments
        MomentName = JointMotion{mm};
        CurrentVar = JointWorks.(MomentName).(VarName);
        CurrentVar(isnan(CurrentVar))= 0;
        WorkPercentage.(MomentName).(VarName)=CurrentVar ./ TotalWork.(VarName)*100;
        MeanWorkPercentage.Labels{mm} = MomentName;
        MeanWorkPercentage.(VarName)(:,mm) = nanmean(CurrentVar ./ TotalWork.(VarName)*100,2);
        SDWorkPercentage.(VarName)(:,mm) =nanstd(CurrentVar ./ TotalWork.(VarName)*100,0,2);
    end    
    
end
 

 %mean every 2 columns 
 Mean2WorkPercentage = struct;
 for vv = 1:length(variables)
    VarName = variables{vv};
    PreviousVar = 0;
    for mm = 1:Nmoments  
        MomentName = JointMotion{mm};
        CurrentVar = JointWorks.(MomentName).(VarName)';
        CurrentVar = deleteZeros (CurrentVar,2); %2 = delete each row with zeros
        Mean2WorkPercentage.(MomentName).(VarName)=MeanNcol (CurrentVar,2);;
    end
 end
 
 

save (savefilename, 'WorkPercentage','MeanJointWork','SDJointWork','TotalWork','MeanWorkPercentage','SDWorkPercentage','Mean2WorkPercentage')


%% plot positive work Percentage - sagital plane only

NormalizedWork = MeanWorkPercentage.PosWork; 
stdWork = SDWorkPercentage.PosWork;
% make always 3 columns 
if size(NormalizedWork,2)<3
    finalCol = size(NormalizedWork,2)+1;
    NormalizedWork(:,finalCol:3)= 0;
    stdWork(:,finalCol:3)= 0;
end

TitleName = 'Relative joint positive work';
Ylabel = '% of total positive limb work';
plotBarWork (NormalizedWork, stdWork,AvgVelocityMax,StdVelocityMax,TitleName,Ylabel)
cd([DirFigure filesep 'RunningBiomechanics'])
saveas(gca, sprintf('%s.jpeg',TitleName));

%% plot positive work Absolute (J/Kg) - sagital plane only

NormalizedWork = MeanJointWork.PosWork;           
stdWork = SDJointWork.PosWork;
% make always 3 columns 
if size(NormalizedWork,2)<3
    finalCol = size(NormalizedWork,2)+1
    NormalizedWork(:,finalCol:3)= 0;
    stdWork(:,finalCol:3)= 0;
end

TitleName = 'Absolute positive work';
Ylabel = 'Work (J/Kg)';
plotBarWork (NormalizedWork, stdWork,AvgVelocityMax,StdVelocityMax,TitleName,Ylabel)
yyaxis left 
ylim([0 max(max(NormalizedWork))+max(max(stdWork))])
cd([DirFigure filesep 'RunningBiomechanics'])
saveas(gca, sprintf('%s.jpeg',TitleName));  

%% plot positive work Percentage - sagital plane only (with step length)

NormalizedWork = MeanWorkPercentage.PosWork;           
stdWork = SDWorkPercentage.PosWork;
TitleName = 'Relative joint positive work - with step length';
Ylabel = '% of Total Work';
plotBarWork (NormalizedWork, stdWork,AvgStepLength,StdStepLength,TitleName,Ylabel)
yyaxis right; ylabel ('Step length (m)'); ylim([0 2])
lh = legend; lh.String{5}= 'Step Length';
cd([DirFigure filesep 'RunningBiomechanics'])
saveas(gca, sprintf('%s.jpeg',TitleName));

%% plot positive work Percentage - sagital plane only (with step frequency)

NormalizedWork = MeanWorkPercentage.PosWork;           
stdWork = SDWorkPercentage.PosWork;
TitleName = 'Relative joint positive work - with step frequency';
Ylabel = '% of Total Work';
plotBarWork (NormalizedWork, stdWork,AvgStepFreq,StdStepFreq,TitleName,Ylabel)
yyaxis right; ylabel ('Step frequency (Hz)'); ylim([0,2.5])
lh = legend; lh.String{5}= 'Step Frequency';
cd([DirFigure filesep 'RunningBiomechanics'])
saveas(gca, sprintf('%s.jpeg',TitleName));

%% plot negative work Percentage - sagital plane only

NormalizedWork = MeanWorkPercentage.NegWork;           
stdWork = SDWorkPercentage.NegWork;
TitleName = 'Relative joint negative work';
Ylabel = '% of Total Work';
plotBarWork (NormalizedWork, stdWork,AvgVelocityMax,StdVelocityMax,TitleName,Ylabel)
cd([DirFigure filesep 'RunningBiomechanics'])
saveas(gca, sprintf('%s.jpeg',TitleName));

%% plot negative work Absolute (J/Kg) - sagital plane only

NormalizedWork = abs(MeanJointWork.NegWork);           
stdWork = SDJointWork.NegWork;
TitleName = 'Absolute joint negative limb work';
Ylabel = 'Work (J/Kg)';
plotBarWork (NormalizedWork, stdWork,AvgVelocityMax,StdVelocityMax,TitleName,Ylabel)
yyaxis left 
ylim([0 max(max(NormalizedWork))+max(max(stdWork))])
cd([DirFigure filesep 'RunningBiomechanics'])
saveas(gca, sprintf('%s.jpeg',TitleName));  

%% plot positive work Percentage - HIP BURSTS
if contains(JointMotion, 'hip_flexion_1')

NormalizedWork = MeanWorkPercentage.PosWork; 
stdWork = SDWorkPercentage.PosWork;
% make always 3 columns 
if size(NormalizedWork,2)<3
    finalCol = size(NormalizedWork,2)+1;
    NormalizedWork(:,finalCol:3)= 0;
    stdWork(:,finalCol:3)= 0;
end

TitleName = 'Relative joint positive work - Hip Bursts';
Ylabel = '% of total positive limb work';
plotBarWork (NormalizedWork, stdWork,AvgVelocityMax,StdVelocityMax,TitleName,Ylabel)

lh = legend;
set (lh,'String',{'Pre fatigue trials', 'Hip joint work - 1st burst ','Hip joint work - 2nd burst','','horizontal velocity','SE'});
cd([DirFigure filesep 'RunningBiomechanics'])
saveas(gca, sprintf('%s.jpeg',TitleName));
end
%% plot positive work Percentage - HIP BURSTS + KNEE + ANKLE
if contains(JointMotion, 'hip_flexion_1')
NormalizedWork(:,1:2) = MeanWorkPercentage.PosWork(:,3:4); % swap last two columns to the beginning ( hip1 hip2 knee ankle)
NormalizedWork(:,3:4) = MeanWorkPercentage.PosWork(:,1:2); 

stdWork(:,1:2) = SDWorkPercentage.PosWork(:,3:4); 
stdWork(:,3:4) = SDWorkPercentage.PosWork(:,1:2); 


TitleName = 'Relative joint positive work - Hip Bursts + Knee + Ankle';
Ylabel = '% of Total Work';
plotBarWork_4 (NormalizedWork, stdWork,AvgVelocityMax,StdVelocityMax,TitleName,Ylabel)

lh = legend;
set (lh,'String',{'Pre fatigue trials', 'Hip joint work - 1st burst ','Hip joint work - 2nd burst','','horizontal velocity','SE'});
cd([DirFigure filesep 'RunningBiomechanics'])
saveas(gca, sprintf('%s.jpeg',TitleName));
end
 %% plot positive work as function of total work 
figure

for ii = 1:3
subplot (1,3,ii)
Y = JointWorks.(JointMotion{ii}).PosWork;
Y(Y==0)=NaN;  Y = Y(:); 
X = TotalWork.PosWork;
X(X==0)=NaN;  X = X(:);

P = plot(X,Y,'.','MarkerSize',12,'Color', 'k');
mmfn
title(sprintf('%s',strrep(JointMotion{ii},'_',' ')))
xlabel('Total Positive Work (J/kg)')
ylabel('Positive Joint Work (J/kg)')

% xlim([0 1])
% ylim([0 0.5])
end
fullscreenFig(0.8,0.8) % callback function


cd([DirFigure filesep 'RunningBiomechanics'])
saveas(gca, sprintf('correlationPositiveJointWork.jpeg'));

%% plot positive work as function of speed

figure

for ii = 1:3
subplot (1,3,ii)
Y = JointWorks.(JointMotion{ii}).PosWork;
Y(Y==0)=NaN;  Y = Y(:); 
X = MaxRuningVelocity;
X(X==0)=NaN;  X = X(:);

P = plot(X,Y,'.','MarkerSize',12,'Color', 'k');
mmfn
title(sprintf('%s',strrep(JointMotion{ii},'_',' ')))
xlabel('Max Running velocity (m/s)')
ylabel('Positive Joint Work (J/kg)')

% xlim([0 1])
% ylim([0 0.5])
end
fullscreenFig(0.8,0.8) % callback function


cd([DirFigure filesep 'RunningBiomechanics'])
saveas(gca, sprintf('correlationPositiveWork_speed.jpeg'));

%% plot positive work PERCENTAGE as function of speed

figure

for ii = 1:3
      
subplot (1,3,ii)
Y = WorkPercentage.(JointMotion{ii}).PosWork;
Y(Y==0)=NaN;  Y = Y(:); 
X = MaxRuningVelocity;
X(X==0)=NaN;  X = X(:);
Y(isnan(X))=[];X(isnan(X))=[];

P = plot(X,Y,'.','MarkerSize',12,'Color', 'k');
mmfn
title(sprintf('%s',strrep(JointMotion{ii},'_',' ')))
xlabel('Max Running velocity (m/s)')
ylabel('Positive Joint Work %')

% xlim([0 1])
% ylim([0 0.5])
end
fullscreenFig(0.8,0.8) % callback function


cd([DirFigure filesep 'RunningBiomechanics'])
saveas(gca, sprintf('correlationPositiveWork_speed.jpeg'));

%% fix size of Joint works and powers
% 
% % delete JointWork cells
% Names = fields (JointWorks);
% Nnames = length(Names);
% 
% for ii = 1:Nnames
%    subNames = fields(JointWorks.(Names{ii}));
%    
%    for ss = 1:length(subNames)
%        JointWorks.(Names{ii}).(subNames{ss})(15:18,:)=0;
%        JointWorks.(Names{ii}).(subNames{ss})(15:18,:)=[];
%    end
%     
%     
% end
% 
% 
% % delete JointPower cells
% Names = fields (JointWorks);
% Nnames = length(Names);
% 
% for ii = 1:Nnames
%    subNames = fields(JointWorks.(Names{ii}));
%    
%    for ss = 1:length(subNames)
%        JointWorks.(Names{ii}).(subNames{ss})(15:18,:)=0;
%        JointWorks.(Names{ii}).(subNames{ss})(15:18,:)=[];
%    end
%     
%     
% end