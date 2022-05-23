% contactTime 

smfai


%generate the first subject 
folderParts = split(SubjectFoldersElaborated{1},filesep);
Subject = folderParts{end};
clear TrialNames

for ff = 1:length(SubjectFoldersElaborated)
    
    OldSubject = Subject;
    folderParts = split(SubjectFoldersElaborated{ff},filesep);
    Subject = folderParts{end};
    DirElaborated = strrep(DirElaborated,OldSubject,Subject);
    DirC3D = [strrep(DirElaborated,'ElaboratedData','InputData') filesep sessionName];
    OrganiseFAI
    LRFAI           % load results results FAI
    Variables = fields(Run);
    Power = Run.(Variables{1}).JointPowers;
    
    
    
    ContactTime =[];

    for ii = 1: size(Power,2)
        
                    
            Percent = Run.GaitCycle.PercentageHeelStrike(ii);
            trial = Power(:,ii);
            LTrial = length(trial(~isnan(trial)))/fs;
            ContactTime(end+1)= LTrial-(Percent*LTrial/100);
           
      
        
       
    end
    Run.ContactTime = ContactTime;
  
    
save RunningBiomechanics Run    
end

