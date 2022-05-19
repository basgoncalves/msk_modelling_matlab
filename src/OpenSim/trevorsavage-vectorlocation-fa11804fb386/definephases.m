function gaitPhases = definephases

% * GaitPhase 1: Loading response - First 16.7% of stance (0.167 * 63.6)
% * GaitPhase 2: Mid-stance - 16.7% to 50% of stance (0.5 * 63.6)
% * GaitPhase 3: Terminal stance - 50 to 82.3% of stance (0.5 * 63.6)
% * GaitPhase 4: Late-stance - Last 16.6% of stance (0.5 * 63.6)
% * GaitPhase 5: Swing - Swing

start     = 100;
StrideDur = 1.1;                     %<- average stride duration for both MDS and FAI data
StanceDur = 0.7;                     %<- average stance duration for both MDS and FAI data
stancePercent = StanceDur/StrideDur; %<- stance as a percentage of stride for both MDS and FAI data

gaitPhases(1).phase = 'loading';         gaitPhases(1).start = 1 + start;                                  gaitPhases(1).stop = round(0.167*stancePercent*101)+ start;
gaitPhases(2).phase = 'midstance';       gaitPhases(2).start = round(0.167*stancePercent*101) + start + 1; gaitPhases(2).stop = round(0.5*stancePercent*101)+ start;
gaitPhases(3).phase = 'terminal stance'; gaitPhases(3).start = round(0.5*stancePercent*101) + start + 1;   gaitPhases(3).stop = round(0.8229*stancePercent*101)+ start;
gaitPhases(4).phase = 'preswing';        gaitPhases(4).start = round(0.823*stancePercent*101) + start + 1; gaitPhases(4).stop = round(stancePercent*101)+ start;
gaitPhases(5).phase = 'swing';           gaitPhases(5).start = round(stancePercent*101) + start + 1;       gaitPhases(5).stop = 101 + start;