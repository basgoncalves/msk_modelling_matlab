% all_forces_file = file with reserve actuators for each joint and muscle forces (use JRAforcefile(CEINMS_trialDir,osimFiles,all_forces_file) 

function CreateMuscleActuatorFiles(dirMC,all_forces_file,all_muscles,muscles_of_interest)

disp('creating actuator files for single muscles ...')
cd(dirMC)
all_forces = load_sto_file(all_forces_file);
% force_names = all_muscles;

force_names = fields(all_forces);
Nactuators = length(force_names);

for imusc = 1:Nactuators
    curr_musc = force_names{imusc};
    if ~contains(curr_musc,muscles_of_interest)
       continue
    end
    single_muscle_actuator = all_forces;
    for iforce_to_zero = 1:Nactuators
        
        if iforce_to_zero == imusc
            continue
        else
%             muscle_to_zero = force_names{imusc_to_zero};
            actuator_to_zero = force_names{iforce_to_zero};
            single_muscle_actuator.(actuator_to_zero)(:,1) = 0;
        end
    end
    resultsDir = [dirMC curr_musc '.sto'];
    write_sto_file_SO(single_muscle_actuator, resultsDir);
end
