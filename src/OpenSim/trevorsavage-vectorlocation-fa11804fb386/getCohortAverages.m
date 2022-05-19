function Out = getCohortAverages (In, dpt, dmv, quat, ScFac, height, femrad, n)    
% In - 
% distpt - distance between points
% distavor - distance between point and
% ScFac -
% height -
% femrad -
% n - n rows

Out = In;
     
%% SPHERICAL DISTANCE
% GAITCYCLE
Out.dist.gaitcyc(end+1).subject     = 'cohort';
Out.dist.gaitcyc(end).mean          = mean(dpt.gaitcyc,2);     
Out.dist.gaitcyc(end).sd            = std(dpt.gaitcyc,0,2);
Out.dist.gaitcyc(end).ci            = CalcCI(Out.dist.gaitcyc(end).sd, n);
Out.dist.gaitcyc(end).colheaders    = {'HCFvecChangeDist_GAITCYCLE'};
% STANCE
Out.dist.stance(end+1).subject      = 'cohort';
Out.dist.stance(end).mean           = mean(dpt.stance,2);     
Out.dist.stance(end).sd             = std(dpt.stance,0,2);
Out.dist.stance(end).ci             = CalcCI(Out.dist.stance(end).sd, n);
Out.dist.stance(end).colheaders     = {'HCFvecChangeDist_STANCE'};
% LOADING
Out.dist.loading(end+1).subject     = 'cohort';
Out.dist.loading(end).mean          = mean(dpt.loading,2);     
Out.dist.loading(end).sd            = std(dpt.loading,0,2);
Out.dist.loading(end).ci            = CalcCI(Out.dist.loading(end).sd, n);
Out.dist.loading(end).colheaders    = {'HCFvecChangeDist_LOADING'};
% MIDSTANCE
Out.dist.midstance(end+1).subject   = 'cohort';
Out.dist.midstance(end).mean        = mean(dpt.midstance,2);     
Out.dist.midstance(end).sd          = std(dpt.midstance,0,2);
Out.dist.midstance(end).ci          = CalcCI(Out.dist.stance(end).sd, n);
Out.dist.midstance(end).colheaders  = {'HCFvecChangeDist_MIDSTANCE'};
% LATESTANCE
Out.dist.latestance(end+1).subject  = 'cohort';
Out.dist.latestance(end).mean       = mean(dpt.latestance,2);     
Out.dist.latestance(end).sd         = std(dpt.latestance,0,2);
Out.dist.latestance(end).ci         = CalcCI(Out.dist.latestance(end).sd, n);
Out.dist.latestance(end).colheaders = {'HCFvecChangeDist_LATESTANCE'};
% PRESWING
Out.dist.preswing(end+1).subject    = 'cohort';
Out.dist.preswing(end).mean         = mean(dpt.preswing,2);     
Out.dist.preswing(end).sd           = std(dpt.preswing,0,2);
Out.dist.preswing(end).ci           = CalcCI(Out.dist.preswing(end).sd, n);
Out.dist.preswing(end).colheaders   = {'HCFvecChangeDist_PRESWING'};
% SWING
Out.dist.swing(end+1).subject       = 'cohort';
Out.dist.swing(end).mean            = mean(dpt.swing,2);     
Out.dist.swing(end).sd              = std(dpt.swing,0,2);
Out.dist.swing(end).ci              = CalcCI(Out.dist.stance(end).sd, n);
Out.dist.swing(end).colheaders      = {'HCFvecChangeDist_SWING'};

