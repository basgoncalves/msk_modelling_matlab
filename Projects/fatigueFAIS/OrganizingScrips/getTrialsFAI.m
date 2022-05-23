
function Trials = getTrialsFAI(Dir,TrialsToUse,WalkingCalibration,TestedLeg)


Isometrics_pre = {'HE','HEAB','HEER','HEABER','HF','HAD','HAB','HER','HIR','KE','KF','PF'};
Isometrics_post = {'HE_post','HEAB_post','HEER_post','HEABER_post','HF_post','HAD_post','HAB_post','HER_post','HIR_post','KE_post','KF_post','PF_post'};
DynamicTrials = {'Run' 'SJ' 'walking'};

Isometrics_pre = findTrials(Dir.Input,Isometrics_pre);
idx = find(contains(Isometrics_pre,{'post'}));
Isometrics_pre(idx) = [];

% Dynamic trials
if exist(Dir.Input,'dir')
    DynamicTrials = findTrials(Dir.Input,DynamicTrials);
else
    DynamicTrials = findFolders(Dir.sessionData,DynamicTrials);
end
% (uncomment to use only pre and post runs)
idx = find(contains(DynamicTrials,TrialsToUse,'IgnoreCase',true));
DynamicTrials = DynamicTrials(idx);
DynamicTrials = unique(DynamicTrials)';

Trials = struct;
Trials.Isometrics_pre = Isometrics_pre;
Trials.Isometrics_post = findTrials(Dir.Input,Isometrics_post);
Trials.Static = findTrials(Dir.Input,{'static'});
Trials.Dynamic = DynamicTrials;
idx = find(contains(Trials.Dynamic,'baseline','IgnoreCase',true));
Trials.MaxEMG = [Trials.Dynamic(idx)' Trials.Isometrics_pre];

idx = find(sum([contains(Trials.Dynamic,{'1'}) contains(Trials.Dynamic,{'run'},'IgnoreCase',1)],2)==2);
Trials.RunStraight = Trials.Dynamic(idx);

idx = find(sum([contains(Trials.Dynamic,{'2'}) contains(Trials.Dynamic,{'run'},'IgnoreCase',1)],2)==2);
Trials.CutLeft = Trials.Dynamic(idx); 

idx = find(sum([contains(Trials.Dynamic,{'3'}) contains(Trials.Dynamic,{'run'},'IgnoreCase',1)],2)==2);
Trials.CutRight = Trials.Dynamic(idx); 

if nargin>3 && contains(TestedLeg,'R')
   Trials.CutDominant =  Trials.CutLeft;
   Trials.CutOpposite =  Trials.CutRight;
   
elseif nargin>3 && contains(TestedLeg,'L')
   Trials.CutDominant =  Trials.CutRight;
   Trials.CutOpposite =  Trials.CutLeft;
else
   Trials.CutDominant =  {};
   Trials.CutOpposite =  {};
end

idx = find(sum([contains(Trials.Dynamic,{'walk'},'IgnoreCase',1)],2)==1);
Trials.Walking = Trials.Dynamic(idx); 

Trials.IK = getDirNames(Dir.IK);
Trials.IK = Trials.IK(contains(Trials.IK,Trials.Dynamic));

Trials.ID = getDirNames(Dir.ID);
Trials.ID = Trials.ID(contains(Trials.ID,Trials.Dynamic));

Trials.RRA = getDirNames(Dir.RRA);
Trials.RRA = Trials.RRA(contains(Trials.RRA,Trials.Dynamic));

Trials.MA = getDirNames(Dir.MA);
Trials.MA = Trials.MA(contains(Trials.MA,Trials.Dynamic));

idx=[];
if WalkingCalibration==0
    idx = find(~contains(Trials.Dynamic,'baseline','IgnoreCase',true));
    idx = find(contains(Trials.Dynamic(idx),'1','IgnoreCase',true));
    Trials.CEINMScalibration = [Trials.Dynamic(idx(1))];
elseif WalkingCalibration==1
    idx = find(contains(Trials.Dynamic,'walking','IgnoreCase',true));
    Trials.CEINMScalibration = [Trials.Dynamic(idx(1))];
end
if ~isempty(idx); Trials.MaxEMG=[Trials.MaxEMG Trials.CEINMScalibration]; end

Trials.CEINMS = getDirNames(Dir.CEINMSsimulations);
Trials.CEINMS = Trials.CEINMS(contains(Trials.CEINMS,Trials.Dynamic));
