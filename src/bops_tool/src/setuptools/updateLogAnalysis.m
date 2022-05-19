
function updateLogAnalysis(Dir,Analysis,SubjectInfo,Stage)

fp = filesep;
cd(Dir.Main)

if contains(Stage,'start')
    fileID = fopen([Dir.Main fp 'LogDataAnalysis.txt'],'a');
    date = char(datetime);
    txt = sprintf('\n%s starting for participant %s - %s ',Analysis,SubjectInfo.ID,date);
    fprintf(fileID, txt);
    fclose(fileID);
elseif contains(Stage,'end')
    
    fileID = fopen([Dir.Main fp 'LogDataAnalysis.txt'],'a');
    date = char(datetime);
    txt = sprintf(' finished at %s ',date);
    fprintf(fileID, txt);
    fclose(fileID);
    
elseif contains(Stage,' ')
    
    fileID = fopen([Dir.Main fp 'LogDataAnalysis.txt'],'a');
    txt = sprintf('\n \n');
    fprintf(fileID, txt);
    fclose(fileID);
end