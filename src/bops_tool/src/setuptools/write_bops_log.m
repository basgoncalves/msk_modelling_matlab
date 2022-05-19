% see setupSubject
function write_bops_log(Analysis,Stage)

bops = load_setup_bops;
bopsdir = bops.directories.mainData;

cd(bopsdir)

if nargin == 0 || contains(Stage,'end')
    
    fileID = fopen([bopsdir fp 'LogDataAnalysis.txt'],'a');
    date = char(datetime);
    txt = sprintf(' finished at %s ',date);
    fprintf(fileID, txt);
    fclose(fileID);
    
elseif contains(Stage,'start')
    fileID = fopen([bopsdir fp 'LogDataAnalysis.txt'],'a');
    date = char(datetime);
    txt = sprintf('\n%s starting for participant %s / %s - %s',Analysis,bops.current.subject,bops.current.session,date);
    fprintf(fileID, txt);
    fclose(fileID);
    
elseif contains(Stage,'skip')
    
    fileID = fopen([bopsdir fp 'LogDataAnalysis.txt'],'a');
    txt = sprintf('\n \n');
    fprintf(fileID, txt);
    fclose(fileID);
end