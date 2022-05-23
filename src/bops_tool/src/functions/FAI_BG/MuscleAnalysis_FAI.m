%% Description - Goncalves, BM (2021)
% Create inverse dynamics xml and run ID OS for each trial
%  after creating inverse kinematics

function MuscleAnalysis_FAI(Dir, Temp, trialName,Logic)

% create directories
fp = filesep;
import org.opensim.modeling.*
[TimeWindow,~,~] = TimeWindow_FatFAIS(Dir,trialName);

DirMAtrial = [Dir.MA fp trialName]; mkdir(DirMAtrial);
[osimFiles] = getosimfilesFAI(Dir,trialName,DirMAtrial); % also creates the directories
if Logic==2 && exist(osimFiles.MAsetup); return; end

mkdir(fileparts(osimFiles.MAsetup))
copyfile(Temp.MASetup,osimFiles.MAsetup)

osimModel = Model(osimFiles.MAmodel);
analyzeTool=AnalyzeTool(osimFiles.MAsetup);
analyzeTool.setModel(osimModel);
analyzeTool.setModelFilename(osimModel.getDocumentFileName());
analyzeTool.setReplaceForceSet(false);
analyzeTool.setResultsDir(osimFiles.MA);
analyzeTool.setOutputPrecision(8)
analyzeTool.setInitialTime(TimeWindow(1));
analyzeTool.setFinalTime(TimeWindow(2));
analyzeTool.setSolveForEquilibrium(false)
analyzeTool.setMaximumNumberOfSteps(20000)
analyzeTool.setMaxDT(1)
analyzeTool.setMinDT(1e-008)
analyzeTool.setErrorTolerance(1e-005)
analyzeTool.setCoordinatesFileName(osimFiles.IKresults)
analyzeTool.setExternalLoadsFileName(osimFiles.IDgrfxml)
analyzeTool.print(osimFiles.MAsetup);
analyzeTool.run

