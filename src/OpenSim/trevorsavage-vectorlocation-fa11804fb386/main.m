% MAIN

% FORCE VECTOR LOCATION
% BRANCH - MASTER

%% ABOUT ME
% -------------------------------------- 
% This code:
%  *  loads the AGGREGATED data for each execution mode 
%     !OR!
%     loads individual PARTICIPANT data for one trial for each execution mode
%  *  gets the scale factors for all participants to be analysed
%  *  using the scaled stl of the right femur, determines the location
%     of the force vector
%  *  saves and plots the result
%---------------------------------------
%% RUN SPECS
% Run on Matlab 2019a or later
% To use this code you need the following add-ons from MATLAB file exchange
% stl Tools
% https://au.mathworks.com/matlabcentral/fileexchange/51200-stltools?s_tid=FX_rc1_behav
% geom3d
% https://au.mathworks.com/matlabcentral/fileexchange/24484-geom3d

% Set the paths to these in the settings below

% All other functions and process by T.N.SAVAGE, 2019-21

%% TO DO:
% ------------------------------
% * Incorporate regression based femoral and acetabular distances

clearvars; clc;

%% SETTINGS
% paths to required functions
paths.stlTools = 'C:\Users\s5001683\Documents\MATLAB\Add-Ons\Toolboxes\stlTools\stlTools';
paths.geom3d   = 'C:\Users\s5001683\Documents\MATLAB\matGeom\matGeom\geom3d';
paths.setup    = 'C:\Users\s5001683\PhD\Mocap\SetUpFiles';

% data processing settings
anawin         = 1;     % <- ANALYSIS WINDOW: Gait cycle [1] or stance phase [2]
osimfemrad     = 23.0; % <- From stlRadius script
osimacerad     = osimfemrad;
cohortID       = {'FAI'};  % 'FAI'; OR 'MDS';
process        = 'participant'; % 'cohort'; OR 'participant';
  %-------------------------
  % IF process = participant, adjust settings here
  subjectNames = {'FAS-321'; 'FAS-324'; 'FAS-331'; 'FAS-602'; 'FAS-603'; ...
                'FAS-604'; 'FAS-605'; 'FAS-606'; 'FAS-608'; 'FAS-611'; ...
                'FAS-614'; 'FAS-617'; 'FAS-623'; 'FAS-626'; 'FAS-630'; ... 
                'FAS-632'; 'FAS-635'; 'FAS-637'; 'FAS-639'; 'FAS-643'; ... 
                'FAS-646'; 'FAS-647'; 'FAS-650'; 'FAS-652'; 'FAS-658'; ...
                'FAS-659'; 'FAS-662'; 'FAS-663'; 'FAS-665'; 'FAS-666'; ...
                'FAS-669'; 'FAS-670'; 'FAS-671'; 'FAS-902'; 'FAS-905'; ...
                'FAS-910'; 'FAS-911'; 'FAS-914'; 'FAS-915'; 'FAS-916'; ...
                'FAS-917'};% PARTID or ALLPARTIC'   <-- list subject you want to process here
  trial        = 'ALLTRIALS';  % TRIALID or 'ALLTRIALS' <-- list trial you want to process here
  side         = 'Right'; % Left; Right
  %-------------------------

% Folder settings
% Outputs will be saved to the path defined my these variables...
%
% mocapFolder/cohortID/[ANALYSES]/idCNMS/idPub/executionModes
%
% Uppercase in above indicates hardcoded name

mocapFolder    = 'C:\Users\s5001683\PhD\Mocap'; % F:\PhD\Mocap\
SessionID      = 'Session_1'; %'Session_1'; 'Session_2';
executionModes = {'StaticOpt'};% 'Hybrid'; 'Openloop'; 'StaticOpt'};
refframe       = {'Pelvis'; 'Femur'}; % Order pelvis first and then femur 
idElab         = ('Walk_ISB');      % [MOtoNMS] dynamic elaboration identifier or folder name --> Walk_ISB Walk
idBOPS         = ('Walk_ISB-8');    % [BOPS] data analysis identifier or folder name
idPelvis       = ('Walk_ISB-8a');   % [BOPS] data analysis identifier or folder name for corrected pelvis
idCNMS         = ('Walk_ISB-8min'); % [CEINMS] data analysis identifier or folder name
idEXEC         = ('Walk_ISB-8min'); % ('Walk_ISB-8hands_old');
idModel        = idBOPS;            % [Model folder] Name of sub directory in model folder holding the model that you want to use
idPub          = ('FAIGaitBiom_n41');   % name of the subanalysis for the conference or publication

