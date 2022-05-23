% Find events of the force plates during running (make sure you have only
% the exact number of events that you want for the "TestedLeg";
%
%

function [events,FPstep,AllEvents,StanceOnFP] = findGaitCycle_FAIS(DirElaborated,trialName)

warning on
dataDir = [DirElaborated fp 'sessionData' fp trialName];
[TestedLeg,~,LongLeg,~] = findLeg(DirElaborated,trialName);
cd(dataDir)
if exist([dataDir fp 'Events.mat'],'file')
    load([dataDir fp 'Events.mat'])
    AllEvents = Events;
else 
    AllEvents = [];
end
if exist([dataDir fp 'Markers.mat'])
    load([dataDir fp 'Markers.mat'])
end
if exist([dataDir fp 'FPdata.mat'])
    load([dataDir fp 'FPdata.mat'])
end
fs_ratio = FPdata.Rate/Markers.Rate;

events = struct;
events.forceplateTimes = struct;
events.forceplateEvents = struct;
FPevents = [];
leg = {'-' '-' '-' '-'};
Time = [FPdata.FirstFrame*fs_ratio:FPdata.LastFrame*fs_ratio]'./FPdata.Rate;

% remove "C_Subject" from the field names (from Vicon)
if exist('Events','var')
    for k = 1:length(Events)
        
        if contains(Events(k).context,TestedLeg) % check if the leg matches the tested leg
            NewName = strrep([Events(k).context '_' Events(k).label],' ','_');
            
            if isfield(events.forceplateTimes,NewName)
                events.forceplateTimes.(NewName)(end+1) = Events(k).time;
                events.forceplateEvents.(NewName)(end+1) = Events(k).frame;
            else
                events.forceplateTimes.(NewName) = Events(k).time;
                events.forceplateEvents.(NewName)= Events(k).frame;
            end
            
            % find foot contact event
            if contains(Events(k).label,'Strike')
                FootContact = Events(k).frame*fs_ratio;
                timeWindow = (FootContact:FootContact+FPdata.Rate/10)- FPdata.FirstFrame*fs_ratio; % Foot contact + 0.1 sec
                if timeWindow(end)> length(FPdata.RawData)
                    timeWindow(end) = length(FPdata.RawData);
                end
            end
            
        end
    end
end

% check step on plate
if ~exist('timeWindow')
    FPstep = [];
%     warning(['no gait events found for ' trialName])
else
    FZ = FPdata.RawData (timeWindow(1):timeWindow(end),contains(FPdata.Labels, {'Force.Fz'}));                      % get vert Focrce for the timewindow
    FZ_filtered = round(ZeroLagButtFiltfilt((1/FPdata.Rate), 100, 1, 'lp', FZ),1);
    idx = find(max(abs(FZ_filtered))> 50);                                                                          % index of  FP that measure force above 50N
    FPstep = find(sum(FZ_filtered));                                                                                % find force plate that have measured force
    FPstep = intersect(FPstep,idx);                                                                                 % Foot on plate = measured force ABOVE 50N;
    leg(FPstep)=LongLeg;
end

% % shift events based on selected force plates
% timeWindow = [Events.frame]*fs_ratio;
% FZ = FPdata.RawData (timeWindow(1)-100:timeWindow(end)+100,contains(FPdata.Labels, {'Force.Fz'})); % get vert Focrce for the timewindow
% Time = Time(timeWindow(1)-100:timeWindow(end)+100);
% FZ_filtered = round(ZeroLagButtFiltfilt((1/FPdata.Rate), 100, 1, 'lp', FZ),1);
% idx = find(FZ_filtered(:,FPstep));
% timeWindow = round(([idx(1) idx(end)]+timeWindow(1)-100)./fs_ratio,0);



Nforceplates = sum(contains(FPdata.Labels, {'Force.Fx'}));
StanceOnFP =  struct('Forceplatform',split(cellstr(sprintf('%d ',1:Nforceplates)),' ')', 'leg',leg);

