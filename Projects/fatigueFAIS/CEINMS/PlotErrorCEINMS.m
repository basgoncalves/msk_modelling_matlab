%% BestGamma = PlotErrorCEINMS(r2mom,rmsmom,r2exc,rmseexc,MeanRangeMom,MeanRangeEMG,Gammas)   
% calculate best gamma value given the rmse of moments (CEINMS vs InverseDynamics) and excitations
% (adjusted vs emg)
%
% Written by Basilio Goncalves (2021) https://www.researchgate.net/profile/Basilio_Goncalves

function [BestGamma,BestRMSE] = PlotErrorCEINMS(r2mom,rmsmom,r2exc,rmseexc,MeanRangeMom,MeanRangeEMG,Gammas,PolyN)    

if ~exist('PolyN'); PolyN=5; end

% find sum of RMSE values and differences between R2 (compare moments and emg)
Sumrmse = abs(nanmean(rmsmom)./MeanRangeMom)+abs(nanmean(rmseexc)./MeanRangeEMG);
Diffr2 = abs(nanmean(r2mom)-nanmean(r2exc));

% delete columns with nans = intersect between non Nan for sumRMSE and diffR2
NonNaNidx = intersect(find(~isnan(Sumrmse)),find(~isnan(Diffr2)));              
Gammas = Gammas(NonNaNidx);
rmsmom = rmsmom(:,NonNaNidx);
rmseexc = rmseexc(:,NonNaNidx);
r2mom = r2mom(:,NonNaNidx);
r2exc = r2exc(:,NonNaNidx);
Sumrmse= Sumrmse(NonNaNidx);
Diffr2= Diffr2(NonNaNidx);
if isempty(Gammas); BestGamma=NaN; BestRMSE=NaN; return; end

%%
prmse = polyfit(Gammas,Sumrmse,PolyN);         % polynomial fucntion (https://au.mathworks.com/help/matlab/ref/polyfit.html#bue6sxq-1-y)        
pr2 = polyfit(Gammas,Diffr2,PolyN);         
PoliFunct_SumErrors = polyval(prmse,Gammas(1):1:Gammas(end))';
PoliFunct_R2 = polyval(pr2,Gammas(1):1:Gammas(end))';

% find the best Gamma by finding the minimum sum of normalised errors and r2 (based on polynomial function)
% [~,BestGamma] = min(PoliFunct_R2 + PoliFunct_SumErrors);  

% find the best Gamma by finding the miinma sum of normalised errors and r2 (from the iterations ran)
[~,BestGammaIdx] = min(Diffr2 + Sumrmse);  BestGamma = Gammas(BestGammaIdx);

BestRMSE = polyval(prmse,BestGamma)';
BestR2 = polyval(pr2,BestGamma)';

%% RMSE (left axes)
ax = tight_subplotBG(2,0,[0.05],[0.1 0.2],[0.1 0.02],[371,307,782,279]);
axes(ax(1)); hold on
plot(Gammas,nanmean(rmsmom)./MeanRangeMom,'o','Color','r')
plot(Gammas,nanmean(rmseexc)./MeanRangeEMG,'o','Color','k')
plot(PoliFunct_SumErrors)
plot(BestGamma,BestRMSE,'x','MarkerSize',10)
% [BestRMSE,BestGamma]=min(PoliFunct_SumErrors);
ylim([0 1])
yticklabels(yticks)
ylabel('RMSE/range')
xticklabels(xticks)

%% r2 (right axes)
axes(ax(2)); hold on
plot(Gammas,nanmean(r2mom),'o','Color','r')
plot(Gammas,nanmean(r2exc),'o','Color','k')
plot(PoliFunct_R2)
plot(BestGamma,BestR2,'x','MarkerSize',10)
% [BestRMSE_R2,BestGamma_R2]=min(PoliFunct_R2);
ylim([0 1])
ylabel('R^2')
xticklabels(xticks)
mmfn_inspect

lg = legend({'moments' 'excitations' 'polyn' ['best gamma = ' num2str(BestGamma)]});
lg.Position(2)= 0.8;

