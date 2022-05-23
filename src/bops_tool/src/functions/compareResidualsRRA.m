% compareResidualsRRA
%
% PlotID = Logic (1 = run ID; 2 = run ID)

function compareResidualsRRA(RRAtrialsOutputDir,modelNames,IKoutputDir,IDoutputDir,Logic)

fp = filesep;
%% check trials that RRA was not faiiled and create an average mass model 

RRA_LogAll ={};
BadTrials ={};
for k = 1: length(RRAtrialsOutputDir)
% Directory of the Log File from RRA
    RRA_Log = [RRAtrialsOutputDir{k} fp 'Log' fp 'out.log'];
    RRAlog = importdata(RRA_Log,' ', 100000);
    [m,ln] = findLine(RRAlog,'Total mass change',0);
    if isempty(m)
        [~,BadTrials{end+1}] = fileparts(RRAtrialsOutputDir{k});
        continue
    end
    RRA_LogAll{end+1} = RRA_Log;
end

ScaledModel =  modelNames.model_full_path{1}; % after running Bops

Models = dir([fileparts(modelNames.model_full_path{1}) fp '*.osim']);
n = num2str(sum(contains({Models.name},'RRA_AvgMass')));
ModelAvgMass = [fileparts(modelNames.model_full_path{1}) fp '034_Rajagopal2015_RRA_AvgMass' n '.osim'];

adjustmodelmass_BG(1,RRA_LogAll, ScaledModel, ModelAvgMass)

BadTrials;

%% 
% k = 1;  % change k to plot other trial
for k = 1: length(RRAtrialsOutputDir)
    
    cd(RRAtrialsOutputDir{k})
    [~,trialName] = fileparts(RRAtrialsOutputDir{k});
    
    disp('-------------------------------------')
    disp(['plottting data for trial ' trialName])
    disp('-------------------------------------')
    
    % models
    rraModels = dir([RRAtrialsOutputDir{k} fp 'Setup' fp '*.osim']);
    ModelTorsoCOM = rraModels(contains({rraModels.name},'_rraAdjusted.osim'));
    ModelTorsoCOM = [ModelTorsoCOM.folder fp ModelTorsoCOM.name];
    ModelAdjMass = [RRAtrialsOutputDir{k} fp 'Setup\034_Rajagopal2015_FAI_AdjMass.osim'];
    
%     files(contains({files.name},'Kinematics_q.sto'))
    % Directory of the Log File from RRA
    RRA_Log = [RRAtrialsOutputDir{k} fp 'Log' fp 'out.log'];
    RRAlog = importdata(RRA_Log,' ', 100000);
    [m,ln] = findLine(RRAlog,'Total mass change',0);
    if isempty(m)
        continue
    end
    % directory
    IDSetupXML = [IDoutputDir fp  trialName fp 'Setup\setup_ID.xml'];
    
    %Kinematics directories
     trialsList = trialsListGeneration(IKoutputDir);
     inputTrials = trialsList(k);

    [IKFileDir] = inputFilesListGeneration(IKoutputDir, inputTrials, '.mot');
    IKFileDir = IKFileDir{1};
    RRAFileDir = [RRAtrialsOutputDir{k} fp trialName '_Kinematics_q.sto'];
    DirC3D = strrep(fileparts(fileparts(IKoutputDir)),'ElaboratedData','InputData');
    OrganiseFAI
    
    % moments to be exported
    s = lower(TestedLeg{1});
    moments = {'time','pelvis_tilt','pelvis_list','pelvis_rotation',...
        'pelvis_tx','pelvis_ty','pelvis_tz',['hip_flexion_' s], ['knee_angle_' s] ,['ankle_angle_' s]};
    
    % outcome variables
    Residuals = struct;
    Mass = struct;
    COM = struct;
    Mom = struct;
    MassAdj = struct;
    IK = struct;
    
    % 1 = run ID , 0 = don't run ID
    if ~exist('Logic')
        Logic = 1;
    end
    %% Scaled Model and original Kinematics(ID)
    
    model_file = ScaledModel;
    KinematicsDir = IKFileDir;
    sufix = '';
    
    [Residuals.ID,Mass.ID,COM.ID,Mom.ID,Labels,IK.IK,MassAdj.ID] = ...
        NewIDwithResiduals (IDSetupXML,model_file,KinematicsDir,moments,sufix,Logic);
    
    disp(' ')
    disp(' ')
    fprintf('Model = %s \n',ScaledModel)
    fprintf('Kinematics = %s \n',IKFileDir)
    
    Residuals
    %% Scaled Model model and RRA kinematics (Scaled_RRA)