%% CUMULATIVE DISTANCE
% GAITCYCLE
Out.cdist.gaitcyc(end+1).subject     = 'cohort';
Out.cdist.gaitcyc(end).mean          = mean(cumsum(dpt.gaitcyc),2);
Out.cdist.gaitcyc(end).sd            = std(cumsum(dpt.gaitcyc),0,2);
Out.cdist.gaitcyc(end).ci            = CalcCI(Out.cdist.gaitcyc(end).sd, n);
Out.cdist.gaitcyc(end).colheaders    = {'HCFvecCumDist_GAITCYCLE'};
% STANCE
Out.cdist.stance(end+1).subject      = 'cohort';
Out.cdist.stance(end).mean           = mean(cumsum(dpt.stance),2);
Out.cdist.stance(end).sd             = std(cumsum(dpt.stance),0,2);
Out.cdist.stance(end).ci             = CalcCI(Out.cdist.stance(end).sd, n);
Out.cdist.stance(end).colheaders     = {'HCFvecCumDist_STANCE'};
% LOADING
Out.cdist.loading(end+1).subject     = 'cohort';
Out.cdist.loading(end).mean          = mean(cumsum(dpt.loading),2);
Out.cdist.loading(end).sd            = std(cumsum(dpt.loading),0,2);
Out.cdist.loading(end).ci            = CalcCI(Out.cdist.loading(end).sd, n);
Out.cdist.loading(end).colheaders    = {'HCFvecCumDist_LOADING'};
% MIDSTANCE
Out.cdist.midstance(end+1).subject   = 'cohort';
Out.cdist.midstance(end).mean        = mean(cumsum(dpt.midstance),2);
Out.cdist.midstance(end).sd          = std(cumsum(dpt.midstance),0,2);
Out.cdist.midstance(end).ci          = CalcCI(Out.cdist.midstance(end).sd, n);
Out.cdist.midstance(end).colheaders  = {'HCFvecCumDist_MIDSTANCE'};
% LATESTANCE
Out.cdist.latestance(end+1).subject  = 'cohort';
Out.cdist.latestance(end).mean       = mean(cumsum(dpt.latestance),2);
Out.cdist.latestance(end).sd         = std(cumsum(dpt.latestance),0,2);
Out.cdist.latestance(end).ci         = CalcCI(Out.cdist.latestance(end).sd, n);
Out.cdist.latestance(end).colheaders = {'HCFvecCumDist_LATESTANCE'};
% PRESWING
Out.cdist.preswing(end+1).subject    = 'cohort';
Out.cdist.preswing(end).mean         = mean(cumsum(dpt.preswing),2);
Out.cdist.preswing(end).sd           = std(cumsum(dpt.preswing),0,2);
Out.cdist.preswing(end).ci           = CalcCI(Out.cdist.preswing(end).sd, n);
Out.cdist.preswing(end).colheaders   = {'HCFvecCumDist_PRESWING'};
% SWING
Out.cdist.swing(end+1).subject       = 'cohort';
Out.cdist.swing(end).mean            = mean(cumsum(dpt.swing),2);
Out.cdist.swing(end).sd              = std(cumsum(dpt.swing),0,2);
Out.cdist.swing(end).ci              = CalcCI(Out.cdist.swing(end).sd, n);
Out.cdist.swing(end).colheaders      = {'HCFvecCumDist_SWING'};

