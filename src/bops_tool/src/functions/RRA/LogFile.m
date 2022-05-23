import org.opensim.modeling.*
subject = 'ACL03';
LogDir = 'C:\Users\User\Desktop\OPENSIM_SCale_Test_BG\OPENSIM_SCale_Test\RRA\RRA_Cut4\Logs';
%CALL THE RRA TOOL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[~,log_mes]=dos(['RRA -S ','C:\Users\User\Desktop\OPENSIM_SCale_Test_BG\OPENSIM_SCale_Test\RRA\RRA_Cut4\Setup_ReduceResiduals1_Cut4.xml'],'-echo');

%SAVE THE WORKSPACE AND PRINT A LOG FILE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
names= dir(LogDir);
names = {names.name};
n = sprintf('%.f',sum(contains (names,['out_' subject]))+1);
cd(LogDir);
fid = fopen(['out_' subject '_' cut '_' n '.log'],'w+');    
fprintf(fid,'%s\n', log_mes);
fclose(fid);
