% all_forces_file = file with reserve actuators for each joint and muscle forces (use JRAforcefile(CEINMS_trialDir,osimFiles,all_forces_file) 

function CreateMuscleActuatorFiles(dirMC,all_forces_file,all_muscles,muscles_of_interest)

disp('creating actuator files for single muscles ...')
cd(dirMC)
all_forces = load_sto_file(all_forces_file);
Nmuscles = length(all_muscles);

for imusc = 1:Nmuscles
    curr_musc = all_muscles{imusc};
    if ~contains(curr_musc,muscles_of_interest)
       continue
    end
    single_muscle = all_forces;
    for imusc_to_zero = 1:Nmuscles
        
        if imusc_to_zero == imusc
            continue
        else
            muscle_to_zero = all_muscles{imusc_to_zero};
            single_muscle.(muscle_to_zero)(:,1) = 0;
        end
    end
    resultsDir = [dirMC curr_musc '.sto'];
    write_sto_file_SO(single_muscle, resultsDir);
end