% % %Set the model that you want to work with for IK/ID/MA
% ScaledModel  = (['_' cohortID{i} '_linearScaled.osim']);
% OptMuscModel = (['_' cohortID{i} '_Scaled_Pose_OptMusc_Hands.osim']);

%% ANALYSIS
for i = 1:length(cohortID)
    % Starting folder for input and elaboration files
    startingFolder = ([mocapFolder filesep cohortID{i}]);
    % Path where your base opensim model and all your setup xmls for scaling are kept
    setUpFolder    = ([mocapFolder filesep 'SetUpFiles']);
    dirElab        = uigetdir(startingFolder,'Select ELABORATED Data Folder');
    dirInput       = regexprep(dirElab, 'ElaboratedData', 'InputData');
    dirAnalyses    = regexprep(dirElab, 'ElaboratedData', 'Analyses');
    dirPlot        = ([dirAnalyses filesep idCNMS filesep idPub filesep executionModes{1} filesep 'figures']);
    % check if dirPlot exists and if not create it...
    if ~exist(dirPlot, 'dir')
        mkdir(dirPlot)
    end
    % Change baseline/follow up and session tags here
    if strcmp(cohortID, 'FAI') ==1
        % TimePoint = 'Baseline'; %'Baseline'; 'FollowUp';
    end
   
    switch process
    case 'participant'
        %% ------------------------------
        % PROCESS INDIVIDUAL PARTICIPANTS
        %--------------------------------
        % §---TO BATCH PROCESS ALL SUBJECTS IN A DIRECTORY---§
        % ----------------------------------------------------
        if strcmp(subjectNames, 'ALLPARTIC') == 1
            subsdir        = dir(dirInput);
            isub           = [subsdir(:).isdir]; %# returns logical vector of subdirectories
            subjectNames   = {subsdir(isub).name}';
            subjectNames(ismember(subjectNames,{'.','..', 'FAS-667', 'FAS-668', 'FAS-912'})) = [];%, 'M03', 'M04', 'M10', 'FAS-667','FAS-668',})) = [];%,
        end
        
        load femmetaData.mat
        for rf = 1:length(refframe)
            for s = 1:length(subjectNames)
                disp(['processing ' subjectNames{s}]);
                partPath = ([dirElab filesep subjectNames{s} filesep SessionID]);
                dirIK    = ([partPath filesep 'inverseKinematics' filesep idBOPS filesep]);
                if strcmp(trial, 'ALLTRIALS') == 1
                    trials = getTrials(dirIK);
                end
                shtName               = strrep(subjectNames{s},'-',''); % <- subject name without hyphen
                load([partPath filesep 'inverseKinematics' filesep idBOPS filesep shtName '_ik_data.mat']);
                modelPath             = ([setUpFolder filesep 'FAI_generic.osim']);
                SF(s)                 = getScaleFactors(dirElab, {subjectNames{s}}, idModel);
                acquisition           = xml_read([dirInput filesep subjectNames{s} filesep SessionID filesep 'acquisition.xml']);
                mass                  = acquisition.Subject.Weight;
                height(s)             = acquisition.Subject.Height;
                side                  = acquisition.Subject.InstrumentedLeg;
                fr                    = acquisition.VideoFrameRate;
                %[osimacerad, osimfemrad] = getRadius(height(s), acquisition.subject.Sex)
                % rad = (osimacerad - osimfemrad)/2;
                % stlRadius(paths, side, SF)
                vecDist.metadata(s).subject    = shtName;
                vecDist.metadata(s).frame      = refframe{rf};
                vecDist.metadata(s).SF         = SF(s);
                vecDist.metadata(s).height     = height(s);
                vecDist.metadata(s).side       = side;
                sRad(s) = SF(s) * osimfemrad;%<- Scaled femoral radius 
                vecDist.metadata(s).femrad_s   = sRad(s);
                % Check edin's measured femoral radius
                for j = 1:length(femmetaData)
                    if regexp(femmetaData(j).partID,shtName)
                        vecDist.metadata(s).femrad_m = femmetaData(j).femrad;
                        vecDist.metadata(s).acerad_m = femmetaData(j).acerad;
                        vecDist.metadata(s).artrad_m = mean([femmetaData(j).femrad; femmetaData(j).acerad]);
                        break
                    end
                end
                for ex = 1:length(executionModes)
                    for t = 1:length(trials)
                        forcePath        = ([partPath filesep 'ceinms\execution' filesep idCNMS filesep executionModes{ex} filesep trials{t} filesep 'ContactForces.sto']);
                        IKPath           = ([partPath filesep 'inverseKinematics' filesep idBOPS filesep trials{t} filesep 'ik.mot']);
                        % transform HCF vector from global to femoral frame
                        transformedvec   = transformRefFrame(modelPath, forcePath, IKPath, side, refframe{rf});
                        JCF              = transformedvec.data; clear transformedvec;
                        % get gait cycle events
                        [phases, stridx] = getGaitEventIndexes(dataIK, JCF, trials{t}, anawin);
                        % -------------------------------------------------
                        % constrain the force to the analysis window 
                        % (HS1 to HS2) and save for visualisations later on
                        gcJCF            = JCF(stridx(1):stridx(2),2:4); 
                        for g = 1:size(gcJCF,2)
                            gcJCFi(:,g)  = interpolateData(gcJCF(:,g)',fr,100)';
                        end
                        % gait cycle rotation matrix
                        gcrotm           = getrotm(-gcJCFi, paths, side, SF(s));
                        % rotm to quaternion
                        gcquat(:,t)      = quaternion(gcrotm,'rotmat', 'point');
                        clear gcJCF gcJCFi g gcrotm
                        % ------------------------------------------------
                        % and ...
                        % use whole window to use events for comparison of
                        % gait phases
                        force            = JCF(:,2:4);% ./ (mass * -9.81);
                        to(t)            = (phases(4).stop - phases(1).start)/(phases(5).stop - phases(1).start);
                        % get rotation matrix by evaluating angles between force vector and [1 0 0]
                        rotm             = getrotm(-force, paths, side, SF(s)); %rotm3 = getrotm_sax(force);
                        % convert rotation matrix to quaternion
                        quat             = quaternion(rotm,'rotmat', 'point');
                        % get mean rotation from [1 0 0] as a quaternion
                        %% DETERMINE AVERAGE VECTOR AND EULER ANGLES DURING GAIT PHASES
                        mquat.gaitcyc(t,:)    = meanrot(quat(stridx(1):stridx(2),1)); % <- get mean rotation
                        mquat.stance(t,:)     = meanrot(quat(phases(1).start:phases(4).stop,1)); % <- get mean rotation                    
                        mquat.loading (t,:)   = meanrot(quat(phases(1).start:phases(1).stop,1)); % <- get mean rotation
                        mquat.midstance(t,:)  = meanrot(quat(phases(2).start:phases(2).stop,1)); % <- get mean rotation
                        mquat.latestance(t,:) = meanrot(quat(phases(3).start:phases(3).stop,1)); % <- get mean rotation
                        mquat.preswing(t,:)   = meanrot(quat(phases(4).start:phases(4).stop,1)); % <- get mean rotation
                        mquat.swing(t,:)      = meanrot(quat(phases(5).start:phases(5).stop,1)); % <- get mean rotation
                        rotm2                 = quat2rotm(quat); %compare rotm to rotm2 to check the calcs
                        % multiply scaled X vector ([1 0 0]* SF) by rotation matrix to get AVERAGE POSITION OF CoP
                        mpos.gaitcyc(t,:)     = [1 0 0] * quat2rotm(mquat.gaitcyc(t,1));
                        mpos.stance(t,:)      = [1 0 0] * quat2rotm(mquat.stance(t,1));                    
                        mpos.loading(t,:)     = [1 0 0] * quat2rotm(mquat.loading(t,1));
                        mpos.midstance(t,:)   = [1 0 0] * quat2rotm(mquat.midstance(t,1));
                        mpos.latestance(t,:)  = [1 0 0] * quat2rotm(mquat.latestance(t,1));
                        mpos.preswing(t,:)    = [1 0 0] * quat2rotm(mquat.preswing(t,1));
                        mpos.swing(t,:)       = [1 0 0] * quat2rotm(mquat.swing(t,1));
                        % average euler angles
                        eul(t,:).gaitcyc       = quat2eul(mquat.gaitcyc(t,:),'ZYX'); % rad2deg(eul) % return to euler angle
                        eul(t,:).stance        = quat2eul(mquat.stance(t,:),'ZYX'); 
                        eul(t,:).loading       = quat2eul(mquat.loading(t,:),'ZYX');
                        eul(t,:).midstance     = quat2eul(mquat.midstance(t,:),'ZYX');
                        eul(t,:).latestance    = quat2eul(mquat.latestance(t,:),'ZYX');
                        eul(t,:).preswing      = quat2eul(mquat.preswing(t,:),'ZYX');
                        eul(t,:).swing         = quat2eul(mquat.swing(t,:),'ZYX');
                        % getForceLocation_stl(-force(stridx(1):stridx(2),:), paths, SF, phases, fr, 100, side);
                        [dvec.gaitcyc(:,t), dmvec.gaitcyc(:,t), pintsect, vecAr.gaitcyc(:,t), a.gaitcyc(t)] = getForceLocation_sphere(force(stridx(1):stridx(2),:), mpos.gaitcyc(t,:), mpos.gaitcyc(t,:), refframe{rf}, paths, side, sRad(s), fr, 100);
                        [dvec.stance(:,t), dmvec.stance(:,t), ~, vecAr.stance(:,t), a.stance(t)]            = getForceLocation_sphere(force(phases(1).start:phases(4).stop,:), mpos.stance(t,:), mpos.gaitcyc(t,:), refframe{rf}, paths, side, sRad(s), fr, 60);
                        [dvec.loading(:,t), dmvec.loading(:,t), ~, vecAr.loading(:,t), a.loading(t)]        = getForceLocation_sphere(force(phases(1).start:phases(1).stop,:), mpos.loading(t,:), mpos.gaitcyc(t,:), refframe{rf}, paths, side, sRad(s), fr, 10);
                        [dvec.midstnce(:,t), dmvec.midstnce(:,t), ~, vecAr.midstnce(:,t), a.midstnce(t)]    = getForceLocation_sphere(force(phases(2).start:phases(2).stop,:), mpos.midstance(t,:), mpos.gaitcyc(t,:), refframe{rf}, paths, side, sRad(s), fr, 20);
                        [dvec.l8stnce(:,t), dmvec.l8stnce(:,t), ~, vecAr.l8stnce(:,t), a.l8stnce(t)]        = getForceLocation_sphere(force(phases(3).start:phases(3).stop,:), mpos.latestance(t,:), mpos.gaitcyc(t,:), refframe{rf}, paths, side, sRad(s), fr, 20);
                        [dvec.preswing(:,t), dmvec.preswing(:,t), ~, vecAr.preswing(:,t), a.preswing(t)]    = getForceLocation_sphere(force(phases(4).start:phases(4).stop,:), mpos.preswing(t,:), mpos.gaitcyc(t,:), refframe{rf}, paths, side, sRad(s), fr, 10);
                        [dvec.swing(:,t), dmvec.swing(:,t), ~, vecAr.swing(:,t), a.swing(t)]                = getForceLocation_sphere(force(phases(5).start:phases(5).stop,:), mpos.swing(t,:), mpos.gaitcyc(t,:), refframe{rf}, paths, side, sRad(s), fr, 40);
                        %[dvec(:,t), dmvec(:,t)]     = getForceLocation_sphere(force, avvec(t,:), paths, SF(s), side);
                        % checkIntersect(pintsect,rotm2(:,:,stridx(1):stridx(2)), sRad(s), paths);
                        cumdist.gaitcyc(:,t)    = cumsum(dvec.gaitcyc(:,t));
                        cumdist.stance(:,t)     = cumsum(dvec.stance(:,t));                    
                        cumdist.loading(:,t)    = cumsum(dvec.loading(:,t));
                        cumdist.midstance(:,t)  = cumsum(dvec.midstnce(:,t));
                        cumdist.latestance(:,t) = cumsum(dvec.l8stnce(:,t));
                        cumdist.preswing(:,t)   = cumsum(dvec.preswing(:,t));
                        cumdist.swing(:,t)      = cumsum(dvec.swing(:,t));
                        clear force HCF rotm quat phases
                    end
                end
                %% ASSEMBLE SUBJECT AVERAGE
                vecDist.dist.gaitcyc(s).subject       = shtName;
                vecDist.dist.gaitcyc(s).mean          = mean(dvec.gaitcyc,2);
                vecDist.dist.gaitcyc(s).sd            = std(dvec.gaitcyc,0,2);
                vecDist.dist.gaitcyc(s).ci            = CalcCI(vecDist.dist.gaitcyc(s).sd, length(trials));
                vecDist.quat.gaitcyc(s,1)             = meanrot(mquat.gaitcyc);
                vecDist.mpos.gaitcyc(s,:)             = [1 0 0] * quat2rotm(vecDist.quat.gaitcyc(s,1));
                vecDist.dist.gaitcyc(s).colheaders    = {'HCFvecChangeDist_GAITCYCLE'};
                vecDist.dist.stance(s).subject        = shtName;
                vecDist.dist.stance(s).mean           = mean(dvec.stance,2);
                vecDist.dist.stance(s).sd             = std(dvec.stance,0,2);
                vecDist.dist.stance(s).ci             = CalcCI(vecDist.dist.stance(s).sd, length(trials));
                vecDist.quat.stance(s,1)              = meanrot(mquat.stance);
                vecDist.mpos.stance(s,:)              = [1 0 0] * quat2rotm(vecDist.quat.stance(s,1));
                vecDist.dist.stance(s).colheaders     = {'HCFvecChangeDist_STANCE'};            
                vecDist.dist.loading(s).subject       = shtName;
                vecDist.dist.loading(s).mean          = mean(dvec.loading,2);
                vecDist.dist.loading(s).sd            = std(dvec.loading,0,2);
                vecDist.dist.loading(s).ci            = CalcCI(vecDist.dist.loading(s).sd, length(trials));
                vecDist.quat.loading(s,1)             = meanrot(mquat.loading);
                vecDist.mpos.loading(s,:)             = [1 0 0] * quat2rotm(vecDist.quat.loading(s,1));
                vecDist.dist.loading(s).colheaders    = {'HCFvecChangeDist_Loading'};
                vecDist.dist.midstance(s).subject     = shtName;
                vecDist.dist.midstance(s).mean        = mean(dvec.midstnce,2);
                vecDist.dist.midstance(s).sd          = std(dvec.midstnce,0,2);
                vecDist.dist.midstance(s).ci          = CalcCI(vecDist.dist.midstance(s).sd, length(trials));
                vecDist.quat.midstance(s,1)           = meanrot(mquat.midstance);
                vecDist.mpos.midstance(s,:)           = [1 0 0] * quat2rotm(vecDist.quat.midstance(s,1));
                vecDist.dist.midstance(s).colheaders  = {'HCFvecChangeDist_Midstance'};
                vecDist.dist.latestance(s).subject    = shtName;
                vecDist.dist.latestance(s).mean       = mean(dvec.l8stnce,2);
                vecDist.dist.latestance(s).sd         = std(dvec.l8stnce,0,2);
                vecDist.dist.latestance(s).ci         = CalcCI(vecDist.dist.latestance(s).sd, length(trials));
                vecDist.quat.latestance(s,1)          = meanrot(mquat.latestance);
                vecDist.mpos.latestance(s,:)          = [1 0 0] * quat2rotm(vecDist.quat.latestance(s,1));
                vecDist.dist.latestance(s).colheaders = {'HCFvecChangeDist_Latestance'};
                vecDist.dist.preswing(s).subject      = shtName;
                vecDist.dist.preswing(s).mean         = mean(dvec.preswing,2);
                vecDist.dist.preswing(s).sd           = std(dvec.preswing,0,2);
                vecDist.dist.preswing(s).ci           = CalcCI(vecDist.dist.preswing(s).sd, length(trials));
                vecDist.quat.preswing(s,1)            = meanrot(mquat.preswing);
                vecDist.mpos.preswing(s,:)            = [1 0 0] * quat2rotm(vecDist.quat.preswing(s,1));
                vecDist.dist.preswing(s).colheaders   = {'HCFvecChangeDist_Preswing'};
                vecDist.dist.swing(s).subject         = shtName;
                vecDist.dist.swing(s).mean            = mean(dvec.swing,2);
                vecDist.dist.swing(s).sd              = std(dvec.swing,0,2);
                vecDist.dist.swing(s).ci              = CalcCI(vecDist.dist.swing(s).sd, length(trials));
                vecDist.quat.swing(s,1)               = meanrot(mquat.swing);
                vecDist.mpos.swing(s,:)               = [1 0 0] * quat2rotm(vecDist.quat.swing(s,1));
                vecDist.dist.swing(s).colheaders      = {'HCFvecChangeDist_Swing'};
                % Cumulative distance
                vecDist.cdist.gaitcyc(s).subject      = shtName;
                vecDist.cdist.gaitcyc(s).mean         = mean(cumdist.gaitcyc,2);
                vecDist.cdist.gaitcyc(s).sd           = std(cumdist.gaitcyc,0,2);
                vecDist.cdist.gaitcyc(s).ci           = CalcCI(vecDist.cdist.gaitcyc(s).sd, length(trials));
                vecDist.cdist.gaitcyc(s).colheaders   = {'HCFvecCumDisp_GAITCYCLE'};
                vecDist.cdist.stance(s).subject       = shtName;
                vecDist.cdist.stance(s).mean          = mean(cumdist.stance,2);
                vecDist.cdist.stance(s).sd            = std(cumdist.stance,0,2);
                vecDist.cdist.stance(s).ci            = CalcCI(vecDist.cdist.stance(s).sd, length(trials));
                vecDist.cdist.stance(s).colheaders    = {'HCFvecCumDisp_Stance'};            
                vecDist.cdist.loading(s).subject      = shtName;              
                vecDist.cdist.loading(s).mean         = mean(cumdist.loading,2);
                vecDist.cdist.loading(s).sd           = std(cumdist.loading,0,2);
                vecDist.cdist.loading(s).ci           = CalcCI(vecDist.cdist.loading(s).sd, length(trials));
                vecDist.cdist.loading(s).colheaders   = {'HCFvecCumDisp_Loading'};
                vecDist.cdist.midstance(s).subject    = shtName;          
                vecDist.cdist.midstance(s).mean       = mean(cumdist.midstance,2);
                vecDist.cdist.midstance(s).sd         = std(cumdist.midstance,0,2);
                vecDist.cdist.midstance(s).ci         = CalcCI(vecDist.cdist.midstance(s).sd, length(trials));  
                vecDist.cdist.midstance(s).colheaders = {'HCFvecCumDisp_Midstance'};
                vecDist.cdist.latestance(s).subject   = shtName;                      
                vecDist.cdist.latestance(s).mean      = mean(cumdist.latestance,2);
                vecDist.cdist.latestance(s).sd        = std(cumdist.latestance,0,2);
                vecDist.cdist.latestance(s).ci        = CalcCI(vecDist.cdist.latestance(s).sd, length(trials)); 
                vecDist.cdist.latestance(s).colheaders= {'HCFvecCumDisp_Latestance'};
                vecDist.cdist.preswing(s).subject     = shtName;                       
                vecDist.cdist.preswing(s).mean        = mean(cumdist.preswing,2);
                vecDist.cdist.preswing(s).sd          = std(cumdist.preswing,0,2);
                vecDist.cdist.preswing(s).ci          = CalcCI(vecDist.cdist.preswing(s).sd, length(trials));  
                vecDist.cdist.preswing(s).colheaders  = {'HCFvecCumDisp_Preswing'};
                vecDist.cdist.swing(s).subject        = shtName;                      
                vecDist.cdist.swing(s).mean           = mean(cumdist.swing,2);
                vecDist.cdist.swing(s).sd             = std(cumdist.swing,0,2);
                vecDist.cdist.swing(s).ci             = CalcCI(vecDist.cdist.swing(s).sd, length(trials));   
                vecDist.cdist.swing(s).colheaders     = {'HCFvecCumDisp_Swing'};
                % Distance from CoP position
                vecDist.dmvec.gaitcyc(s).subject       = shtName;
                vecDist.dmvec.gaitcyc(s).mean          = mean(dmvec.gaitcyc,2);
                vecDist.dmvec.gaitcyc(s).sd            = std(dmvec.gaitcyc,0,2);
                vecDist.dmvec.gaitcyc(s).ci            = CalcCI(vecDist.dmvec.gaitcyc(s).sd, length(trials));
                vecDist.dmvec.gaitcyc(s).colheaders    = {'HCFdistAvVec_GAITCYCLE'};
                vecDist.dmvec.stance(s).subject        = shtName;
                vecDist.dmvec.stance(s).mean           = mean(mean(dmvec.stance,2),1);
                vecDist.dmvec.stance(s).sd             = std(mean(dmvec.stance,2),0,1);
                vecDist.dmvec.stance(s).ci             = CalcCI(vecDist.dmvec.stance(s).sd, length(trials));
                vecDist.dmvec.stance(s).colheaders     = {'HCFdistAvVec_Stance'};               
                vecDist.dmvec.loading(s).subject       = shtName;
                vecDist.dmvec.loading(s).mean          = mean(mean(dmvec.loading,2),1);
                vecDist.dmvec.loading(s).sd            = std(mean(dmvec.loading,2),0,1);
                vecDist.dmvec.loading(s).ci            = CalcCI(vecDist.dmvec.loading(s).sd, length(trials));
                vecDist.dmvec.loading(s).colheaders    = {'HCFdistAvVec_Loading'};            
                vecDist.dmvec.midstance(s).subject     = shtName;
                vecDist.dmvec.midstance(s).mean        = mean(mean(dmvec.midstnce,2),1);
                vecDist.dmvec.midstance(s).sd          = std(mean(dmvec.midstnce,2),0,1);
                vecDist.dmvec.midstance(s).ci          = CalcCI(vecDist.dmvec.midstance(s).sd, length(trials));
                vecDist.dmvec.midstance(s).colheaders  = {'HCFdistAvVec_Midstance'};                             
                vecDist.dmvec.latestance(s).subject    = shtName;
                vecDist.dmvec.latestance(s).mean       = mean(mean(dmvec.l8stnce,2),1);
                vecDist.dmvec.latestance(s).sd         = std(mean(dmvec.l8stnce,2),0,1);
                vecDist.dmvec.latestance(s).ci         = CalcCI(vecDist.dmvec.latestance(s).sd, length(trials));
                vecDist.dmvec.latestance(s).colheaders = {'HCFdistAvVec_Latestance'};                             
                vecDist.dmvec.preswing(s).subject      = shtName;
                vecDist.dmvec.preswing(s).mean         = mean(mean(dmvec.preswing,2),1);
                vecDist.dmvec.preswing(s).sd           = std(mean(dmvec.preswing,2),0,1);
                vecDist.dmvec.preswing(s).ci           = CalcCI(vecDist.dmvec.preswing(s).sd, length(trials));
                vecDist.dmvec.preswing(s).colheaders   = {'HCFdistAvVec_Preswing'};                             
                vecDist.dmvec.swing(s).subject         = shtName;
                vecDist.dmvec.swing(s).mean            = mean(mean(dmvec.swing,2),1);
                vecDist.dmvec.swing(s).sd              = std(mean(dmvec.swing,2),0,1);
                vecDist.dmvec.swing(s).ci              = CalcCI(vecDist.dmvec.swing(s).sd, length(trials));
                vecDist.dmvec.swing(s).colheaders      = {'HCFdistAvVec_Swing'};
                % Area
                vecDist.area.gaitcyc(s).subject      = shtName;
                vecDist.area.gaitcyc(s).mean         = mean(vecAr.gaitcyc,2);
                vecDist.area.gaitcyc(s).sd           = std(vecAr.gaitcyc,0,2);
                vecDist.area.gaitcyc(s).ci           = CalcCI(vecDist.area.gaitcyc(s).sd, length(trials));
                vecDist.area.gaitcyc(s).colheaders   = {'HCFvecArea_GAITCYCLE'};
                vecDist.area.stance(s).subject       = shtName;
                vecDist.area.stance(s).mean          = mean(vecAr.stance,2);
                vecDist.area.stance(s).sd            = std(vecAr.stance,0,2);
                vecDist.area.stance(s).ci            = CalcCI(vecDist.area.stance(s).sd, length(trials));
                vecDist.area.stance(s).colheaders    = {'HCFvecArea_Stance'};            
                vecDist.area.loading(s).subject      = shtName;              
                vecDist.area.loading(s).mean         = mean(vecAr.loading,2);
                vecDist.area.loading(s).sd           = std(vecAr.loading,0,2);
                vecDist.area.loading(s).ci           = CalcCI(vecDist.area.loading(s).sd, length(trials));
                vecDist.area.loading(s).colheaders   = {'HCFvecArea_Loading'};
                vecDist.area.midstance(s).subject    = shtName;          
                vecDist.area.midstance(s).mean       = mean(vecAr.midstnce,2);
                vecDist.area.midstance(s).sd         = std(vecAr.midstnce,0,2);
                vecDist.area.midstance(s).ci         = CalcCI(vecDist.area.midstance(s).sd, length(trials));  
                vecDist.area.midstance(s).colheaders = {'HCFvecArea_Midstance'};
                vecDist.area.latestance(s).subject   = shtName;                      
                vecDist.area.latestance(s).mean      = mean(vecAr.l8stnce,2);
                vecDist.area.latestance(s).sd        = std(vecAr.l8stnce,0,2);
                vecDist.area.latestance(s).ci        = CalcCI(vecDist.area.latestance(s).sd, length(trials)); 
                vecDist.area.latestance(s).colheaders= {'HCFvecArea_Latestance'};
                vecDist.area.preswing(s).subject     = shtName;                       
                vecDist.area.preswing(s).mean        = mean(vecAr.preswing,2);
                vecDist.area.preswing(s).sd          = std(vecAr.preswing,0,2);
                vecDist.area.preswing(s).ci          = CalcCI(vecDist.area.preswing(s).sd, length(trials));  
                vecDist.area.preswing(s).colheaders  = {'HCFvecArea_Preswing'};
                vecDist.area.swing(s).subject        = shtName;                      
                vecDist.area.swing(s).mean           = mean(vecAr.swing,2);
                vecDist.area.swing(s).sd             = std(vecAr.swing,0,2);
                vecDist.area.swing(s).ci             = CalcCI(vecDist.area.swing(s).sd, length(trials));   
                vecDist.area.swing(s).colheaders     = {'HCFvecArea_Swing'};                
                % Metadata
                % dpt = distance between data (time) points
                dpt.gaitcyc(:,s)                       = mean(vecDist.dist.gaitcyc(s).mean,2);
                dpt.stance(:,s)                        = mean(vecDist.dist.stance(s).mean,2);
                dpt.loading(:,s)                       = mean(vecDist.dist.loading(s).mean,2);    
                dpt.midstance(:,s)                     = mean(vecDist.dist.midstance(s).mean,2);
                dpt.latestance(:,s)                    = mean(vecDist.dist.latestance(s).mean,2);
                dpt.preswing(:,s)                      = mean(vecDist.dist.preswing(s).mean,2);
                dpt.swing(:,s)                         = mean(vecDist.dist.swing(s).mean,2);
                % drv = distance to average centre of pressure
                dmv.gaitcyc(:,s)                      = mean(dmvec.gaitcyc,2);
                dmv.stance(:,s)                       = mean(dmvec.stance,2);             
                dmv.loading(:,s)                      = mean(dmvec.loading,2);            
                dmv.midstance(:,s)                    = mean(dmvec.midstnce,2);            
                dmv.latestance(:,s)                   = mean(dmvec.l8stnce,2);
                dmv.preswing(:,s)                     = mean(dmvec.preswing,2);            
                dmv.swing(:,s)                        = mean(dmvec.swing,2);
                % dp = distance to average centre of pressure            
                vecDist.metadata(s).to                = mean(to);
                vecDist.metadata(s).mquat             = vecDist.quat.gaitcyc(s);
                m_quat(:,s)                           = meanrot(gcquat,2);
                vecDist.metadata(s).quat              = m_quat(:,s);               
                vecDist.metadata(s).mpos              = vecDist.mpos.gaitcyc(s,:);
                vecDist.metadata(s).cdist_gc          = max(vecDist.cdist.gaitcyc(s).mean);
                vecDist.metadata(s).cdist_swg         = max(vecDist.cdist.swing(s).mean);
                vecDist.metadata(s).dcop_gc           = mean(vecDist.dmvec.gaitcyc(s).mean,1);
                vecDist.metadata(s).dcop_stn          = mean(vecDist.dmvec.stance(s).mean,1);
                vecDist.metadata(s).dcop_swg          = mean(vecDist.dmvec.swing(s).mean,1);
                vecDist.metadata(s).crd_gc            = cumsum(vecDist.dmvec.gaitcyc(s).mean,1);
                vecDist.metadata(s).AEgc              = mean(sum(vecAr.gaitcyc));
                vecDist.metadata(s).AEst              = mean(sum(vecAr.stance));
                vecDist.metadata(s).AEld              = mean(sum(vecAr.loading));
                vecDist.metadata(s).AEms              = mean(sum(vecAr.midstnce));
                vecDist.metadata(s).AEls              = mean(sum(vecAr.l8stnce));
                vecDist.metadata(s).AEps              = mean(sum(vecAr.preswing));
                vecDist.metadata(s).AEsw             = mean(sum(vecAr.swing));
                vecDist.metadata(s).ABdgc             = mean(a.gaitcyc);
                vecDist.metadata(s).ABdst             = mean(a.stance);
                vecDist.metadata(s).ABdld             = mean(a.loading);
                vecDist.metadata(s).ABdms             = mean(a.midstnce);
                vecDist.metadata(s).ABdls             = mean(a.l8stnce);
                vecDist.metadata(s).ABdps             = mean(a.preswing);
                vecDist.metadata(s).ABdsw             = mean(a.swing);
                clear trials avvec dvec dmvec cumdist vecAr eul phases to gcquat a
            end
        %% ASSEMBLE COHORT AVERAGE
        % metadata
        vecLoc(rf) = getCohortAverages (vecDist, dpt, dmv, m_quat, SF, height, sRad, length(subjectNames));  
        plotAvVec(vecLoc(rf), paths, cohortID{i}, dirPlot, refframe{rf}, vecLoc(rf).metadata(end).SF)
        plot_d_AvVec(vecLoc(rf), cohortID{i}, dirPlot, refframe{rf})
        plot_area(vecLoc(rf), cohortID{i}, dirPlot, refframe{rf})
%         save([dirAnalyses filesep idCNMS filesep idPub filesep 'HCFvecdisp.mat'],'d');
        clear vecDist m_quat dpt dmv
        end
        save([dirAnalyses filesep idCNMS filesep idPub filesep executionModes{1} filesep 'elabVecDist_so.mat'],'vecLoc');
    case 'cohort'
        %% ------------------------------
        % PROCESS COHORT LEVEL DATA
        %--------------------------------
            JCF            = load([dirAnalyses filesep idCNMS filesep idPub filesep 'elabCNMS_summary.mat']);
            SF              = getScaleFactors(dirElab, {JCF.elabCNMS_summary.Assisted.ContactForces.subject}.', idModel);
        for ex = 1:length(executionModes)
            force           = JCF.elabCNMS_summary.([executionModes{ex}]).ContactForces(end).mean(:, 13:15).*-1;
            phases          = definephases;
            getForceLocation_stl(force, paths, mean(SF), phases)
        end
    end
end