%% DISTANCE FROM AVERAGE ORIENTATION
% GAITCYCLE
Out.dmvec.gaitcyc(end+1).subject      = 'cohort';
Out.dmvec.gaitcyc(end).mean           = mean(dmv.gaitcyc,2);
Out.dmvec.gaitcyc(end).sd             = std(dmv.gaitcyc,0,2);
Out.dmvec.gaitcyc(end).ci             = CalcCI(Out.dmvec.gaitcyc(end).sd, n);
Out.dmvec.gaitcyc(end).colheaders     = {'HCFvecDistRepvec_GAITCYCLE'};
% STANCE
Out.dmvec.stance(end+1).subject       = 'cohort';
Out.dmvec.stance(end).mean            = mean(dmv.stance,2);
Out.dmvec.stance(end).sd              = std(dmv.stance,0,2);
Out.dmvec.stance(end).ci              = CalcCI(Out.dmvec.stance(end).sd, n);
Out.dmvec.stance(end).colheaders      = {'HCFvecDistRepvec_STANCE'};
% LOADING
Out.dmvec.loading(end+1).subject      = 'cohort';
Out.dmvec.loading(end).mean           = mean([In.dmvec.loading.mean].');
Out.dmvec.loading(end).sd             = std([In.dmvec.loading.mean].',0);
Out.dmvec.loading(end).ci             = CalcCI(Out.dmvec.loading(end).sd, n);
Out.dmvec.loading(end).colheaders     = {'HCFvecDistRepvec_LOADING'};
% MIDSTANCE
Out.dmvec.midstance(end+1).subject    = 'cohort';
Out.dmvec.midstance(end).mean         = mean([In.dmvec.midstance.mean].');
Out.dmvec.midstance(end).sd           = std([In.dmvec.midstance.mean].',0);
Out.dmvec.midstance(end).ci           = CalcCI(Out.dmvec.midstance(end).sd, n);
Out.dmvec.midstance(end).colheaders   = {'HCFvecDistRepvec_MIDSTANCE'};
% LATESTANCE
Out.dmvec.latestance(end+1).subject   = 'cohort';
Out.dmvec.latestance(end).mean        = mean([In.dmvec.latestance.mean].');
Out.dmvec.latestance(end).sd          = std([In.dmvec.latestance.mean].',0);
Out.dmvec.latestance(end).ci          = CalcCI(Out.dmvec.latestance(end).sd, n);
Out.dmvec.latestance(end).colheaders  = {'HCFvecDistRepvec_LATESTANCE'};
% PRESWING
Out.dmvec.preswing(end+1).subject     = 'cohort';
Out.dmvec.preswing(end).mean          = mean([In.dmvec.preswing.mean].');
Out.dmvec.preswing(end).sd            = std([In.dmvec.preswing.mean].',0);
Out.dmvec.preswing(end).ci            = CalcCI(Out.dmvec.preswing(end).sd, n);
Out.dmvec.preswing(end).colheaders    = {'HCFvecDistRepvec_PRESWING'};
% SWING
Out.dmvec.swing(end+1).subject        = 'cohort';
Out.dmvec.swing(end).mean             = mean([In.dmvec.swing.mean].');
Out.dmvec.swing(end).sd               = std([In.dmvec.swing.mean].',0);
Out.dmvec.swing(end).ci               = CalcCI(Out.dmvec.swing(end).sd, n);
Out.dmvec.swing(end).colheaders       = {'HCFvecDistRepvec_SWING'};
%% AREA
Out.area.gaitcyc(end+1).subject      = 'cohort';
Out.area.gaitcyc(end).mean           = mean([In.area.gaitcyc.mean].')';
Out.area.gaitcyc(end).sd             = std([In.area.gaitcyc.mean].',0)';
Out.area.gaitcyc(end).ci             = CalcCI(Out.dmvec.gaitcyc(end).sd, n);
Out.area.gaitcyc(end).colheaders     = {'HCFvecArea_GAITCYCLE'};
% STANCE
Out.area.stance(end+1).subject       = 'cohort';
Out.area.stance(end).mean            = mean([In.area.stance.mean].')';
Out.area.stance(end).sd              = std([In.area.stance.mean].',0)';
Out.area.stance(end).ci              = CalcCI(Out.area.stance(end).sd, n);
Out.area.stance(end).colheaders      = {'HCFvecArea_STANCE'};
% LOADING
Out.area.loading(end+1).subject      = 'cohort';
Out.area.loading(end).mean           = mean([In.area.loading.mean].')';
Out.area.loading(end).sd             = std([In.area.loading.mean].',0)';
Out.area.loading(end).ci             = CalcCI(Out.area.loading(end).sd, n);
Out.area.loading(end).colheaders     = {'HCFvecArea_LOADING'};
% MIDSTANCE
Out.area.midstance(end+1).subject    = 'cohort';
Out.area.midstance(end).mean         = mean([In.area.midstance.mean].')';
Out.area.midstance(end).sd           = std([In.area.midstance.mean].',0)';
Out.area.midstance(end).ci           = CalcCI(Out.area.midstance(end).sd, n);
Out.area.midstance(end).colheaders   = {'HCFvecArea_MIDSTANCE'};
% LATESTANCE
Out.area.latestance(end+1).subject   = 'cohort';
Out.area.latestance(end).mean        = mean([In.area.latestance.mean].')';
Out.area.latestance(end).sd          = std([In.area.latestance.mean].',0)';
Out.area.latestance(end).ci          = CalcCI(Out.area.latestance(end).sd, n);
Out.area.latestance(end).colheaders  = {'HCFvecArea_LATESTANCE'};
% PRESWING
Out.area.preswing(end+1).subject     = 'cohort';
Out.area.preswing(end).mean          = mean([In.area.preswing.mean].')';
Out.area.preswing(end).sd            = std([In.area.preswing.mean].',0)';
Out.area.preswing(end).ci            = CalcCI(Out.area.preswing(end).sd, n);
Out.area.preswing(end).colheaders    = {'HJCFvecArea_PRESWING'};
% SWING
Out.area.swing(end+1).subject        = 'cohort';
Out.area.swing(end).mean             = mean([In.area.swing.mean].')';
Out.area.swing(end).sd               = std([In.area.swing.mean].',0)';
Out.area.swing(end).ci               = CalcCI(Out.area.swing(end).sd, n);
Out.area.swing(end).colheaders       = {'HJCFvecArea_SWING'};
%% METADATA
Out.metadata(end+1).subject          = 'cohort';
Out.metadata(end).SF                 = mean(ScFac);
Out.metadata(end).height             = mean(height);
Out.metadata(end).side               = 'NA';
Out.metadata(end).femrad_s           = mean(femrad);
Out.metadata(end).femrad_m           = mean([In.metadata.femrad_m].');
Out.metadata(end).acerad_m           = mean([In.metadata.acerad_m].');
Out.metadata(end).artrad_m           = mean([In.metadata.artrad_m].');
Out.metadata(end).to                 = mean([In.metadata.to].');
Out.metadata(end).quat               = meanrot(quat,2);
Out.metadata(end).mquat              = meanrot(Out.quat.gaitcyc);
Out.metadata(end).mpos               = [1 0 0] * quat2rotm(Out.metadata(end).mquat);
Out.metadata(end).cdist_gc           = max(cumsum(mean(dpt.gaitcyc,2)));
Out.metadata(end).cdist_swg          = max(cumsum(mean(dpt.swing,2)));
Out.metadata(end).dcop_gc            = mean(mean(dmv.gaitcyc,2));
Out.metadata(end).dcop_stn           = mean(mean(dmv.stance,2));
Out.metadata(end).dcop_swg           = mean(mean(dmv.swing,2));
Out.metadata(end).crd_gc             = cumsum(mean(dmv.gaitcyc,2));
Out.metadata(end).AEgc               = mean([In.metadata.AEgc]);
Out.metadata(end).AEst               = mean([In.metadata.AEst]);
Out.metadata(end).AEld               = mean([In.metadata.AEld]);
Out.metadata(end).AEms               = mean([In.metadata.AEms]);
Out.metadata(end).AEls               = mean([In.metadata.AEls]);
Out.metadata(end).AEps               = mean([In.metadata.AEps]);
Out.metadata(end).AEsw               = mean([In.metadata.AEsw]);
Out.metadata(end).ABdgc              = mean([In.metadata.ABdgc]);
Out.metadata(end).ABdst              = mean([In.metadata.ABdst]);
Out.metadata(end).ABdld              = mean([In.metadata.ABdld]);
Out.metadata(end).ABdms              = mean([In.metadata.ABdms]);
Out.metadata(end).ABdls              = mean([In.metadata.ABdls]);
Out.metadata(end).ABdps              = mean([In.metadata.ABdps]);
Out.metadata(end).ABdsw              = mean([In.metadata.ABdsw]);
%%
                