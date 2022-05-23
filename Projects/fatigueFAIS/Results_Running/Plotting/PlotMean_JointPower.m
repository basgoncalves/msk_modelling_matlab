% PlotMean_JointPower
cd(DirResults)
load('JointPowers.mat')
load ('SpatioTemporal.mat')

%% define which variables to use
Variables = {'hip_flexion','knee','ankle','hip_flexion_1','hip_flexion_2'};
    [idx,~] = listdlg('PromptString',{'Choose the correct peaks'}...
        ,'ListString',Variables);
    
JointMotion = Variables(idx);
if contains(JointMotion(2),'knee')
savefilename = 'MeanJointPower';
else 
savefilename = 'MeanJointPower_HipBursts';
end

%%
Nmoments = length(JointMotion);
fs = 200;


variables = fields(JointPowers.(JointMotion{end}));
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

MeanPowerPercentage=struct;
SDPowerPercentage=struct;
PowerPercentage = struct;

MeanJointPower = struct;
SDJointPower = struct;
for mm = 1:Nmoments                                        % loop through hip flexion, knee and ankle
    
    MomentName = JointMotion{mm};
    CurrentVar = JointPowers.(MomentName).(VarName);
    for tt = 1:14                                          % loop through all the 14 trials
        TrialPowers=[];
        for pp = 1: length(CurrentVar)
            if ~isempty(CurrentVar{pp})
                
                CurrentVar{pp}(CurrentVar{pp}==0)=NaN;
                ParticipantTrial = TimeNorm(CurrentVar{pp}(:,tt),fs);
                
                TrialPowers(1:length(ParticipantTrial),end+1) = ParticipantTrial;
                
                
            end
        end
        MeanJointPower.Labels{tt} = sprintf('%s_%.f',MomentName,tt);
        
        MeanJointPower.(MomentName)(:,tt) = nanmean(TrialPowers,2);
        SDJointPower.Labels{tt}= sprintf('%s_%.f',MomentName,tt);
        SDJointPower.(MomentName)(:,tt) = nanstd(TrialPowers',1)';
        
        
    end
    
end
 


 cd(DirResults)

save (savefilename,'MeanJointPower','SDJointPower')


%% plot power trial 1 vs trial 14 - hip 

    
MomentName = 'hip_flexion';
MeanPower = MeanJointPower.(MomentName);
SDPower = SDJointPower.(MomentName);
H1 = figure;
lineColor{1} = 'r';
lineColor{14} = 'b';
for tt = [1,14]                                          % loop through all the 14 trials (columns)
    x = (1:1:101)';
    y = MeanPower(:,tt);
    e = SDPower(:,tt);
    
    
    y = -MeanPower(:,tt)';
    y(isnan(y))=[];
    x = (1:1:length(y));    
    std_dev = SDPower(:,tt)';
    std_dev(isnan(std_dev))=[];
    curve1 = y + std_dev;
    curve2 = y - std_dev;
    x2 = [x, fliplr(x)];
    inBetween = [curve1, fliplr(curve2)];
    MeanPlot(tt)=plot(x, y, lineColor{tt}, 'LineWidth', 2);
    hold on
    SDPlot(tt)= fill(x2, inBetween, [5 5 5]/255);    
    alpha (0.1)

    
end
legend('Mean Baseline','SD Baseline','Mean last sprint','SD last srpint')
mmfn
title (sprintf('%s Joint Power (W\kg)',strrep(MomentName,'_',' ')))

xlabel('Gait cycle %')
    






NormalizedPower = MeanPowerPercentage.PosPower; 
stdPower = SDPowerPercentage.PosPower;
% make always 3 columns 
if size(NormalizedPower,2)<3
    finalCol = size(NormalizedPower,2)+1;
    NormalizedPower(:,finalCol:3)= 0;
    stdPower(:,finalCol:3)= 0;
end

TitleName = 'Relative joint positive power';
Ylabel = '% of Total Power';
plotBarPower (NormalizedPower, stdPower,AvgVelocityMax,StdVelocityMax,TitleName,Ylabel)
cd([DirFigure filesep 'RunningBiomechanics'])
saveas(gca, sprintf('%s.jpeg',TitleName));

%% plot positive power Absolute (J/Kg) - sagital plane only

NormalizedPower = MeanJointPower.PosPower;           
stdPower = SDJointPower.PosPower;
% make always 3 columns 
if size(NormalizedPower,2)<3
    finalCol = size(NormalizedPower,2)+1
    NormalizedPower(:,finalCol:3)= 0;
    stdPower(:,finalCol:3)= 0;
end

TitleName = 'Absolute positive power';
Ylabel = 'Power (J/Kg)';
plotBarPower (NormalizedPower, stdPower,AvgVelocityMax,StdVelocityMax,TitleName,Ylabel)
yyaxis left 
ylim([0 max(max(NormalizedPower))+max(max(stdPower))])
cd([DirFigure filesep 'RunningBiomechanics'])
saveas(gca, sprintf('%s.jpeg',TitleName));  

%% plot positive power Percentage - sagital plane only (with step length)

NormalizedPower = MeanPowerPercentage.PosPower;           
stdPower = SDPowerPercentage.PosPower;
TitleName = 'Relative joint positive power - with step length';
Ylabel = '% of Total Power';
plotBarPower (NormalizedPower, stdPower,AvgStepLength,StdStepLength,TitleName,Ylabel)
yyaxis right; ylabel ('Step length (m)'); ylim([0 2])
lh = legend; lh.String{5}= 'Step Length';
cd([DirFigure filesep 'RunningBiomechanics'])
saveas(gca, sprintf('%s.jpeg',TitleName));

%% plot positive power Percentage - sagital plane only (with step frequency)

NormalizedPower = MeanPowerPercentage.PosPower;           
stdPower = SDPowerPercentage.PosPower;
TitleName = 'Relative joint positive power - with step frequency';
Ylabel = '% of Total Power';
plotBarPower (NormalizedPower, stdPower,AvgStepFreq,StdStepFreq,TitleName,Ylabel)
yyaxis right; ylabel ('Step frequency (Hz)'); ylim([0,2.5])
lh = legend; lh.String{5}= 'Step Frequency';
cd([DirFigure filesep 'RunningBiomechanics'])
saveas(gca, sprintf('%s.jpeg',TitleName));

%% plot negative power Percentage - sagital plane only

NormalizedPower = MeanPowerPercentage.NegPower;           
stdPower = SDPowerPercentage.NegPower;
TitleName = 'Relative joint negative power';
Ylabel = '% of Total Power';
plotBarPower (NormalizedPower, stdPower,AvgVelocityMax,StdVelocityMax,TitleName,Ylabel)
cd([DirFigure filesep 'RunningBiomechanics'])
saveas(gca, sprintf('%s.jpeg',TitleName));

%% plot negative power Absolute (J/Kg) - sagital plane only

NormalizedPower = abs(MeanJointPower.NegPower);           
stdPower = SDJointPower.NegPower;
TitleName = 'Absolute joint negative power';
Ylabel = 'Power (J/Kg)';
plotBarPower (NormalizedPower, stdPower,AvgVelocityMax,StdVelocityMax,TitleName,Ylabel)
yyaxis left 
ylim([0 max(max(NormalizedPower))+max(max(stdPower))])
cd([DirFigure filesep 'RunningBiomechanics'])
saveas(gca, sprintf('%s.jpeg',TitleName));  

%% plot positive power Percentage - HIP BURSTS

NormalizedPower = MeanPowerPercentage.PosPower; 
stdPower = SDPowerPercentage.PosPower;
% make always 3 columns 
if size(NormalizedPower,2)<3
    finalCol = size(NormalizedPower,2)+1;
    NormalizedPower(:,finalCol:3)= 0;
    stdPower(:,finalCol:3)= 0;
end

TitleName = 'Relative joint positive power - Hip Bursts';
Ylabel = '% of Total Power';
plotBarPower (NormalizedPower, stdPower,AvgVelocityMax,StdVelocityMax,TitleName,Ylabel)

lh = legend;
set (lh,'String',{'Pre fatigue trials', 'Hip joint power - 1st burst ','Hip joint power - 2nd burst','','horizontal velocity','SE'});
cd([DirFigure filesep 'RunningBiomechanics'])
saveas(gca, sprintf('%s.jpeg',TitleName));

%% plot positive power Percentage - HIP BURSTS + KNEE + ANKLE

NormalizedPower(:,1:2) = MeanPowerPercentage.PosPower(:,3:4); % swap last two columns to the beginning ( hip1 hip2 knee ankle)
NormalizedPower(:,3:4) = MeanPowerPercentage.PosPower(:,1:2); 

stdPower(:,1:2) = SDPowerPercentage.PosPower(:,3:4); 
stdPower(:,3:4) = SDPowerPercentage.PosPower(:,1:2); 


TitleName = 'Relative joint positive power - Hip Bursts + Knee + Ankle';
Ylabel = '% of Total Power';
plotBarPower_4 (NormalizedPower, stdPower,AvgVelocityMax,StdVelocityMax,TitleName,Ylabel)

lh = legend;
set (lh,'String',{'Pre fatigue trials', 'Hip joint power - 1st burst ','Hip joint power - 2nd burst','','horizontal velocity','SE'});
cd([DirFigure filesep 'RunningBiomechanics'])
saveas(gca, sprintf('%s.jpeg',TitleName));

 %% plot positive power as function of total power 
figure

for ii = 1:3
subplot (1,3,ii)
Y = JointPowers.(JointMotion{ii}).PosPower;
Y(Y==0)=NaN;  Y = Y(:); 
X = TotalPower.PosPower;
X(X==0)=NaN;  X = X(:);

P = plot(X,Y,'.','MarkerSize',12,'Color', 'k');
mmfn
title(sprintf('%s',strrep(JointMotion{ii},'_',' ')))
xlabel('Total Positive Power (J/kg)')
ylabel('Positive Joint Power (J/kg)')

% xlim([0 1])
% ylim([0 0.5])
end
fullscreenFig(0.8,0.8) % callback function


cd([DirFigure filesep 'RunningBiomechanics'])
saveas(gca, sprintf('correlationPositiveJointPower.jpeg'));

%% plot positive power as function of speed

figure

for ii = 1:3
subplot (1,3,ii)
Y = JointPowers.(JointMotion{ii}).PosPower;
Y(Y==0)=NaN;  Y = Y(:); 
X = MaxRuningVelocity;
X(X==0)=NaN;  X = X(:);

P = plot(X,Y,'.','MarkerSize',12,'Color', 'k');
mmfn
title(sprintf('%s',strrep(JointMotion{ii},'_',' ')))
xlabel('Max Running velocity (m/s)')
ylabel('Positive Joint Power (J/kg)')

% xlim([0 1])
% ylim([0 0.5])
end
fullscreenFig(0.8,0.8) % callback function


cd([DirFigure filesep 'RunningBiomechanics'])
saveas(gca, sprintf('correlationPositivePower_speed.jpeg'));

%% plot positive power PERCENTAGE as function of speed

figure

for ii = 1:3
      
subplot (1,3,ii)
Y = PowerPercentage.(JointMotion{ii}).PosPower;
Y(Y==0)=NaN;  Y = Y(:); 
X = MaxRuningVelocity;
X(X==0)=NaN;  X = X(:);
Y(isnan(X))=[];X(isnan(X))=[];

P = plot(X,Y,'.','MarkerSize',12,'Color', 'k');
mmfn
title(sprintf('%s',strrep(JointMotion{ii},'_',' ')))
xlabel('Max Running velocity (m/s)')
ylabel('Positive Joint Power %')

% xlim([0 1])
% ylim([0 0.5])
end
fullscreenFig(0.8,0.8) % callback function


cd([DirFigure filesep 'RunningBiomechanics'])
saveas(gca, sprintf('correlationPositivePower_speed.jpeg'));

%% fix size of Joint powers and powers
% 
% % delete JointPower cells
% Names = fields (JointPowers);
% Nnames = length(Names);
% 
% for ii = 1:Nnames
%    subNames = fields(JointPowers.(Names{ii}));
%    
%    for ss = 1:length(subNames)
%        JointPowers.(Names{ii}).(subNames{ss})(15:18,:)=0;
%        JointPowers.(Names{ii}).(subNames{ss})(15:18,:)=[];
%    end
%     
%     
% end
% 
% 
% % delete JointPower cells
% Names = fields (JointPowers);
% Nnames = length(Names);
% 
% for ii = 1:Nnames
%    subNames = fields(JointPowers.(Names{ii}));
%    
%    for ss = 1:length(subNames)
%        JointPowers.(Names{ii}).(subNames{ss})(15:18,:)=0;
%        JointPowers.(Names{ii}).(subNames{ss})(15:18,:)=[];
%    end
%     
%     
% end