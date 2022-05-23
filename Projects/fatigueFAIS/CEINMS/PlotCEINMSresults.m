%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% inspect the force and EMG from the isometric trials from the c3d files

function PlotCEINMSresults(Dir,CEINMSSettings,SubjectInfo,SimulationDir,OptimalSettings)

fp = filesep;
warning off
%% Plotting settings
PlotSet = struct;
PlotSet.figSize = [30 30 1700 700];
PlotSet.FontSize = 12;
PlotSet.FontName = 'Times New Roman';
PlotSet.Xlab = 'GaitCycle (%)';
MatchWord = 1; % 1= match names / 0 = don't match full name

%% Dof and names of the variables to plot
[~,trialName]  = DirUp(SimulationDir,1);

dofList = split(CEINMSSettings.dofList ,' ')';
S = getOSIMVariablesFAI(SubjectInfo.TestedLeg,CEINMSSettings.osimModelFilename,dofList);
OS = getosimfilesFAI(Dir,trialName); % also creates the directories

exctGern = xml_read(CEINMSSettings.excitationGeneratorFilename);
exeCFG = xml_read(CEINMSSettings.exeCfg);
synthMTUs = split(exeCFG.NMSmodel.type.hybrid.synthMTUs,' ');
inputEMG = struct;
for m = 1:length(exctGern.mapping.excitation)
    muscle = exctGern.mapping.excitation(m).ATTRIBUTE.id;
    if sum(contains(synthMTUs,muscle))>0
        continue
    end
    if contains(muscle,S.AllMuscles) && ~isempty(exctGern.mapping.excitation(m).input)
        inputEMG.(muscle) = char;
        for i = 1:length(exctGern.mapping.excitation(m).input)
            inputEMG.(muscle) = [inputEMG.(muscle) ' ' exctGern.mapping.excitation(m).input(i).CONTENT];
        end
    end
end

%% Find best interation from all CEINMS executions
if nargin>4 
    load([SimulationDir fp 'OptimalSettings.mat'])
    
elseif ~exist([SimulationDir fp 'OptimalSettings.mat'])
    OptimalSettings = OptimalGammaCEINMS_BG(Dir,TrialSimulationDir,SubjectInfo); 
    CEINMSexe_BG (Dir,CEINMSSettings,trialName,OptimalSettings.Alpha,OptimalSettings.Beta,OptimalSettings.Gamma);
else
    load([SimulationDir fp 'OptimalSettings.mat'])
end
TimeWindow = TimeWindow_FatFAIS(Dir,trialName);
BestItrDir = OptimalSettings.Dir;
% BestItrDir = results_directory;
saveDir = [Dir.Results_CEINMS fp trialName];
if exist(saveDir)
    n = num2str(sum(contains(cellstr(ls(Dir.Results_CEINMS)),trialName))+1);
    saveDir = [Dir.Results_CEINMS fp trialName '_' n];
end
mkdir(saveDir); mkdir([saveDir fp 'ModelParameters'])
% create a copy of the cfg and log files 
if OptimalSettings.Gamma ~= 0
copyfile([SimulationDir fp 'OptimalSettings.mat'],[saveDir fp 'ModelParameters'])
copyfile([SimulationDir fp sprintf('AlphaA%.f BetaB%.f_OptimalGamma.jpeg',OptimalSettings.Alpha,OptimalSettings.Beta)],[saveDir fp 'ModelParameters'])
end
copyfile([Dir.CEINMScalibration fp 'shapeFactor.jpeg'],[saveDir fp 'ModelParameters'])
copyfile([Dir.CEINMScalibration fp 'activationScale.jpeg'],[saveDir fp 'ModelParameters'])
copyfile([Dir.CEINMScalibration fp 'optimalFibreLength.jpeg'],[saveDir fp 'ModelParameters'])
copyfile([Dir.CEINMScalibration fp 'pennationAngle.jpeg'],[saveDir fp 'ModelParameters'])
copyfile([Dir.CEINMScalibration fp 'tendonSlackLength.jpeg'],[saveDir fp 'ModelParameters'])
copyfile([Dir.CEINMScalibration fp 'maxContractionVelocity.jpeg'],[saveDir fp 'ModelParameters'])
copyfile([Dir.CEINMScalibration fp 'maxIsometricForce.jpeg'],[saveDir fp 'ModelParameters'])
copyfile([Dir.CEINMScalibration fp 'StrengthCoeficients.jpeg'],[saveDir fp 'ModelParameters'])

copyfile(CEINMSSettings.outputSubjectFilename,[saveDir fp 'ModelParameters'])
copyfile(CEINMSSettings.exeCfg,[saveDir fp 'ModelParameters'])
copyfile([Dir.CEINMSsetup fp trialName '.xml'],[saveDir fp 'ModelParameters'])
copyfile([BestItrDir fp 'out.log'],[saveDir fp 'ModelParameters'])

%% assess if the muscles can produces the desired torques
% calculates the max torque for each DOF 
MaxTorqueMuscles(Dir,CEINMSSettings,trialName)
saveas(gcf,[saveDir fp 'MaxPossibleTorquePerDOF.jpeg'])
close all

