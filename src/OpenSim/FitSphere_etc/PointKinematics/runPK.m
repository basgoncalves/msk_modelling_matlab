function runPK(folderPK)
%Run PK
disp('calculate PointKinematics')
setupfilePK = [folderPK,'PK_setup.xml'];
logFileOut=[folderPK '\out.log'];% Save the log file in a Log folder for each trial
dos(['opensim-cmd run-tool ' setupfilePK ' > ' logFileOut]);
