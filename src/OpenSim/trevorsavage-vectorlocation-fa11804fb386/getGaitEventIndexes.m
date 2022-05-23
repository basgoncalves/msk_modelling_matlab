function [gaitPhases, stridx] = getGaitEventIndexes(dataIK, HJCF, trial, anawin)
% gets index of start and stop gait events from the tansformed
% force data

trialsList = {dataIK.trial}.';
[~, order] = ismember(trial, trialsList);
gestart    = dataIK(order).ftstr1.time; %<- HS1
td         = HJCF(:,1); %<- time column

if anawin == 1
    gestop = dataIK(order).ftstr2.time; %<- HS2
    toeoff = dataIK(order).ftoff.time;  %<- TOff
    stride = (gestop - gestart);
    swing  = (gestop - dataIK(order).ftoff.time);
    dTto   = abs(toeoff - td);
    mindTto= min(dTto);  
    toidx  = find(dTto == mindTto);
    if size(toidx,1) > 1
        toidx = toidx(2);
    end
elseif anawin == 2
    gestop = dataIK(order).ftoff.time;
end

% create arrays of difference in time start and finish
dTs = abs(gestart - td); 
dTf = abs(gestop - td);
% search difference arrays for minimum difference
mindTs     = min(dTs);  stridx(1) = find(dTs == mindTs);
mindTf     = min(dTf);  stridx(2) = find(dTf == mindTf);
stance     = (toidx - stridx(1));

%% get phase indexes
halfstance = ceil(stridx(1) + (stance/2));
sev10      = (0.1667 * stance);
loading    = ([stridx(1)]);
midstance  = (stridx(1) + round(sev10));
latestance = halfstance;
preswing   = (toidx - round(sev10));
heelstr1   = stridx(1);
heelstr2   = stridx(2);

% Gait sycle phases inclusive of last event of previous cycle for distances - this won't change analysis of whole gait cycle 
gaitPhases(1).phase = 'loading';      gaitPhases(1).start = loading;      gaitPhases(1).stop = midstance;
gaitPhases(2).phase = 'midstance';    gaitPhases(2).start = midstance;    gaitPhases(2).stop = latestance;
gaitPhases(3).phase = 'latestance';   gaitPhases(3).start = latestance;   gaitPhases(3).stop = preswing;
gaitPhases(4).phase = 'preswing';     gaitPhases(4).start = preswing;     gaitPhases(4).stop = toidx;
if anawin == 1 %<- if gait gait cycle rather than stance only...
    gaitPhases(5).phase = 'swing';    gaitPhases(5).start = toidx;        gaitPhases(5).stop = heelstr2;
end