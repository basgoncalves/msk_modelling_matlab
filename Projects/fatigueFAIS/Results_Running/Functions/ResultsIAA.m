
% COM_X


function [LegCont,CLCont] = ResultsIAA(DirIAA)

fp = filesep;
files = dir(DirIAA);
DirElaborated = DirUp(DirIAA,1);
[~,Subject] = DirUp(DirElaborated,2);
DirC3D = strrep(DirElaborated,'ElaboratedData','InputData');
DirID = strrep(DirIAA, 'inducedAccelerationAnalysis', 'inverseDynamics');
DirIK = strrep(DirIAA, 'inducedAccelerationAnalysis', 'inverseKinematics');



%import sampling rates
load([DirElaborated fp 'sessionData' fp 'Rates.mat'])
fs = Rates.VideoFrameRate;
DirResults_RSFAI = ([DirUp(DirElaborated,3) fp 'Results' fp 'RS_FAIS']);
load([DirResults_RSFAI fp 'CEINMSdata.mat'])
cd(DirResults_RSFAI)

% set outputs
LegCont = struct;
LegCont.COM_X = struct;
LegCont.hip_flexion = struct;
LegCont.knee_flexion = struct;

%contralateral leg
CLCont = struct;
CLCont.COM_X = struct;
CLCont.hip_flexion = struct;
CLCont.knee_flexion = struct;


for k = 3: length(files)
    
    trialName = files(k).name;
    
    if ~exist([DirIAA fp trialName fp 'IndAccPI_Results' fp trialName '_IndAccPI_ankle_angle_l.sto'])
        continue
    end
    
    [TestedLeg,CL] = findLeg(DirElaborated,trialName);
    [~, ~,FootContact] = TimeWindow_FatFAIS(DirC3D,trialName,TestedLeg);

    XML = xml_read([DirIAA fp trialName fp 'setup_IAA.xml']);
    TimeWindow = [XML.AnalyzeTool.initial_time XML.AnalyzeTool.final_time];
    DirResultsIAA = [DirIAA fp trialName fp 'IndAccPI_Results' fp trialName '_IndAccPI'];
        
    %% contributions of tested leg to COM acceleration (anterio/posterior - X)
    s = lower(TestedLeg{1});
    cl = lower(CL{1});
    motion = 'COM_X';
    fileName = ['_' motion '.sto'];
    [MODEL,EXP,CONTRIB,CONTRIB_CL,time] = IAAtrialPlot(DirResultsIAA,fileName,s,cl,TimeWindow);
    suptitle(['Horizontal COM acceleration (stance leg)'])
    
    LegCont.COM_X.(trialName) = CONTRIB;
    CLCont.COM_X.(trialName) = CONTRIB_CL;
    
    cd(DirUp(DirResultsIAA,2))
    saveas(gca,[motion '.tiff'])    
    %% contributions of _hip_flexion
    s = lower(TestedLeg{1});
    cl = lower(CL{1});
    motion = 'hip_flexion';
    fileName = ['_' motion '_' s '.sto'];
    [MODEL,EXP,CONTRIB,CONTRIB_CL,time] = IAAtrialPlot(DirResultsIAA,fileName,s,cl,TimeWindow);
    suptitle(['hip flexion_' s ' acceleration (stance leg)'])
    
    LegCont.hip_flexion.(trialName) = CONTRIB;
    CLCont.hip_flexion.(trialName) = CONTRIB_CL;
    
    cd(DirUp(DirResultsIAA,2))
    saveas(gca,[motion '.tiff']) 
    %% contributions of tested leg to _knee_angle_
    s = lower(TestedLeg{1});
    cl = lower(CL{1});
    motion = 'knee_angle';
    fileName = ['_' motion '_' s '.sto'];
    [MODEL,EXP,CONTRIB,CONTRIB_CL,time] = IAAtrialPlot(DirResultsIAA,fileName,s,cl,TimeWindow);
    suptitle([strrep(fileName,'.sto','')  ' acceleration (stance leg)'])
    
    LegCont.knee_flexion.(trialName) = CONTRIB;
    CLCont.knee_flexion.(trialName) = CONTRIB_CL;    
    
    cd(DirUp(DirResultsIAA,2))
    saveas(gca,[motion '.tiff'])

    close all
end


