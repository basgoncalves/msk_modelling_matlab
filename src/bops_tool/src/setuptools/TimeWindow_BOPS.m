
function [TimeWindow,FramesWindow,SplitEvent] = TimeWindow_BOPS(trialName)

subjectSettings = load_subject_settings;
TimeWindow          = [];
FramesWindow        = [];
SplitEvent          = struct; 
SplitEvent.time     = [];
SplitEvent.frame    = [];

eventsdir = [subjectSettings.directories.sessionData fp trialName fp 'Events.mat'];
load ([subjectSettings.directories.sessionData fp trialName fp 'markers.mat']);                                     % load "Markers"

if isfile(eventsdir)
    load(eventsdir)                                                                                                 % load "Events"
    TimeWindow   = [Events(1).time Events(end).time];
    FramesWindow = [Events(1).frame Events(end).frame];
else 
    cprintf('yellow', ['Full time window used for ' trialName 'because trial does not contain events \n'])
    FramesWindow = [Markers.FirstFrame Markers.LastFrame];
    TimeWindow   = FramesWindow .* (1/Markers.Rate);
end
