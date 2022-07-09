
function Plot_Muscle_Contributions_to_HCF

Dir = getdirFAI;  
Subjects = dir([Dir.Main fp 'ElaboratedData']);
Subjects = {Subjects.name}';

for isub = 1:length(Subjects)
 
    [Dir,Temp,SubjectInfo,Trials] = getdirFAI(Subjects{isub});
    
    leg = lower(SubjectInfo.TestedLeg);                                                                             % find muscles used in CEINMS
    s = getOSIMVariablesFAI(upper(leg),modelname);
    muscles_of_interest = strcat(s.muscles_of_interest.All,['_' leg]);
    
    disp(SubjectInfo.ID)
    trialList = Trials.CEINMS;
    trialList = trialList(contains(trialList,'Run'));
    for ii = 1:length(trialList)
        trialName = trialList{ii};
        [trialDirs] = getosimfilesFAI(Dir,trialName);
        if exits([trialDirs.SO fp lastMuscle '_InOnParentFrame_ReactionLoads.sto'])
            
        end
    
        
    end
    
end