%     model_file = ScaledModel;
%     KinematicsDir = RRAFileDir;
%     sufix = 'Scaled_RRA';
%     
%     [Residuals.(sufix),Mass.(sufix),COM.(sufix), Mom.(sufix),Labels,MassAdj.(sufix)] = ...
%         NewIDwithResiduals (IDSetupXML,model_file,KinematicsDir,moments,sufix,Logic);
%     
%     disp(' ')
%     disp(' ')
%     fprintf('Model = %s \n',ScaledModel)
%     fprintf('Kinematics = %s \n',IKFileDir)
%     
%     Residuals
    %% COM Torso adjusted model and original kinematics (COMtorso_Original)
    % * Average residuals after adjusting torso COM
    
%     model_file = ModelTorsoCOM;
%     KinematicsDir = IKFileDir;
%     sufix = 'COMtorso_Original';
%     
%     [Residuals.(sufix),Mass.(sufix),COM.(sufix), Mom.(sufix),Labels,MassAdj.(sufix)] = ...
%         NewIDwithResiduals (IDSetupXML,model_file,KinematicsDir,moments,sufix,Logic);
%     
%     Residuals
    %% COM Torso adjusted model and RRA kinematics  (COMtorso_RRA)
    
%     model_file = ModelTorsoCOM;
%     KinematicsDir = RRAFileDir;
%     sufix = 'COMtorso_RRA';
%     
%     [Residuals.(sufix),Mass.(sufix),COM.(sufix), Mom.(sufix),Labels,MassAdj.(sufix)] = ...
%         NewIDwithResiduals (IDSetupXML,model_file,KinematicsDir,moments,sufix,Logic);
%     
%     Residuals
    %% Adjust Mass Model and original kinematics (MassAll_Original)
%     Model_In = ScaledModel;
%     Model_Out = ModelAdjMass;
%     adjustmodelmass(1, Model_In, Model_Out,RRA_Log);
%     
%     model_file = ModelAdjMass;
%     KinematicsDir = IKFileDir;
%     sufix = 'MassAll_Original';
%     
%     [Residuals.(sufix),Mass.(sufix),COM.(sufix), Mom.(sufix),Labels,MassAdj.(sufix)] = ...
%         NewIDwithResiduals (IDSetupXML,model_file,KinematicsDir,moments,sufix,Logic);
%     
%     Residuals
    %% Adjust Mass Model and RRA kinematics (MassAll_RRA)
    
