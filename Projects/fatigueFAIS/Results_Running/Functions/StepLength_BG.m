% Basilio Goncalves 2020
% step length calculation after using MoTONMS and Open Sim to get
% kinematics

OrganiseFAI
RunNames = {'Run_baselineA1';'Run_baselineB1';'RunA1';'RunB1';'RunC1';'RunD1';'RunE1';'RunF1';...
    'RunG1';'RunH1';'RunI1';'RunJ1';'RunK1';'RunL1'};
%%
cd([DirMocap filesep 'ElaboratedData'])
FilesElab = dir;
FilesElab (1:2) =[];
StepLength=[];
StepFreq=[];
StepLocation=[];
description = {};
disp('calculating step length/frequency...')
for ss = 1: length(FilesElab)
    OldSubject = Subject;
    Subject = FilesElab(ss).name;
    SubjectNum = str2num (Subject);
    DirC3D = strrep(DirC3D,[filesep OldSubject],[filesep Subject]);
    OrganiseFAI
    
    description{1,ss} = Subject;
    cd(DirIK)
    
    Trials = dir(sprintf('%s\\%s',DirIK));
    for tt =  3: length(Trials)
        
        TrialName = erase (Trials(tt).name,'_IK.mot');
        
        if sum(contains (RunNames,TrialName))>0
            Row = find(contains (RunNames,TrialName));
            load ([DirIK filesep TrialName filesep 'GaitCycle.mat']);
            c3dData = btk_loadc3d([DirInput filesep Subject filesep 'pre' filesep ...
                TrialName '.c3d']);
            Leg =  TestedLeg{1};
            % ratio of frquency = freq of force plates / freq Mocap
            fs_mocap = c3dData.marker_data.Info.frequency;
            fs_ratio = c3dData.fp_data.Info(1).frequency ./ fs_mocap;
            MarkerNames = fields(c3dData.marker_data.Markers);
            MarkerNames = MarkerNames(find (contains(MarkerNames, Leg)));
            MarkerNames = MarkerNames(find(contains(MarkerNames,'MT')));
            
            %Step length = difference in position(XYZ) at Toe Off 1 and 2
            TO = GaitCycle.ToeOff-GaitCycle.FirstFrameC3D;
            
            if ~isempty(MarkerNames)&& length(GaitCycle.ToeOff)>1 && ...
                    TO(2)<length (c3dData.marker_data.Markers.(MarkerNames{1})) && ...
                    TO(1)>0
                
                X1 = c3dData.marker_data.Markers.(MarkerNames{1})(TO(1),1);
                X2 = c3dData.marker_data.Markers.(MarkerNames{1})(TO(2),1);
                Y1 = c3dData.marker_data.Markers.(MarkerNames{1})(TO(1),2);
                Y2 = c3dData.marker_data.Markers.(MarkerNames{1})(TO(2),2);
                Z1 = c3dData.marker_data.Markers.(MarkerNames{1})(TO(1),3);
                Z2 = c3dData.marker_data.Markers.(MarkerNames{1})(TO(2),3);
                %  step length in METERS
                StepLength(Row,ss) = sqrt((X2-X1)^2 + (Y2-Y1)^2 + (Z2-Z1)^2)/1000;
                % step frequency
                StepFreq (Row,ss) = 1/((TO(2)-TO(1))/fs_mocap);
                % contact time
                
                %Step Location at foot contact
                FC = GaitCycle.foot_contacts(1)-GaitCycle.FirstFrameC3D;
                PosFC = c3dData.marker_data.Markers.(MarkerNames{1})(FC,2);
                % location in meters(8.2 = start line to the ende of force plates)
                StepLocation (Row,ss) = 8.2-(PosFC/1000);
            end
        end
        
    end
    
end

MeanSL = mean(StepLength,1);  % mean of each column (trial)
MeanSF = mean(StepFreq,1);


disp ('done')

cd(DirResults)
save SpatioTemporal description StepFreq StepLength StepLocation MeanSL MeanSF

%% Figures
% Match SPSS data
cd(DirResults)
load ('SpatioTemporal.mat')
description = description';
StepLength= StepLength';
StepFreq = StepFreq';
StepLocation = StepLocation';

Mean2StepLength = MeanNcol(StepLength,2);
deltaSetpLength = (Mean2StepLength(:,end)-Mean2StepLength(:,1))./Mean2StepLength(:,1)*100;
Mean2StepFreq = MeanNcol(StepFreq,2);
deltaStepFreq = (Mean2StepFreq(:,end)-Mean2StepFreq(:,1))./Mean2StepFreq(:,1)*100;


load('MaxRuningVelocity.mat')
MaxRuningVelocity = deleteZeros(MaxRuningVelocity);
MaxRuningVelocity = MaxRuningVelocity';
StepLocation(StepLocation==0)=NaN;
R=[];
figure
for ii = 1:size(StepLocation,1)
    y = MaxRuningVelocity(ii,:);
    x = StepLocation (ii,:);
    scatter (x,y)
    xlabel('Location of the step (meters from start)')
    ylabel ('Horizontal velocity (m/s)')
    hold on
    r = corrcoef(rmmissing(x),rmmissing(y));
    R(ii) = r(1,2);
    [a,b]=polyfit(rmmissing(x),rmmissing(y),1);
    
    
end
% vertical bars for each force plate
Ymax = max(ylim);
for ii = 1:3
    Xpos = 8.2-(ii-1)*0.9;
    plot ([Xpos Xpos],[0 Ymax],'k')
    Xpos = Xpos - 0.45;
    Txt = sprintf('Force plate %d',ii);
    text (Xpos,Ymax,Txt,'HorizontalAlignment','center')
end
mmfn
cd(DirFigure)