%% Plot moments and JCF 
[RMSE,R2, EMG_MOM_Data] = CEINMS_errors(OS.emg,OS.IDRRAresults,BestItrDir,CEINMSSettings.excitationGeneratorFilename,CEINMSSettings.exeCfg,S.DOFmuscles);
IK = LoadResults_BG(OS.IKresults,TimeWindow,S.coordinates,1);
N=3; M=length(dofList);
[ha, ~,FirstCol, LastRow] = tight_subplotBG(N,M,[0.05 0.05],[0.1 0.15],0.05,PlotSet.figSize);
for d = 1:length(dofList)
    
    currentDOF = dofList{d};axes(ha(d));hold on
    plot(EMG_MOM_Data.mom.(currentDOF).measured); plot(EMG_MOM_Data.mom.(currentDOF).estimated);
    currentRMSE = nanmean(RMSE.mom.(currentDOF)); currentR2= nanmean(R2.mom.(currentDOF));
    
    yticklabels(yticks)
    title(sprintf('%s (RMSE = %.1f, r^2 = %.2f)\n %s',currentDOF,currentRMSE,currentR2,S.DOFdirections.(currentDOF){1}),'Interpreter','none')
    if any(d == FirstCol); ylabel('Moment (Nm/Kg)');
    lg = legend({'inverse dynamics' 'CEINMS'});
    lg.Position = [0.2314    0.86    0.1365    0.02];
    end

    % joint contact forces
    [JCF,JCF_Labels]=LoadResults_BG ([BestItrDir fp 'ContactForces.sto'],TimeWindow,S.ContactForces.(dofList{d}),0);
    axes(ha(d+M));hold on; JCF = JCF./(SubjectInfo.Weight*9.81);plot(JCF);
    x=JCF(:,1);y=JCF(:,2);z=JCF(:,3);ResultantJCF = sqrt(x.^2+z.^2+y.^2); plot(ResultantJCF); yticklabels(yticks)
    
    if any(d+M == FirstCol)
        ylabel('Contact Force (N/BW)');
        lg = legend({'x[(-) posterior  | anteriro(+)]' 'y[(-) inferior | superior(+)]' 'z[(-) lateral | medial(+)]' 'resultant force'});
        lg.Position = [0.2314    0.6    0.1365    0.0689];
    end   
    axes(ha(d+2*M));hold on;plot(IK(:,d));yticklabels(yticks); xlabel(PlotSet.Xlab)
    if any(d+2*M == FirstCol); ylabel('Angle(deg)');end  
end

MaxVelocity = CalcVelocity_OpenSimPelvis(Dir,trialName,TimeWindow);
suptitle([trialName '=' num2str(MaxVelocity) 'm/s'],'FontName',PlotSet.FontName)
mmfn_inspect
F = gcf;
for i = 1:length(F.Children);F.Children(i).FontSize = PlotSet.FontSize;end
saveas(gcf,[saveDir fp 'ContactForces.jpeg'])

%% Plot activation
for d = 1:length(dofList)
    currentDOF = dofList{d};N = size(EMG_MOM_Data.exc.(currentDOF).estimated,2);
    [ha, ~,FirstCol, LastRow] = tight_subplotBG(N,0,0.05,0.05,0.05,PlotSet.figSize);
    Labels=EMG_MOM_Data.muscles.(currentDOF);
    for col = 1:N
        axes(ha(col));hold on
        plot(EMG_MOM_Data.exc.(currentDOF).measured(:,col)); plot(EMG_MOM_Data.exc.(currentDOF).estimated(:,col));
        ylim([0 1])
        title(Labels{col},'Interpreter','none')
        if any(col==FirstCol);ylabel('Excitatin(0 to 1)');end
        if any(col==LastRow);xlabel(PlotSet.Xlab); end
    end
    legend({'MeasuredEMG' 'Adj/Synth exctiations'})
    currentRMSE = nanmean(RMSE.exc.(currentDOF)); currentR2=nanmean(R2.exc.(currentDOF));
    suptitle(sprintf('%s (mean R2 = %.2f, mean RMSE = %.2f)',currentDOF,currentR2,currentRMSE),'FontName',PlotSet.FontName)
    mmfn_inspect; F = gcf; for i = 1:length(F.Children);F.Children(i).FontSize = PlotSet.FontSize;end 
    saveas(gcf,[saveDir fp 'activations_' dofList{d} '.jpeg'])
    close all
end

%% Forces
for d = 1:length(dofList)
    N = ceil(sqrt(length(S.DOFmuscles.(dofList{d}))));
    M = ceil(length(S.DOFmuscles.(dofList{d}))/N);
    [ha, ~,FirstCol, LastRow] = tight_subplotBG(N,M,0.05,0.05,0.05,PlotSet.figSize);
    
    [MTUForce,PassiveForce,ActiveForce,MaxIsomForce,muscleList] = getCEINMSForces...
        (CEINMSSettings.outputSubjectFilename,BestItrDir,dofList{d},TimeWindow);

    for col = 1:length(muscleList)
        axes(ha(col)); ylim([0 2]);hold on
        plot(MTUForce(:,col)./MaxIsomForce)
