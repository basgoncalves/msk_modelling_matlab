
function PlotRRA(trial,prefix)

initiate_JCFFAIS
load('RRAresults.mat')
savedir = [cd fp 'RRA' fp trial]; mkdir(savedir);

Ylabels={'N' 'Nm'};
plotMaxResiduals(CEINMSData,RRAresults,'peak',trial,prefix,Ylabels, savedir)
plotMaxResiduals(CEINMSData,RRAresults,'RMS',trial,prefix,Ylabels, savedir)

plotFinalResidualsFromLog(CEINMSData,RRAresults,'peak',trial,Ylabels, savedir)
plotFinalResidualsFromLog(CEINMSData,RRAresults,'RMS',trial,Ylabels, savedir)


plotTimeVariant(RRAresults,trial,prefix,Ylabels,savedir)

%%                                                  CALLBACK FUNCTIONS
function plotMaxResiduals(CEINMSData,RRAresults,calculation,trial,prefix,Ylabels,savedir)
%% peak values
fp = filesep;
Nparticipants = length(CEINMSData.participantsGroups);
variablesIN = fields(RRAresults.(prefix));

[Residuals,IndivData] = createTable(CEINMSData,RRAresults,calculation,trial,prefix);

% PP = plotBGset(Residuals,4); PP.ylabel = {'N/Nm'}; PP.title = {'full gait cycle'}; close all; figure
% [FigList,Normality,Anova,Bonf,MD] = BarBG_Dataset(Residuals,variablesOUT,PP,1,savedir);

BarColors= [1 0 0; 0 0 1]; %red, blue

if contains(calculation,'peak')
    Title = 'peak stance';
elseif contains(calculation,'RMS')
    Title = 'RMS stance';
end

Ncomparions = 2;
ResultantGRF = sqrt(CEINMSData.GRF.AP.(trial).^2+CEINMSData.GRF.V.(trial).^2+CEINMSData.GRF.ML.(trial).^2);
PeakGRF = repmat(max(ResultantGRF,[],1),1,Ncomparions);
PeakGRF_x = repmat(max(CEINMSData.GRF.AP.(trial),[],1),1,Ncomparions);
PeakGRF_y = repmat(max(CEINMSData.GRF.V.(trial),[],1),1,Ncomparions);
PeakGRF_z = repmat(max(CEINMSData.GRF.ML.(trial),[],1),1,Ncomparions);

NormalizedIndivData = IndivData;
NormalizedIndivData(:,2)=NormalizedIndivData(:,2)./PeakGRF'*100;
NormalizedIndivData(:,3)=NormalizedIndivData(:,3)./PeakGRF'*100;
NormalizedIndivData(:,4)=NormalizedIndivData(:,4)./PeakGRF'*100;

LG = {'Original' 'CEINMS'};
figure;
BarBG_ind (NormalizedIndivData(:,[1:4]),Ylabels(1),{'Fx' 'Fy' 'Fz'},Title,LG,10,8,[] ,BarColors);
saveas(gcf,[savedir fp calculation '_' prefix '_pelvis_translation.jpeg']);

figure
BarBG_ind (IndivData(:,[1 5:7]),Ylabels(2),{'pelvis_tilt','pelvis_list','pelvis_rotation'},Title,LG,10,8,[],BarColors);
saveas(gcf,[savedir fp calculation '_' prefix '_pelvis_rotation.jpeg']);

figure
BarBG_ind (IndivData(:,[1 8:12]),Ylabels(2),{'hip_flexion','hip_adduction','hip_rotation','knee_angle','ankle_angle'},Title,LG,10,8,[],BarColors);
saveas(gcf,[savedir fp calculation '_' prefix '_hip_knee_ankle.jpeg']);


[means(1),se(1),sd(1),~,cipervar] = grpstats(Residuals.pelvis_tilt_CEINMS,[],{'mean','sem','std','gname','meanci'},'Alpha',0.05);
[means(2),se(2),sd(2),~,cipervar] = grpstats(Residuals.pelvis_tilt_Original,[],{'mean','sem','std','gname','meanci'},'Alpha',0.05);

function plotTimeVariant(RRAresults,trial,prefix,Ylabels,savedir)
%% curves
fp = filesep;
variablesIN = fields(RRAresults.(prefix));
Nparticipants = length(RRAresults.Participants);

Nvar = length(variablesIN);
[ha, pos,FirstCol,LastRow,LastCol] = tight_subplotBG(Nvar, 0, 0.05, 0.05, 0.05,0);
[ha_mean, pos,FirstCol,LastRow,LastCol] = tight_subplotBG(Nvar, 0, 0.05, 0.05, 0.05,0);
mmfn_inspect
for v = 1:Nvar
    OGdata = []; RRAdata =[]; CEINMSdata=[];
    Var = variablesIN{v};
    for n = 1:Nparticipants
    OGdata(:,n) = TimeNorm (RRAresults.([prefix]).(Var).(trial)(:,n),1);
    CEINMSdata(:,n) = TimeNorm (RRAresults.([prefix 'ceinms']).(Var).(trial)(:,n),1);
    end
    axes(ha(v)); hold on
    plot(OGdata,'r');
    plot(CEINMSdata,'b');
    
    % mean plots
    [M(:,1),~,~,CI(:,1),~] = ConfInt_TimeVar(OGdata,0.05);
    [M(:,2),~,~,CI(:,2),~] = ConfInt_TimeVar(CEINMSdata,0.05);
    axes(ha_mean(v)); hold on
    plotShadedSD(M,CI,[1 0 0;0 0 1]);   % plot mean values with colors
    ylabel([Ylabels{1} '/' Ylabels{2}])
    xticklabels(xticks)
    yticklabels(yticks)
    title(Var,'Interpreter','none')  
