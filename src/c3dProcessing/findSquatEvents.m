
% Task = Squat or SJ (Squat Jump)
function Events = findSquatEvents (TrialDir,Task)

fp = filesep;

data = btk_loadc3d(TrialDir);
nFP = length(data.fp_data.GRF_data);
Events = struct;
if contains(Task, 'SJ') ||  contains(Task, 'Squat Jump')
    ZeroFrames =[1:length(data.fp_data.GRF_data(1).F(:,3))];
    fs = data.fp_data.Info.frequency;
    %find zero frames in all the force plates
    for k = 1:nFP
        % vert grf
        [ii,idx] = find(~data.fp_data.GRF_data(k).F(:,3));
        if isempty(idx)
            continue
        else
            [ZeroFrames,~]=intersect(ZeroFrames,ii);
        end
    end
    
    Events.TakeOffFrame = ZeroFrames(1);
    Events.LandingFrame = ZeroFrames(end);
    
    Events.TakeOffTime = ZeroFrames(1)/fs;
    Events.LandingTime = ZeroFrames(end)/fs;
    
    Events.CEINMS =  [Events.TakeOffTime - 0.5 Events.LandingTime + 0.5]; 
    if Events.CEINMS(2) > data.fp_data.Time(end)
        Events.CEINMS(2) = data.fp_data.Time(end);
    end
    
    Events.StartFrame = [Events.CEINMS(1)]*fs;
    Events.EndFrame = [Events.CEINMS(2)]*fs;
    
    Events.StartTime = [Events.CEINMS(1)];
    Events.EndTime = [Events.CEINMS(2)];
    
   
    
elseif contains(Task, 'Squat')
    % find sacrum markers
    fs = data.marker_data.Info.frequency;
    Markers = fields(data.marker_data.Markers);
    idx = find(contains(Markers,{'SACR'}))';
    
    Start =[];
    End =[];
    for k = idx

        PosZ = data.marker_data.Markers.(Markers{k})(:,3);
        Baseline = mean(PosZ(1:fs));
        Vel = diff(PosZ);
        
        % low pass velocity
        Fnyq = fs/2;
        fcolow = 6;
        [b,a] = butter(2,fcolow*1.25/Fnyq,'low');
        Vel = filtfilt(b,a,Vel);                                             % low pass filter;
        
        D = find(Vel<-0.2); % define based on velocity
        Start(end+1) = D(1);
        End(end+1) = D(end);
        
    end
    

    Events.StartFrame = mean(Start);
    Events.EndFrame = mean(End);
    
    Events.StartTime = mean(Start)/fs;
    Events.EndTime =mean(End)/fs;
    
    Events.CEINMS =  [Events.StartTime  Events.EndTime]; 
    
end

