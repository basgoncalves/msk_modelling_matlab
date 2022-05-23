% batch induced acceleration analysis BG 2020

% Logic = 1 (default); 1 = re-run trials / 0 = do not re-run trials
function BatchIAA_FAI_BG (Subjects,Logic, Analysis)
fp = filesep;
try Logic; catch; Logic = 1; end

for ff = 1:length(Subjects)
    
    [Dir,Temp,SubjectInfo,Trials] = getdirFAI(Subjects{ff});
    updateLogAnalysis(Dir,'Induced acceleration analysis',SubjectInfo,'start')

    trialList = Trials.CEINMS;
    idx = contains(contains(trialList,'baseline')&contains(trialList,'1');
    trialList = trialList(idx);
    for ii = 1:length(trialList)

        trialName = trialList{ii};
        trialDirs = getosimfilesFAI(Dir,trialName,[Dir.IAA fp trialName]); % load paths for this trial
        fprintf('%s \n',trialName)
        mkdir(trialDirs.IAA)

                copyfile(trialDirs.IAAkinematics,trialDirs.IAA)                         % copy kinematics
        copyfile(trialDirs.IAAkinematics,trialDirs.IAA)                         % copy kinematics
        copyfile(trialDirs.IAAexternal_loads_file,trialDirs.IAA)                % copy GRF xml
        copyfile(trialDirs.SOactuators,trialDirs.IAAactuators)                  % copy actuator xml
        adjustActuatorXML(trialDirs.IAAactuators,10,10,10,10,10,10,10,10);              % adjust actuator xml (ActuatorFile,hip,knee,ankle,lumbar,arm,elbow,pro,pelvis)
                     
        
        BodyNames = 'all';  % all = all the segments; 'center_of_mass' = indicate the induced accelerations of the system center of mass
        % static opt if needed
        copyfile([ElaborationFilePath fp trialName fp trialName '.mot'],IAAPath)
        kinetics_file = [DirIAA fp trialName fp trialName '.mot'];
       
        % run Static Optimisation (check templates in OrganiseFAI)
        if ~exist(osimFiles.SOforceResults); runSO_BG(Dir, Temp, trialName); end     
        
        OptimalSettings = OptimalGammaCEINMS_BG(Dir,[Dir.CEINMSsimulations fp trialName],SubjectInfo);
        CEINMS_trialDir = OptimalSettings.Dir;
        JRAforcefile(CEINMS_trialDir,trialDirs,trialDirs.IAAforcefile);
        SetupXML =  xml_read(Temp.IAASetup); 
        SetupXML.AnalyzeTool.coordinates_file = trialDirs.IAAkinematics;  % coordinates
        SetupXML.AnalyzeTool.external_loads_file = trialDirs.IAAexternal_loads_file;    
        SetupXML.AnalyzeTool.force_set_files = trialDirs.IAAactuators;                                  %actuators
        SetupXML.AnalyzeTool.AnalysisSet.objects.IndAccPI.forces_file = trialDirs.IAAforcefile;
        SetupXML.AnalyzeTool.AnalysisSet.objects.IndAccPI.kinetics_file = trialDirs.IAAkinetics_file;
        SetupXML.AnalyzeTool.AnalysisSet.objects.IndAccPI.weights = '1000 100 10';  % weights IndAcc
        SetupXML.AnalyzeTool.initial_time = FootContact.time;
        SetupXML.AnalyzeTool.final_time = FT;                                   %FT = final time with some force measured;
% external loads files 
% XML =  xml_read(GRFxml);
% XML.ExternalLoads.external_loads_model_kinematics_file = relativepath(coordinates_file,DirIAA);
% XML.ExternalLoads.datafile = relativepath(kinetics_file,DirIAA);
% xml_write(GRFxml, XML, root,Pref);




%force file
[kinetics_file,~,FT] = deleteForceIAA(kinetics_file,AcqXML,GRFxml,kinetics_file);




[TimeWindow, ~,FootContact] = TimeWindow_FatFAIS(DirC3D,trialName,TestedLeg);       % time window (based on the time in SO file)



%% write xml 
IAAxmlPath = [DirIAA fp 'setup_IAA.xml'];
xml_write(IAAxmlPath, SetupXML, root,Pref);

%% Run IAA
% 
import org.opensim.modeling.*
cd(fileparts(IAAxmlPath))

% % dos(['analyze -S ' SetupIAA])
% % T.Dorn's plug in
% force_file = CombineSOandCEINMS(CEINMS_trialDir,SOdir,0);
dos(['analyze -L IndAccPI -S ' IAAxmlPath])
%         ResultsIAA(DirIAA)
    end
    
    updateLogAnalysis(Dir,'IAA',SubjectInfo)


    
end

disp('=================================')
disp('')
disp('Induced acceleration analysis finished ')
disp('')
disp('=================================')

