function [Events, EventsInfo] = insertGaitEvents(acquisition, RightHS, RightTO)
%Insert the heel-strike events into the c3d file
%   Input the column vectors corresponding to the heel-strike events for
%   each foot and use these time points to add heel-strikes into the c3d
%   file

% Loop through all heel strikes and append events into the file
for i = 1%:length(RightHS)
     
     btkAppendEvent(acquisition,'Foot Strike', RightHS(i,1), 'Right');
     [Events, EventsInfo] = btkAppendEvent(acquisition,'Foot Off', RightTO(i,1), 'Right');
     
end


end