end

axes(ha(end)); hold on
legend(ha(end).Children([n*2+1 n+1 1]),{([prefix 'original']) ([prefix 'RRA']) ([prefix 'CEINMS - only mass adjusted'])})

axes(ha_mean(end)); hold on
legend({([prefix 'original']) '95%CI' ([prefix 'RRA']) '95%CI' ([prefix 'CEINMS - only mass adjusted']) '95%CI'})

f = gcf; saveas(f,[savedir fp prefix '_timevar_mean.jpeg']);
close (f)

f = gcf; saveas(f,[savedir fp prefix '_timevar_individual.jpeg']);
close (f)


% RMS

function plotFinalResidualsFromLog(CEINMSData,RRAresults,calculation,trial,Ylabels,savedir)
%% peak values
fp = filesep;
Nparticipants = length(RRAresults.Participants);
variablesIN = fields(RRAresults.OriginalResiduals);

[Residuals,IndivData] = createTable(CEINMSData,RRAresults,calculation,trial,'OriginalResiduals');

PP = plotBGset(Residuals,4); PP.ylabel = {'N/Nm'}; PP.title = {'full gait cycle'}; close all; 
varNames = Residuals.Properties.VariableNames(4:end);
figure; [FigList,Normality,Anova,Bonf,MD] = BarBG_Dataset(Residuals,varNames,PP,1,savedir);

BarColors= [1 0 0; 0 0 0]; %red, black 

if contains(calculation,'peak')
    Title = 'peak';
elseif contains(calculation,'RMS')
    Title = 'RMS';
end

LG ={'Original' 'after RRA'};
figure;
BarBG_ind (IndivData(:,[1:4]),Ylabels(1),{'Fx' 'Fy' 'Fz'},Title,LG,10,8,[],BarColors);
saveas(gcf,[savedir fp calculation '_Residuals' '_pelvis_translation.jpeg']);

figure
BarBG_ind (IndivData(:,[1 5:7]),Ylabels(2),{'pelvis_tilt','pelvis_list','pelvis_rotation'},Title,LG,10,8,[],BarColors);
saveas(gcf,[savedir fp calculation '_Residuals' '_pelvis_rotation.jpeg']);

function [Residuals,IndivData] = createTable (CEINMSData,RRAresults,calculation,trial,prefix)
%%   table 
Nparticipants = length(CEINMSData.participantsGroups);
variablesIN = fields(RRAresults.(prefix));
Groups = {};
Groups(CEINMSData.participantsGroups==1)={'FAIS'};
Groups(CEINMSData.participantsGroups==2)={'CAM'};
Groups(CEINMSData.participantsGroups==3)={'control'};

Residuals = table;
Residuals.Group(1:Nparticipants,1) = Groups';
Residuals.SubjectCodes(1:Nparticipants) = CEINMSData.participants;
Residuals.ID(1:Nparticipants) = str2double(CEINMSData.participants);

% 'pelvis_tx';'pelvis_ty';'pelvis_tz';'pelvis_tilt';'pelvis_list';'pelvis_rotation'
IndivData = [];
IndivData(1:46,1) = 1;IndivData(47:92,1) = 2;
for v = 1:length(variablesIN)
    for n = 1:Nparticipants
        Var = variablesIN{v};
        
        if contains(prefix,'OriginalResiduals')
            OGdata = RRAresults.OriginalResiduals.(Var).(trial); 
            CEINMSdata = RRAresults.PostRRAResiduals.(Var).(trial);
        else
            OGdata = RRAresults.([prefix]).(Var).(trial); 
            CEINMSdata = RRAresults.([prefix 'ceinms']).(Var).(trial);
        end
        
        OGdata(OGdata==0)=NaN; 
        CEINMSdata(CEINMSdata==0)=NaN;
        
        MassAdj = abs(RRAresults.MassAdjustments.(trial));   % only mass adjustments less than 30 kg were included 
        OGdata(MassAdj > 30)=NaN; 
        CEINMSdata(MassAdj > 30)=NaN;
        
        if contains(calculation,'peak')
        Residuals.([Var '_Original'])(1:Nparticipants) = max(abs(OGdata),[],1);
        Residuals.([Var '_CEINMS'])(1:Nparticipants) = max(abs(CEINMSdata),[],1);
        elseif contains(calculation,'RMS')
        Residuals.([Var '_Original'])(1:Nparticipants) = rms(abs(OGdata),1);
        Residuals.([Var '_CEINMS'])(1:Nparticipants) = rms(abs(CEINMSdata),1); 
        end
    end
       
    IndivData(1:46,v+1) = Residuals.([Var '_Original']);
    IndivData(47:92,v+1) = Residuals.([Var '_CEINMS']);
end
Residuals = sortrows(Residuals,'Group');