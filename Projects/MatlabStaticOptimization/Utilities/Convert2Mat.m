
function Convert2Mat()

fp = filesep;

mainDir = fileparts(fileparts([mfilename('fullpath') '.m']));
tesdataDir = [mainDir '\TestData\'] ; % Base Directory to base results directory.
savedir = [tesdataDir];

legs = {'l' 'r'};
penalties = {'0' '10' '100' '500' '1000'};
AVA = {'AVA_p30' 'AVA_p0'};
resultsDirs = dir([tesdataDir fp 'results_SO_*']);
muscleForces = struct;
contactForces = struct;
joints = {'hip_resultant' 'hip_x' 'hip_y' 'hip_z' 'knee_resultant' 'knee_x' 'knee_y' 'knee_z'};

trap.muscleForces = struct;
trap.contactForces = struct;

ik = struct;
ik.hip_flexion = [];
ik.knee_angle = [];
ik.ankle_angle = [];

id = struct;
id.hip_flexion = [];
id.knee_angle = [];
id.ankle_angle = [];

% load IK and ID
cd(fileparts(resultsDirs(1).folder))
ik_data = load_sto_file(['results_ik.sto']);
id_data = load_sto_file(['results_id.sto']);

cd(resultsDirs(1).folder)

for iLeg = 1:2
    l = lower(legs{iLeg});

    if contains(l,'l'); leg = 'left';
    else; leg = 'right';
    end
    
    disp(['loading data for ' leg ' leg...'])

    for iAva = 1:length(AVA)
        count_loops = 0;
        curr_AVA = AVA{iAva};

        for iPen = 1:length(penalties)
                        
            curr_penalty = penalties{iPen};
            resultsDirs = dir([tesdataDir fp 'results_SO_' leg '_*_Pen' curr_penalty '_' curr_AVA '*']);
            cd(resultsDirs(1).folder)

            muscles_of_interest = strcat({'iliacus_' 'psoas_' 'recfem_' 'tfl_' 'glmax1_' 'glmed1_' 'glmin1_'}, l);

            muscles_of_interest = strcat({'addbrev_' 'addlong_' 'addmagDist_' 'addmagIsch_' 'addmagMid_' 'addmagProx_' 'bflh_' 'bfsh_' ...
                'edl_' 'ehl_' 'fdl_' 'fhl_' 'gaslat_' 'gasmed_' 'glmax1_' 'glmax2_' 'glmax3_' 'glmed1_' 'glmed2_' 'glmed3_'...
                'glmin1_' 'glmin2_' 'glmin3_' 'grac_' 'iliacus_' 'perbrev_' 'perlong_' 'piri_' 'psoas_' 'recfem_' 'sart_' ...
                'semimem_' 'semiten_' 'soleus_' 'tfl_' 'tibant_' 'tibpost_' 'vasint_' 'vaslat_' 'vasmed_'},l);


            force_file = [resultsDirs(1).name fp 'results_forces.sto'];
            force_data = load_sto_file(force_file);
            fs = 1/(force_data.time(2)-force_data.time(1));

            muscleForces.(['Pen_' curr_penalty]) = struct;
            for iMuscle = 1:length(muscles_of_interest)
                iMuscle = muscles_of_interest{iMuscle};
                muscleForces.(['Pen_' curr_penalty]).(iMuscle) = [];
                trap.muscleForces.(['Pen_' curr_penalty]).(iMuscle) = [];
            end

            for iJoint = 1:length(joints)
                contactForces.(['Pen_' curr_penalty]).(joints{iJoint}) = [];
                trap.contactForces.(['Pen_' curr_penalty]).(joints{iJoint}) = [];
            end

            % loop through each trial
            for iFolder = 1:length(resultsDirs)

                disp([resultsDirs(iFolder).name])
                count_loops = count_loops +1;

                % load muscle forces
                force_file = [resultsDirs(iFolder).name fp 'results_forces.sto'];
                force_data = load_sto_file(force_file);

                % load joint contact force
                contactForces_file = [resultsDirs(iFolder).name fp 'results_JointReaction_JointRxn_ReactionLoads.sto'];
                contactForces_data = load_sto_file(contactForces_file);

                look_for_substrings = {['hip_' l], ['knee_' l], ['ankle_' l]};
                [contactForces_data] = calc_resultant_JCF(contactForces_data,look_for_substrings,fs);

                try % in child
                    contactForces.(['Pen_' curr_penalty]).(joints{2})(:,end+1) = contactForces_data.(['hip_' l '_on_femur_' l '_in_femur_' l '_fx_norm']);
                    contactForces.(['Pen_' curr_penalty]).(joints{3})(:,end+1) = contactForces_data.(['hip_' l '_on_femur_' l '_in_femur_' l '_fy_norm']);
                    contactForces.(['Pen_' curr_penalty]).(joints{4})(:,end+1) = contactForces_data.(['hip_' l '_on_femur_' l '_in_femur_' l '_fz_norm']);
                    contactForces.(['Pen_' curr_penalty]).(joints{1})(:,end+1) = contactForces_data.(['hip_' l '_norm']);


                    contactForces.(['Pen_' curr_penalty]).(joints{6})(:,end+1) = contactForces_data.(['walker_knee_' l '_on_tibia_' l '_in_tibia_' l '_fx_norm']);
                    contactForces.(['Pen_' curr_penalty]).(joints{7})(:,end+1) = contactForces_data.(['walker_knee_' l '_on_tibia_' l '_in_tibia_' l '_fy_norm']);
                    contactForces.(['Pen_' curr_penalty]).(joints{8})(:,end+1) = contactForces_data.(['walker_knee_' l '_on_tibia_' l '_in_tibia_' l '_fz_norm']);
                    contactForces.(['Pen_' curr_penalty]).(joints{5})(:,end+1) = contactForces_data.(['knee_' l '_norm']);

                catch % in parent

                    contactForces.(['Pen_' curr_penalty]).(joints{2})(:,end+1) = contactForces_data.(['hip_' l '_on_pelvis_in_pelvis_fx_norm']);
                    contactForces.(['Pen_' curr_penalty]).(joints{3})(:,end+1) = contactForces_data.(['hip_' l '_on_pelvis_in_pelvis_fy_norm']);
                    contactForces.(['Pen_' curr_penalty]).(joints{4})(:,end+1) = contactForces_data.(['hip_' l '_on_pelvis_in_pelvis_fz_norm']);
                    contactForces.(['Pen_' curr_penalty]).(joints{1})(:,end+1) = contactForces_data.(['hip_' l '_norm']);

                    contactForces.(['Pen_' curr_penalty]).(joints{6})(:,end+1) = contactForces_data.(['walker_knee_' l '_on_femur_' l '_in_femur_' l '_fx_norm']);
                    contactForces.(['Pen_' curr_penalty]).(joints{7})(:,end+1) = contactForces_data.(['walker_knee_' l '_on_femur_' l '_in_femur_' l '_fy_norm']);
                    contactForces.(['Pen_' curr_penalty]).(joints{8})(:,end+1) = contactForces_data.(['walker_knee_' l '_on_femur_' l '_in_femur_' l '_fz_norm']);
                    contactForces.(['Pen_' curr_penalty]).(joints{5})(:,end+1) = contactForces_data.(['knee_' l '_norm']);
                end

                % area under the curve of resultant contact force
                trap.contactForces.(['Pen_' curr_penalty]).(joints{1})(end+1) = trapz(contactForces_data.time,contactForces_data.(['hip_' l]));
                trap.contactForces.(['Pen_' curr_penalty]).(joints{5})(end+1) = trapz(contactForces_data.time,contactForces_data.(['knee_' l]));

                % find time range in muscle force data to only use the ext
                % biomech for the same time range
                time_range = [min(force_data.time) max(force_data.time)];
                idx_time = [find(ik_data.time==time_range(1)): find(ik_data.time==time_range(2))]';


                % load IK and ID data (only use the iterations of the first
                % penalty, after that kinematics and kienctics just repeat)
                if count_loops <= length(resultsDirs)
                    ik.hip_flexion(:,end+1) = TimeNorm(ik_data.(['hip_flexion_' l])(idx_time),fs);
                    ik.knee_angle(:,end+1)  = TimeNorm(ik_data.(['knee_angle_' l])(idx_time),fs);
                    ik.ankle_angle(:,end+1) = TimeNorm(ik_data.(['ankle_angle_' l])(idx_time),fs);

                    id.hip_flexion(:,end+1) = TimeNorm(id_data.(['hip_flexion_' l '_moment'])(idx_time),fs);
                    id.knee_angle(:,end+1)  = TimeNorm(id_data.(['knee_angle_' l '_moment'])(idx_time),fs);
                    id.ankle_angle(:,end+1) = TimeNorm(id_data.(['ankle_angle_' l '_moment'])(idx_time),fs);
                end


                % add muscle forces and AUC to the final struct
                for iMuscle = 1:length(muscles_of_interest)
                    iMuscle = muscles_of_interest{iMuscle};
                    muscleForces.(['Pen_' curr_penalty]).(iMuscle)(:,end+1) = TimeNorm([force_data.(iMuscle)],fs);

                    trap.muscleForces.(['Pen_' curr_penalty]).(iMuscle)(:,end+1) = trapz(force_data.time,force_data.(iMuscle));
                end
            end
        end
        [muscleForces] = sumMuscleForces(muscleForces,l);
        cd(savedir)
        save(['results_' l '_' curr_AVA '.mat'],'contactForces','muscleForces','trap','ik','id','muscles_of_interest','joints')
    end
end


%--------------------------------------------------------------------------------------------------%
function [contactForces_data] = calc_resultant_JCF(contactForces_data,look_for_substrings,fs)

all_labels = fields(contactForces_data);
labels_of_interest = all_labels(contains(all_labels,look_for_substrings));
labels_of_interest = labels_of_interest(contains(labels_of_interest,{'fx','fy','fz'}));

Ncols = size(labels_of_interest,1);
count = 1;
for i = 1:3:length(labels_of_interest)
    x = contactForces_data.(labels_of_interest{i});
    y = contactForces_data.(labels_of_interest{i+1});
    z = contactForces_data.(labels_of_interest{i+2});

    resultant = sqrt(x.^2+y.^2+z.^2);
    contactForces_data.(look_for_substrings{count}) = resultant;
    count = count + 1;
end

all_labels = fields(contactForces_data);
for i = 2:length(all_labels)
    contactForces_data.([all_labels{i} '_norm']) = TimeNorm(contactForces_data.([all_labels{i}]),fs);
end


%--------------------------------------------------------------------------------------------------%
function TimeNormalizedData = TimeNorm (Data,fs)

TimeNormalizedData=[];

for col = 1: size (Data,2)

    currentData = Data(:,col);
    currentData(isnan(currentData))=[];
    if length(currentData)<3
        TimeNormalizedData(1:101,col)= NaN;
        continue
    end

    timeTrial = 0:1/fs:size(currentData,1)/fs;
    timeTrial(end)=[];
    Tnorm = timeTrial(end)/101:timeTrial(end)/101:timeTrial(end);

    TimeNormalizedData(1:101,col)= interp1(timeTrial,currentData,Tnorm)';
end


%--------------------------------------------------------------------------------------------------%
function [muscleForces] = sumMuscleForces(muscleForces,leg)

penalties = fields(muscleForces);

muscles_groups = {{['recfem_' leg]} {['tfl_' leg]} {['sart_' leg]} {['soleus_' leg]} ...
    strcat({'addbrev_' 'addlong_' 'addmagDist_' 'addmagIsch_' 'addmagMid_' 'addmagProx_' 'grac_'},leg) ...
    strcat({'bflh_' 'bfsh_' 'semimem_' 'semiten_'},leg)...
    strcat({'gaslat_' 'gasmed_'},leg)...
    strcat({'glmax1_' 'glmax2_' 'glmax3_'},leg)...
    strcat({'glmed1_' 'glmed2_' 'glmed3_'},leg)...
    strcat({'glmin1_' 'glmin2_' 'glmin3_'},leg)...
    strcat({'iliacus_' 'psoas_'},leg) ...
    strcat({'vasint_' 'vaslat_' 'vasmed_'},leg)};

muscles_groups_names = {'recfem' 'tfl' 'sart' 'soleus' 'adductors' 'hamstrings' 'gastroc' 'glmax_all' 'glmed_all' 'glmin_all' 'ilio_psoas' 'vasti'};

for iPen = 1:length(penalties)
    for iGroup = 1:length(muscles_groups)
        muscleForces.(penalties{iPen}).(muscles_groups_names{iGroup}) = [];
    end
end

for iPen = 1:length(penalties)
    for iGroup = 1:length(muscles_groups)
        muscles = muscles_groups{iGroup};
        muscle_foces_single_group = muscleForces.(penalties{iPen}).(muscles{1});
        for iMuscle = 2:length(muscles)
            muscle_foces_single_group = muscle_foces_single_group + muscleForces.(penalties{iPen}).(muscles{iMuscle});

        end
        muscleForces.(penalties{iPen}).(muscles_groups_names{iGroup}) = muscle_foces_single_group;

    end
end
