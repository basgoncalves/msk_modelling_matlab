% batch MOtoNMS


function BatchC3D2MAT_FAI_BG (Subjects)

fp = filesep;
for ff = 1:length(Subjects)
    
    [Dir,~,SubjectInfo,Trials] = getdirbops(Subjects{ff});
    
    updateLogAnalysis(Dir,'Convert C3D to MAT',SubjectInfo,'start')
    
    % convert files from .c3d to .mat files (see ..ElaboratedData\dynamicElaboration)
    C3D2MAT_BG(Dir.Input,Trials.Dynamic)
    C3D2MAT_BG(Dir.Input,Trials.Isometrics_pre)
    C3D2MAT_BG(Dir.Input,Trials.Isometrics_post)
    C3D2MAT_BG(Dir.Input,Trials.Static)    
   
    updateLogAnalysis(Dir,'Convert C3D to MAT',SubjectInfo,'end')
end
