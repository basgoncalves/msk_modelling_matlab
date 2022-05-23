
function rotateFP

AcquisitionInterface_BOPS
bops = load_setup_bops;
subject = load_subject_settings;

ElaborationFilePath = subject.directories.dynamicElaborations;
[foldersPath,parameters]= DataProcessingSettings(ElaborationFilePath);

trialsList=parameters.trialsList;
foldersPath.trialOutput = mkOutputDir(foldersPath.elaboration,trialsList);
globalToOpenSimRotations = parameters.globalToOpenSimRotations;
FPtoGlobalRotations = parameters.FPtoGlobalRotations;
motionDirections=parameters.motionDirection;

load([foldersPath.sessionData 'ForcePlatformInfo.mat'])
nFP=length(ForcePlatformInfo);
if isfield(parameters,'platesPad')
    padsThickness=parameters.platesPad;
else
    padsThickness=zeros(1,nFP);
end

FPRawData=loadMatData(foldersPath.sessionData, trialsList, 'FPdata');
[Forces,Moments,COP]= AnalogDataSplit(FPRawData,ForcePlatformInfo);

switch ForcePlatformInfo{1}.type   %assumption: FPs are of the same type
    
    case {2,3,4}
        
        if (exist('fcut','var') && isfield(fcut,'f'))
            filtForces=DataFiltering(Forces,AnalogFrameRate,fcut.f);
            filtMoments=DataFiltering(Moments,AnalogFrameRate,fcut.f);
        else
            filtForces=Forces;
            filtMoments=Moments;
        end
        
        %In this case, COP have to be computed
        %Necessary Thresholding for COP computation
        [ForcesThr,MomentsThr]=FzThresholding(filtForces,filtMoments);
        
        for k=1:length(filtMoments)
            for i=1:nFP
                COP{k}(:,:,i)=computeCOP(ForcesThr{k}(:,:,i),MomentsThr{k}(:,:,i), ForcePlatformInfo{i}, padsThickness(i));
            end
        end
        
        filtCOP=COP; %not necessary to filter the computed cop
        
        
    case 1   %Padova type: it returns Px & Py
        
        if (exist('fcut','var'))
            
            if isfield(fcut,'f')
                
                filtForces=filteringDataFPtype1(Forces,AnalogFrameRate,fcut.f,'Forces');
                filtMoments=filteringDataFPtype1(Moments,AnalogFrameRate,fcut.f,'Moments');
                
            else
                filtForces=Forces;
                filtMoments=Moments;
            end
            
            if isfield(fcut,'cop')
                
                filtCOP=filteringDataFPtype1(COP,AnalogFrameRate,fcut.cop,'COP');
            else
                filtCOP=COP;
            end
            
        else
            filtForces=Forces;
            filtMoments=Moments;
            filtCOP=COP;
        end
        %Threasholding also here for uniformity among the two cases
        [ForcesThr,MomentsThr]=FzThresholding(filtForces,filtMoments);
end


[~, ~, Frames]=loadMatData(foldersPath.sessionData, trialsList, 'Markers');
WindowsSelection=parameters.WindowsSelection;
StancesOnFP=parameters.StancesOnFP;
load([foldersPath.sessionData 'Rates.mat'])

AnalogFrameRate = Rates.AnalogFrameRate;

AnalysisWindow=AnalysisWindowSelection(WindowsSelection,StancesOnFP,filtForces,Frames,Rates);

[ForcesFiltered,~]=selectionData(ForcesThr,AnalysisWindow,Rates.AnalogFrameRate);
[MomentsFiltered,~]=selectionData(MomentsThr,AnalysisWindow,AnalogFrameRate);
[COPFiltered,Ftime]=selectionData(filtCOP,AnalysisWindow,AnalogFrameRate);


for k = 1:length(trialsList)
    globalMOTdata{k}=[];
    
    for i=1:nFP
        Torques{k}(:,:,i)= computeTorque(ForcesFiltered{k}(:,:,i),MomentsFiltered{k}(:,:,i),COPFiltered{k}(:,:,i),ForcePlatformInfo{i});
        
        globalForces{k}(:,:,i)  = RotateCS (ForcesFiltered{k}(:,:,i),FPtoGlobalRotations(i));
        globalTorques{k}(:,:,i) = RotateCS (Torques{k}(:,:,i),FPtoGlobalRotations(i));
        globalCOP{k}(:,:,i)     = convertCOPToGlobal(COPFiltered{k}(:,:,i),FPtoGlobalRotations(i),ForcePlatformInfo{i});
        
        globalMOTdata{k}=[globalMOTdata{k} globalForces{k}(:,:,i) globalCOP{k}(:,:,i) ];
    end
    
    for i=1:nFP
        globalMOTdata{k}=[globalMOTdata{k} globalTorques{k}(:,:,i) ];
    end
    
    MOTdataOpenSim{k}=RotateCS (globalMOTdata{k},globalToOpenSimRotations);                                             %Rotation for OpenSim
    
    MOTrotDataOpenSim{k}=rotatingMotionDirection(motionDirections{k},MOTdataOpenSim{k});                                %accounting for the possibility of different directions of motion
    
    FullFileName=[foldersPath.trialOutput{k} 'grf.mot'];                                                                %Write MOT
    writeMot(MOTrotDataOpenSim{k},Ftime{k},FullFileName)
    
    
    trialName = trialsList{k};
    trialAnalysisPath = [subject.directories.IK fp trialName];                                                          % DEFINE ANALYSIS PATH
    fprintf(['\n ' trialName '\n'])
    [osimFiles] = getdirosimfiles_BOPS(trialName,trialAnalysisPath);                                                    % get directories of opensim files for this trial
    
    copyfile(osimFiles.externalforces,[trialAnalysisPath fp 'grf.mot'])                                                 % usefull for checking data in the gui easier
    
end