% define stride sub-phases as 
% (1) early stance (from FS to maximum knee angle in stance)
% (2) late stance (from maximum knee angle in stance to TO)
% (3) early swing (from TO to maximum knee angle in swing)
% (4) mid swing (from maximum knee angle in swing to maximum hip flexion angle)
% (5) late swing (from maximum hip flexion angle to ipsilateral FS) 
% (Higashihara et al., 2015)

% SF = stride phases
function SP = gaitcycleIK (IKfilename,GRFmot_file,TestedLeg)

L = lower(TestedLeg{1});

% import inverse kinematics data
IKdata = importdata (IKfilename);
fsIK = 1/(IKdata.data(2,1)-IKdata.data(1,1));

% import GRF data 
GRFstruct = importdata(GRFmot_file);
[GRF, LabelGRF, idxLabelGRF] =findData(GRFstruct.data,GRFstruct.colheaders,{'vz'},2);
fsGRF = 1/(GRFstruct.data(2,1)-GRFstruct.data(1,1));
fsRatio = round(fsGRF / fsIK);

% find region where there is GRF  
[Frames,FPN] = size(GRF);
idx =[];
Fz = zeros(ceil(Frames/10),1);
for pp = 1:FPN
    Fz = Fz +  downsample(GRF(:,pp),fsRatio); % vert GRF for the tested leg

end
    idx = unique([idx; find(Fz)]);
% find early stance 
[Angle,Label,idxLabel] = findData(IKdata.data,IKdata.colheaders,{['knee_angle_' L]}); 
[Peak,PeakID] = findpeaks(Angle);
realPeaks = find(Peak>max(Angle)*0.8);
Peak = Peak(realPeaks);


% find early stance 
[Angle,Label,idxLabel] = findData(IKdata.data,IKdata.colheaders,{['hip_flexion_' L]}); 
[Peak,PeakID] = findpeaks(Angle);
realPeaks = find(Peak>max(Angle)*0.8);
% = NaN;


figure
plot(Angle)
hold on
yyaxis right
plot()

fs = data.marker_data.Info.frequency;
fsRatio = data.fp_data.Info(1).frequency / fs ;
shortFZ = downsample(Fz,fsRatio);
idx = find(shortFZ);
[Peak,PeakID] = findpeaks(IKdata.data(:,6));

MIN = [];
for k = 1: length(PeakID)
    if  sum(find(idx==PeakID(k))) >0
        [MIN(k),] = NaN;
    else
        [MIN(k),] = min(idx-PeakID(k));
    end
end

x = [];  % 
[~,id] = min(abs(MIN));% position of the minimum value
x(1) = PeakID(id);
MIN(id) = NaN;     % make the minumm value = NaN so we can find a new minimum

[~,id] = min(abs(MIN));% position of the second minumm value 
x(2) = PeakID(id);

x = sort(x);