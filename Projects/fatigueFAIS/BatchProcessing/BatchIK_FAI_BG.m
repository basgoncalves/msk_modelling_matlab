% batch Inverse kinematics
% Logic = 1 (default); 1 = re-run trials / 2 = do not re-run trials
function BatchIK_FAI_BG(Subjects,Logic)

fp = filesep;

for ff = 1:length(Subjects)
 
    [Dir,Temp,SubjectInfo,~]=getdirFAI(Subjects{ff});           % get directories and subject info
    if isempty(fields(SubjectInfo));continue; end                               % check if subject info exists
    updateLogAnalysis(Dir,'IK',SubjectInfo,'start')                             % update log file
    ElabXML=xml_read([Dir.dynamicElaborations fp 'elaboration.xml']);           % load elaboration xml
    TrialList=split(ElabXML.Trials,' ')';                                       % get trials from xml
    
    for trial=TrialList
        InverseKinematics_FAI(Dir,Temp,trial{1},Logic);                         % Run IK for single trial
    end    
    
    updateLogAnalysis(Dir,'IK',SubjectInfo,'end')                               % update log file end
end
%     PlotOSIMresults(Subjects,'IK')                                              % plot results
cmdmsg('Inverse kinematics finished')