%         plot(PassiveForce(:,pos)./MaxIsomForce)
%         plot(ActiveForce(:,pos)./MaxIsomForce)
        title(muscleList{col},'Interpreter','none')
        yticklabels(yticks)
        if any(col==FirstCol);ylabel('% Max Isom Force');end
        if any(col==LastRow);xlabel(PlotSet.Xlab); end
    end
    axes(ha(1));
    lg = legend({'MTU force' 'Passive force' 'ActiveForce'}); lg.Position = [0.14 0.91 0.08 0.07];
    suptitle([S.Joints{d} '_MuscleForces'],'Interpreter','none','FontName',PlotSet.FontName)
    mmfn_inspect
    F = gcf;
    for i = 1:length(F.Children); F.Children(i).FontSize = PlotSet.FontSize;end
    saveas(gcf,[saveDir fp 'MuscleForces_' dofList{d} '.jpeg'])
    close all
end

%% Length
for d = 1:length(dofList)
    N = ceil(sqrt(length(S.DOFmuscles.(dofList{d}))));
    M = ceil(length(S.DOFmuscles.(dofList{d}))/N);
    [ha, ~,FirstCol, LastRow] = tight_subplotBG(N,M,0.05,0.05,0.05,PlotSet.figSize);
    
    muscleList = S.DOFmuscles.(dofList{d});
    [NormFibreLength,~] = LoadResults_BG ([BestItrDir fp 'NormFibreLengths.sto'],...
    TimeWindow,muscleList,0);
    
    for col = 1:length(muscleList)
        axes(ha(col)); ylim([0.5 1.5]);hold on
        plot(NormFibreLength(:,col))
        title(muscleList{col},'Interpreter','none')
        yticklabels(yticks)
        if any(col==FirstCol);ylabel('Norm Fibre Length');end
        if any(col==LastRow);xlabel(PlotSet.Xlab); end
    end
    axes(ha(1));
    suptitle([S.Joints{d} '_NormFibreLength'],'Interpreter','none','FontName',PlotSet.FontName)
    mmfn_inspect
    F = gcf;
    for i = 1:length(F.Children); F.Children(i).FontSize = PlotSet.FontSize;end
    saveas(gcf,[saveDir fp 'NormFibreLength_' dofList{d} '.jpeg'])
    close all
end

%% Velocites
for d = 1:length(dofList)
    N = ceil(sqrt(length(S.DOFmuscles.(dofList{d}))));
    M = ceil(length(S.DOFmuscles.(dofList{d}))/N);
    [ha, ~,FirstCol, LastRow] = tight_subplotBG(N,M,0.05,0.05,0.05,PlotSet.figSize);
    
    muscleList = S.DOFmuscles.(dofList{d});
    [NormFibreVelocities,~] = LoadResults_BG ([BestItrDir fp 'NormFibreVelocities.sto'],...
    TimeWindow,muscleList,0);
    
    for col = 1:length(muscleList)
        axes(ha(col)); ylim([-1 1]);hold on
        plot(NormFibreVelocities(:,col))
        title(muscleList{col},'Interpreter','none')
        yticklabels(yticks)
        if any(col==FirstCol);ylabel('Norm Fibre Vel');end
        if any(col==LastRow);xlabel(PlotSet.Xlab); end
    end
    axes(ha(1));
    suptitle([S.Joints{d} '_NormFibreVelocities'],'Interpreter','none','FontName',PlotSet.FontName)
    mmfn_inspect
    F = gcf;
    for i = 1:length(F.Children); F.Children(i).FontSize = PlotSet.FontSize;end
    saveas(gcf,[saveDir fp 'NormFibreVelocities_' dofList{d} '.jpeg'])
    close all
end

%% Moment arms
for d = 1:length(dofList)
    N = ceil(sqrt(length(S.DOFmuscles.(dofList{d}))));
    M = ceil(length(S.DOFmuscles.(dofList{d}))/N);
    [ha, ~,FirstCol, LastRow] = tight_subplotBG(N,M,0.05,0.05,0.05,PlotSet.figSize);
    
    muscleList = S.DOFmuscles.(dofList{d});
    [MomArm,~] = LoadResults_BG ([OS.MA fp '_MuscleAnalysis_MomentArm_' dofList{d} '.sto'],TimeWindow,muscleList,0);
   
    
    for col = 1:length(muscleList)
        axes(ha(col));hold on
        plot(MomArm(:,col))
        title(muscleList{col},'Interpreter','none')
        yticklabels(yticks)
        if any(col==FirstCol);ylabel('Norm Fibre Vel');end
        if any(col==LastRow);xlabel(PlotSet.Xlab); end
    end
    axes(ha(1));
    suptitle([S.Joints{d} '_MomArm'],'Interpreter','none','FontName',PlotSet.FontName)
    mmfn_inspect
    F = gcf;
    for i = 1:length(F.Children); F.Children(i).FontSize = PlotSet.FontSize;end
    saveas(gcf,[saveDir fp 'MomArm_' dofList{d} '.jpeg'])
    close all
end

