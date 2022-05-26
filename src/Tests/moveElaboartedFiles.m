
function moveElaboartedFiles(Subjects)

origin  = 'E:\3-PhD\Data\MocapData\ElaboratedData';
trgt    = 'C:\Users\Bas\Documents\3-PhD\MocapData\ElaboratedData';
mkdir([trgt])

for ff = 1:length(Subjects)
   
    [Dir,Temp,SubjectInfo,Trials] = getdirFAI(Subjects{ff});
  
    
    
    [~,session] = fileparts(Dir.Elaborated);
    destination = [trgt fp Subjects{ff} fp session];
    mkdir([destination])
    
    disp(['copying ' Subjects{ff} '...'])
    
    copyfile(Dir.IK,[destination fp 'inverseKinematics'])
    copyfile(Dir.ID,[destination fp 'inverseDynamics'])
    copyfile(Dir.RRA,[destination fp 'residualReductionAnalysis'])
    copyfile(Dir.MA,[destination fp 'muscleAnalysis'])
    copyfile(Dir.SO,[destination fp 'StaticOpt'])
    copyfile(Dir.JRA,[destination fp 'JointReactionAnalysis'])
    copyfile(Dir.CEINMS,[destination fp 'ceinms'])
    copyfile(Dir.OSIM_LinearScaled,[destination])
    copyfile(Dir.OSIM_RRA,[destination])
    copyfile(Dir.OSIM_LO,[destination])
    copyfile(Dir.OSIM_LO_HANS,[destination])
    copyfile(Dir.OSIM_LO_HANS_originalMass,[destination])
    
end