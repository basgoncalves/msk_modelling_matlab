

% time window (based on the events in the session folder)
if contains(TrialName,'run','IgnoreCase',1)
    load([DirSession fp 'Events.mat'])
    FS = find(and(contains({Events.label},'Foot Strike'),contains({Events.context},TestedLeg)));
    FO = find(and(contains({Events.label},'Foot Off'),contains({Events.context},TestedLeg)));
    SetupXML.AnalyzeTool.initial_time = round(Events(FS).time,3);
    SetupXML.AnalyzeTool.final_time =  round(Events(FO(end)).time,3);

elseif contains(trialName,'SJ','IgnoreCase',1) 
   % add a "buffer zone" (min = 0.01 sec) - see notes*  
   load([DirSession fp 'FPdata.mat'])
   col = find(contains(FPdata.Labels,{'Fz3'}));
   vert = FPdata.RawData(:,col);
   fs = FPdata.Rate;
   [flight,idx] = find(vert==0);
   SetupXML.AnalyzeTool.initial_time = (flight(1)-fs)/fs; 
   SetupXML.AnalyzeTool.final_time = length(vert)/fs; 
    
else
    load([DirSession fp TrialName fp 'Markers.mat'])
    S = find(contains(Markers.Labels,'SACR'))*3; % index of the sacrum markers (x3 to account for XYZ directions)
    M = mean(Markers.RawData(1:50,S(1)));
    Rn = range(Markers.RawData(:,S(1)));
    % find the point where the vertical position is lower than 1% of the
    % range of the marker
    F = find(Markers.RawData(:,S(1))< M-0.01*Rn); 
    SetupXML.AnalyzeTool.initial_time = (F(1)-Markers.Rate)/Markers.Rate;
    SetupXML.AnalyzeTool.final_time =  Markers.LastFrame/Markers.Rate;
    
end
