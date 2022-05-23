
function Out = CheckGaitEvents (DirC3D,Trials,TestedLeg)

fp = filesep;
[~,Subject] = DirUp(DirC3D,2);
Out =[];
for k = 1: length(Trials)
    
    trialName = Trials{k};
    if ~exist([DirC3D fp trialName '.c3d'])
%         disp([DirC3D fp trialName '.c3d' ' does not exisit'])
        Out(k) = 0;
        continue
    end
    
    data = btk_loadc3d([DirC3D fp trialName '.c3d']);
    % remove the "C" from events if they were done in Vicon
    MarkerEvents = TrimStruct (data.Events.Events,['C' data.sub_info.Name '_']);
 
    
    if contains (trialName, 'run','IgnoreCase',1) && contains(trialName,'1') 
        side = TestedLeg;
    elseif contains(trialName,'run','IgnoreCase',1) && contains(trialName,'2')
        side = {'R'};
    elseif contains(trialName,'run','IgnoreCase',1) && contains(trialName,'3')
        side = {'L'};
    else 
        continue
    end
    
    % use only the events for the side of interest 
    fld = fields(MarkerEvents);
    idx = find(~contains(fld,side));
    for i  = idx'
        MarkerEvents = rmfield(MarkerEvents,(fld{i}));
    end
    
    % define the event labls
    if contains(side,'R')
        Strike = 'Right_Foot_Strike';
        Off = 'Right_Foot_Off';
    elseif contains(side,'L')
        Strike = 'Left_Foot_Strike';
        Off = 'Left_Foot_Off';
    end
    
    
    if contains(trialName,'1') && ...               % for Run with number 1
            isfield(MarkerEvents,Strike) &&...      
            length(MarkerEvents.(Strike))==1 && ... % one foot strike
            isfield(MarkerEvents,Off) &&...
            length(MarkerEvents.(Off))==2           % two foot off
        
        Out(k) = 1;
    elseif contains(trialName,'2') && ...            % for Run with number 2
            isfield(MarkerEvents,Strike) &&...      
            length(MarkerEvents.(Strike))==1 && ...  % ONE foot strike
            isfield(MarkerEvents,Off) &&...
            length(MarkerEvents.(Off))==1            % ONE foot off
        
        Out(k) = 1;
    elseif contains(trialName,'3') && ...            % for Run with number 3
            isfield(MarkerEvents,Strike) &&...      
            length(MarkerEvents.(Strike))==1 && ...  % ONE foot strike
            isfield(MarkerEvents,Off) &&...
            length(MarkerEvents.(Off))==1            % ONE foot off
        Out(k) = 1;
    else
%         disp([trialName ' does not contain the correct gait events'])
        Out(k) = 0;
        continue
    end
    
    % check if the trial has enough frames for the EMG delay (0.2sec)
    fld = fields(MarkerEvents);
    for i = 1:length(fld)
        initial_time = data.marker_data.First_Frame/data.marker_data.Info.frequency;
       if  initial_time > min(MarkerEvents.(fld{i})) - 0.2
%         disp([trialName ' does not have enough frames before the first event'])
        Out(k) = 0;
        continue
       end
    end
    
    % check if force vector is on during foor contact / foot off
%     fld = fields(data.fp_data.FP_data);
%     for i = 1:length(fld)
%         [Time,idx] = intersect(round(data.fp_data.Time,4), round(data.marker_data.Time,4));
%         grf = data.fp_data.GRF_data(i).F(idx,3);
%         frame = find(round(Time,3)==round(MarkerEvents.(Strike),3));
%        if ~isempty(frame) && grf(frame(1)) > 10
% %         disp([trialName ' does not have enough frames before the first event'])
%         Out(k) = 0;
%         continue
%        end
%     end
    
end
