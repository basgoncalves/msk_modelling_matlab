
function BatchLinearScaling_FAI_BG (Subjects)

fp = filesep;
for ff = 1:length(Subjects)
    
    [Dir,Temp,SubjectInfo,Trials,~] = getdirFAI(Subjects{ff});
  
    updateLogAnalysis(Dir,'Linear scaling',SubjectInfo,'start')

    % Satatic elaboration
    StaticInterface_BG(Dir,Temp,Trials)
    runStaticElaboration(Dir.staticElaborations)
    
    % Linear scale model based on marker data
    [~,setupScaleXML]  = scaleXMLWrite_BG(Dir,Temp,SubjectInfo,Trials);
    M=dos(['scale -S ' setupScaleXML],'-echo');
    [TSE,RMSE,MaxError] = plotMarkerErrStatic([Dir.Scale fp 'out.log']);
    cmdmsg('Model Scaled')
    close all
    cd(Dir.staticElaborations); save Errors TSE RMSE MaxError
    updateLogAnalysis(Dir,'Linear scaling',SubjectInfo,'end')
end
cmdmsg(['MOtoNMS complete'])
