function MuscleParamenters = GetMuscleParameters_FAI(Subjects)

fp = filesep;
MuscleParamenters = struct;
MuscleParamenters.participants = {};
MuscleParamenters.tendonSlackLength=table;
MuscleParamenters.optimalFibreLength=table;
MuscleParamenters.C1=table;
MuscleParamenters.C2=table;
MuscleParamenters.maxIsometricForce=table;

for ff = 1:length(Subjects)
    [Dir,Temp,SubjectInfo,Trials] = getdirFAI(smfai(Subjects(ff)));
    fprintf('%s ...\n',SubjectInfo.ID)

    CEINMSSettings = CEINMSsetup_FAI(Dir,Temp,SubjectInfo);
    MuscleParamenters.participants{ff}=SubjectInfo.ID;
    M=xml_read(CEINMSSettings.outputSubjectFilename);        % load model
    Muscles = {M.mtuSet.mtu.name};
    NMuscles = length([M.mtuSet.mtu]);
    
    for m = 1:NMuscles
        MuscleParamenters.tendonSlackLength.(Muscles{m})(ff) = M.mtuSet.mtu(m).tendonSlackLength;
        MuscleParamenters.optimalFibreLength.(Muscles{m})(ff) = M.mtuSet.mtu(m).optimalFibreLength;
        MuscleParamenters.C1.(Muscles{m})(ff) = M.mtuSet.mtu(m).c1;
        MuscleParamenters.C2.(Muscles{m})(ff) = M.mtuSet.mtu(m).c2;
        MuscleParamenters.maxIsometricForce.(Muscles{m})(ff) = M.mtuSet.mtu(m).maxIsometricForce*M.mtuSet.mtu(m).strengthCoefficient/SubjectInfo.Weight*9.81;
    end
end

save([Dir.Results fp 'CEINMS' fp 'MuscleParamenters.mat'],'MuscleParamenters')

% b=bar(MuscleParamenters.tendonSlackLength.recfem_r)
% xticks([1:length(MuscleParamenters.participants)])
% xticklabels(MuscleParamenters.participants)
