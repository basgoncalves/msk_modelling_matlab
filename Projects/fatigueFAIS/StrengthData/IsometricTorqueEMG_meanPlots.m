%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Select folder that contains individual
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS
%   copyTrials_FAI
%   MaxStrengthPerSubject_FAI
%   reaclibrateForce
%   MaxEMG_FAI
%   PlotsMaxStrength_FAI
%   PlotMeanStrengthDiff_FAI

%% IsometricTroqrueEMG_meanPlots

% Plot mean strength for all the subjects
PlotsMeanStrength_FAI

% mean Strength diff
PlotMeanStrengthDiff_FAI


%% Check EMG data & Re-run analysis

CheckEMG_isometricTrials_FAI

%% pre post diff-EMG - INCOMPLETE
MaxEMGDiff={};
for ii = 2:2:length (MaxEMGTrials)
    idx = strcmpi(Isometrics_pre{1},MaxEMGTrials(:,1));
    PreTrials = cell2mat(MaxEMGTrials(ii,2:size(MaxEMGTrials,2)));
    PostTrials = cell2mat(MaxEMGTrials(ii+1,2:size(MaxEMGTrials,2)));
    
    MaxEMGDiff(ii,1) =MaxEMGTrials(ii,1);
    MaxEMGDiff(ii,2:size(MaxEMGTrials,2)) = num2cell((PostTrials - PreTrials)./PreTrials*100);
end

% clear empty cells
for ii = flip(1:2:length (MaxEMGDiff))
    MaxEMGDiff(ii,:)=[];
end

%delete rows 10-12 (PF,KF,KE)
MaxEMGDiff(10:12,:)=[];                                      % delete KF, KE and PF

figure
bar(cell2mat(MaxEMGDiff(1:end,2:end)));
xticks(1:length(MaxEMGDiff));
xticklabels(MaxEMGDiff(1:end,1));
set(gca,'TickLabelInterpreter','none');
xtickangle(45)
ylabel('Force change(%)');
title (sprintf('Force change after fatigue - %s',Subject),'Interpreter','none');

cd (SubjFolder)
save strenghtData StrengthTrials MaxStrength NewMaxStrength MaxStrengthPre StrengthDiff

sprintf ('Max Strength trials saved')

%% mean EMG pre - isometric tasks

PlotMaxEMG_isometric_FAI

