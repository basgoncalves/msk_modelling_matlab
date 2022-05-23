% PlotBarSplitWork
%
% Phase 1 = Stance ; Phase 2 = Swing

function  [pfW,nfW, peW, neW] = SplitWork_Running (MeanRun,joint,fs,GaitPhase)
%% organise data 
FS = 24;

Fld = fields(MeanRun.(joint).JointPowers);
Fld = Fld(contains(Fld,'trial'));

for ii = 1:length(Fld)
    FootContact = MeanRun.FootContacts(:,ii)/100; % footcontact in percentage of gait cycle
    
    Power = MeanRun.(joint).JointPowers.(Fld{ii});
    Moments = MeanRun.(joint).Moments.(Fld{ii});
    AngularVelocity = MeanRun.(joint).AngularVelocity.(Fld{ii});
    % covert foot contact percentage to frame number
    for ff = 1: size(Power,2)
        NFrames = length(find(~isnan(Power(:,ff))));
        FootContact_frame(ff) = round(NFrames*FootContact(ii));
        
        if exist('GaitPhase') && GaitPhase == 2             % if phase is swing
            Power(FootContact_frame(ff):end,ff) = NaN;
            Moments(FootContact_frame(ff):end,ff) = NaN;
            AngularVelocity(FootContact_frame(ff):end,ff) = NaN;
            
        elseif exist('GaitPhase') && GaitPhase == 1         %if phase is stance
            Power(1:FootContact_frame(ff),ff) = NaN;
            Moments(1:FootContact_frame(ff),ff) = NaN;
            AngularVelocity(1:FootContact_frame(ff),ff) = NaN;
        end
    end
    
    
    [pfW(ii,:),nfW(ii,:),peW(ii,:),neW(ii,:)] = SplitJointWork (Power,Moments,AngularVelocity,fs);         %split joint works based on muscle active
end

pfW=pfW'; nfW=nfW'; peW=peW'; neW=neW';     % flip data vertically to plot bars easily