%     Model_In = ScaledModel;
%     Model_Out = ModelAdjMass;
%     adjustmodelmass(1, Model_In, Model_Out,RRA_Log);
%     
%     model_file = ModelAdjMass;
%     KinematicsDir = RRAFileDir;
%     sufix = 'MassAll_RRA';
%     
%     [Residuals.(sufix),Mass.(sufix),COM.(sufix), Mom.(sufix),Labels,MassAdj.(sufix)] = ...
%         NewIDwithResiduals (IDSetupXML,model_file,KinematicsDir,moments,sufix,Logic);
%     
%     Residuals
%     
    %% Average Mass Model and original kinematcs  
    model_file = ModelAvgMass;
    KinematicsDir = IKFileDir;
    sufix = 'AvgMass_Original';
    
    [Residuals.(sufix),Mass.(sufix),COM.(sufix), Mom.(sufix),Labels,IK.(sufix),MassAdj.(sufix)] = ...
        NewIDwithResiduals (IDSetupXML,model_file,KinematicsDir,moments,sufix,Logic);
    
    disp(' ')
    disp(' ')
    fprintf('Model = %s \n',ScaledModel)
    fprintf('Kinematics = %s \n',IKFileDir)
    
    Residuals

    %% Average Mass Model and RRA kinematcs  
    model_file = ModelAvgMass;
    KinematicsDir = RRAFileDir;
    sufix = 'AvgMass_RRA';
    
    [Residuals.(sufix),Mass.(sufix),COM.(sufix), Mom.(sufix),Labels,IK.(sufix),MassAdj.(sufix)] = ...
        NewIDwithResiduals (IDSetupXML,model_file,KinematicsDir,moments,sufix,Logic);
    
    disp(' ')
    disp(' ')
    fprintf('Model = %s \n',ScaledModel)
    fprintf('Kinematics = %s \n',IKFileDir)
    
    Residuals

    %% Plot pelvis moments (residuals)
    
    figure
    hold on
    fld = fields(Mom);
    cols = [2:4];
    
    for  ii = 1: length(fld)
        S = struct;
        fs = 1/ (Mom.(fld{ii})(2,1)-Mom.(fld{ii})(1,1));
        NormData = TimeNorm(Mom.(fld{ii})(:,cols),fs);
        S.(fld{ii}) = NormData;
        Ylab = {'Moment (N.m)'};
        Xlab = {'Gait cycle (%)'};
        TT = moments(cols);
        LW = 2;
        plotLine_BG(S,Ylab,Xlab,TT,LW)
        OrgResidulars.(fld{ii}) = rms(Mom.(fld{ii})(:,cols));
        NormResidulars.(fld{ii}) = rms(NormData);
    end
    
    % R squared
    S = struct;
    for  ii = 1: length(fld)
        NormData = TimeNorm(Mom.(fld{ii})(:,cols),fs);
        S.(fld{ii}) = NormData;
    end
    
    [RMSE,rsquared,RMSELabels,RMS] = getRMSE(S);
    
    % text with R squared
    rnames = strrep(fld,'_',' ');
    for  ii = 1: length(fld)
        if ii ~= 1 % skip the original ID
            Posx = [50 50 50];
            f = gcf;
            
            % check the order of the figure children (it flips every
            % iteration)
            if f.Children(1).Position(1) > f.Children(end).Position(1)
               f.Children = flip(f.Children);
            end
            
            
            for rr = 1: size(rsquared,2)
                axes(f.Children(rr))
                t = sprintf('R^2 %s = %.2f',rnames{ii},rsquared(ii-1,rr));
                t = text(0.5,0.5,[t]);
                Posy = max(ylim)-range(ylim)*(ii*0.025)+0.02*range(ylim);
                set(t, 'Position',[Posx(rr)  Posy  0.0000], 'FontSize', 11)
            end
        end
    end
    
    legend(rnames,'Interpreter','none','Box','off','FontSize', 12)
    f.Children(1).Position = [0.8374    0.4985    0.1198    0.1215];
    % legend(fld,'Interpreter','none','Box','off','FontSize', 12)
    
    %% Plot pelvis forces (residuals)
    
    figure
    hold on
    fld = fields(Mom);
    cols = [5:7];
    
    for  ii = 1: length(fld)
        S = struct;
        fs = 1/ (Mom.(fld{ii})(2,1)-Mom.(fld{ii})(1,1));
        NormData = TimeNorm(Mom.(fld{ii})(:,cols),fs);
        S.(fld{ii}) = NormData;
        Ylab = {'Force (N)'};
        Xlab = {'Gait cycle (%)'};
        TT = moments(cols);
        LW = 2;
        plotLine_BG(S,Ylab,Xlab,TT,LW)
        OrgResidulars.(fld{ii}) = rms(Mom.(fld{ii})(:,cols));
        NormResidulars.(fld{ii}) = rms(NormData);
    end
    
    % R squared
    S = struct;
    for  ii = 1: length(fld)
        NormData = TimeNorm(Mom.(fld{ii})(:,cols),fs);
        S.(fld{ii}) = NormData;
    end
    
    [RMSE,rsquared,RMSELabels,RMS] = getRMSE(S);
    
    % text with R squared
    rnames = strrep(fld,'_',' ');
    for  ii = 1: length(fld)
        if ii ~= 1 % skip the original ID
            Posx = [50 50 50];
            f = gcf;
            
            % check the order of the figure children (it flips every
            % iteration)
            if f.Children(1).Position(1) > f.Children(end).Position(1)
               f.Children = flip(f.Children);
            end
            
            
            for rr = 1: size(rsquared,2)
                axes(f.Children(rr))
                t = sprintf('R^2 %s = %.2f',rnames{ii},rsquared(ii-1,rr));
                t = text(0.5,0.5,[t]);
                Posy = max(ylim)-range(ylim)*(ii*0.025)+0.02*range(ylim);
                set(t, 'Position',[Posx(rr)  Posy  0.0000], 'FontSize', 11)
            end
        end
    end
    
    legend(rnames,'Interpreter','none','Box','off','FontSize', 12)
    f.Children(1).Position = [0.8374    0.4985    0.1198    0.1215];
    % legend(fld,'Interpreter','none','Box','off','FontSize', 12)  
    
    %% Plot pelvis angle
    
    figure
    hold on
    fld = fields(IK);
    cols = [2:4];
    
    for  ii = 1: length(fld)
        S = struct;
        fs = 1/ (IK.(fld{ii})(2,1)-IK.(fld{ii})(1,1));
        NormData = TimeNorm(IK.(fld{ii})(:,cols),fs);
        S.(fld{ii}) = NormData;
        Ylab = {'Angle (deg)'};
        Xlab = {'Gait cycle (%)'};
        TT = moments(cols);
        LW = 2;
        plotLine_BG(S,Ylab,Xlab,TT,LW)
        OrgResidulars.(fld{ii}) = rms(IK.(fld{ii})(:,cols));
        NormResidulars.(fld{ii}) = rms(NormData);
    end
    
    % R squared
    S = struct;
    for  ii = 1: length(fld)
        NormData = TimeNorm(IK.(fld{ii})(:,cols),fs);
        S.(fld{ii}) = NormData;
    end
    
    [RMSE,rsquared,RMSELabels,RMS] = getRMSE(S);
    
    % text with R squared
    rnames = strrep(fld,'_',' ');
    for  ii = 1: length(fld)
        if ii ~= 1 % skip the original ID
            Posx = [50 50 50];
            f = gcf;
            
            % check the order of the figure children (it flips every
            % iteration)
            if f.Children(1).Position(1) > f.Children(end).Position(1)
               f.Children = flip(f.Children);
            end
            
            
            for rr = 1: size(rsquared,2)
                axes(f.Children(rr))
                t = sprintf('R^2 %s = %.2f',rnames{ii},rsquared(ii-1,rr));
                t = text(0.5,0.5,[t]);
                Posy = max(ylim)-range(ylim)*(ii*0.025)+0.02*range(ylim);
                set(t, 'Position',[Posx(rr)  Posy  0.0000], 'FontSize', 11)
            end
        end
    end
    
    legend(rnames,'Interpreter','none','Box','off','FontSize', 12)
    f.Children(1).Position = [0.8374    0.4985    0.1198    0.1215];
    % legend(fld,'Interpreter','none','Box','off','FontSize', 12)
    
    %% Plot pelvis linear kinematics cols 
    
    figure
    hold on
    fld = fields(IK);
    cols = [5:7];
    
    for  ii = 1: length(fld)
        S = struct;
        fs = 1/ (IK.(fld{ii})(2,1)-IK.(fld{ii})(1,1));
        NormData = TimeNorm(IK.(fld{ii})(:,cols),fs);
        S.(fld{ii}) = NormData;
        Ylab = {'Displacement (m)'};
        Xlab = {'Gait cycle (%)'};
        TT = moments(cols);
        LW = 2;
        plotLine_BG(S,Ylab,Xlab,TT,LW)
        OrgResidulars.(fld{ii}) = rms(IK.(fld{ii})(:,cols));
        NormResidulars.(fld{ii}) = rms(NormData);
    end
    
    % R squared
    S = struct;
    for  ii = 1: length(fld)
        NormData = TimeNorm(IK.(fld{ii})(:,cols),fs);
        S.(fld{ii}) = NormData;
    end
    
    [RMSE,rsquared,RMSELabels,RMS] = getRMSE(S);
    
    % text with R squared
    rnames = strrep(fld,'_',' ');
    for  ii = 1: length(fld)
        if ii ~= 1 % skip the original ID
            Posx = [50 50 50];
            f = gcf;
            
            % check the order of the figure children (it flips every
            % iteration)
            if f.Children(1).Position(1) > f.Children(end).Position(1)
               f.Children = flip(f.Children);
            end
            
            
            for rr = 1: size(rsquared,2)
                axes(f.Children(rr))
                t = sprintf('R^2 %s = %.2f',rnames{ii},rsquared(ii-1,rr));
                t = text(0.5,0.5,[t]);
                Posy = max(ylim)-range(ylim)*(ii*0.025)+0.02*range(ylim);
                set(t, 'Position',[Posx(rr)  Posy  0.0000], 'FontSize', 11)
            end
        end
    end
    
    legend(rnames,'Interpreter','none','Box','off','FontSize', 12)
    f.Children(1).Position = [0.8374    0.4985    0.1198    0.1215];
    % legend(fld,'Interpreter','none','Box','off','FontSize', 12)
        
    %% Plot hip knee and ankle forces cols 8,9 and 10
    
    figure
    hold on
    fld = fields(Mom);
    cols = [8:10];
    for  ii = 1: length(fld)
        S = struct; % needs yo be inside the loop to plot all the fields in the same row
        fs = 1/ (Mom.(fld{ii})(2,1)-Mom.(fld{ii})(1,1));
        NormData = TimeNorm(Mom.(fld{ii})(:,cols),fs);
        S.(fld{ii}) = NormData;
        Ylab = {'Moment (N.m)'};
        Xlab = {'Gait cycle (%)'};
        TT = moments(cols);
        LW = 2;
        plotLine_BG(S,Ylab,Xlab,TT,LW)
        OrgResidulars.(fld{ii}) = rms(Mom.(fld{ii})(:,cols));
        NormResidulars.(fld{ii}) = rms(NormData);
    end
    
    
    % R squared
    S = struct;
    for  ii = 1: length(fld)
        NormData = TimeNorm(Mom.(fld{ii})(:,cols),fs);
        S.(fld{ii}) = NormData;
    end
    
    [RMSE,rsquared,RMSELabels,RMS] = getRMSE(S);
    
    % text with R squared
    rnames = strrep(RMSELabels,'_',' ');
    for  ii = 1: length(fld)
        if ii ~= 1 % skip the original ID
            Posx = [40 40 40];
            f = gcf;
            % check which plot is the number 1 in children
            if f.Children(1).Position(1) > f.Children(end).Position(1)
               f.Children = flip(f.Children);
            end
            for rr = 1: size(rsquared,2)
                axes(f.Children(rr))
                t = sprintf('R^2 %s = %.3f',rnames{ii-1},rsquared(ii-1,rr));
                t = text(0.5,0.5,[t]);
                Posy = max(ylim)-range(ylim)*(ii*0.025)+0.02*range(ylim);
                set(t, 'Position',[Posx(rr)  Posy  0.0000], 'FontSize', 11)
            end
        end
    end
    
    legend(rnames,'Interpreter','none','Box','off','FontSize', 12)
    f.Children(1).Position = [0.8374    0.4985    0.1198    0.1215];
    
    %% Plot hip knee and ankle pelvis kinematics
    
    figure
    hold on
    fld = fields(IK);
    cols = [8:10];
    
    for  ii = 1: length(fld)
        S = struct;
        fs = 1/ (IK.(fld{ii})(2,1)-IK.(fld{ii})(1,1));
        NormData = TimeNorm(IK.(fld{ii})(:,cols),fs);
        S.(fld{ii}) = NormData;
        Ylab = {'Angle (deg)'};
        Xlab = {'Gait cycle (%)'};
        TT = moments(cols);
        LW = 2;
        plotLine_BG(S,Ylab,Xlab,TT,LW)
        OrgResidulars.(fld{ii}) = rms(IK.(fld{ii})(:,cols));
        NormResidulars.(fld{ii}) = rms(NormData);
    end
    
    % R squared
    S = struct;
    for  ii = 1: length(fld)
        NormData = TimeNorm(IK.(fld{ii})(:,cols),fs);
        S.(fld{ii}) = NormData;
    end
    
    [RMSE,rsquared,RMSELabels,RMS] = getRMSE(S);
    
    % text with R squared
    rnames = strrep(fld,'_',' ');
    for  ii = 1: length(fld)
        if ii ~= 1 % skip the original ID
            Posx = [50 50 50];
            f = gcf;
            
            % check the order of the figure children (it flips every
            % iteration)
            if f.Children(1).Position(1) > f.Children(end).Position(1)
               f.Children = flip(f.Children);
            end
            
            
            for rr = 1: size(rsquared,2)
                axes(f.Children(rr))
                t = sprintf('R^2 %s = %.2f',rnames{ii},rsquared(ii-1,rr));
                t = text(0.5,0.5,[t]);
                Posy = max(ylim)-range(ylim)*(ii*0.025)+0.02*range(ylim);
                set(t, 'Position',[Posx(rr)  Posy  0.0000], 'FontSize', 11)
            end
        end
    end
    
    legend(rnames,'Interpreter','none','Box','off','FontSize', 12)
    f.Children(1).Position = [0.8374    0.4985    0.1198    0.1215];
    % legend(fld,'Interpreter','none','Box','off','FontSize', 12)
        
    %% bar plot residuals
    figure
    hold on
    fld = fields(Residuals);
    group=[];
    for  ii = 1: length(fld)
        group(:,ii) = Residuals.(fld{ii});
    end
    bar(group);
    b = gca;
    xticks(1:6)
    xlabels = strrep(moments(2:7),'_',' ');
    xticklabels(xlabels)
    xtickangle(45)
    legend(fld,'Interpreter','none','Box','off','FontSize', 12)
    b.YLabel.String = 'N.m / N';
    title('RMS residuals')
    mmfn
    
    %% bar plot mass suggested changes
    figure
    hold on
    fld = fields(Mass);
    group=[];
    for  ii = 1: length(fld)
        group(:,ii) = Mass.(fld{ii});
    end
    bar(group);
    b = gca;
    xticks(1:6)
    xlabels = strrep(fld,'_',' ');
    xticklabels(xlabels)
    xtickangle(45)
    b.YLabel.String = 'Kg';
    title('Mass trunk')
    text(max(xlim)*0.8,max(ylim)*0.99, ['total mass adjusments = ' num2str(MassAdj.ID) 'kg'],'FontSize',14)
    mmfn
    
    %% Save figures
    figDir = [RRAtrialsOutputDir{k} fp 'Figures'];
    mkdir(figDir)
    cd(figDir)
    names = flip({'Residuals pelvis moments' 'Residual pelvis forces' 'Pelvis angle'...
        'Pelvis translations' 'Moments HKA' 'Angle HKA' 'RMSresiduals pelvis' 'Trunk mass'});

    h =  findobj('type','figure');
    
    for n = 1:length(h)
        f = gcf;
        saveas (f,[names{n} '.tif'])
        close (f)
    end
    
end