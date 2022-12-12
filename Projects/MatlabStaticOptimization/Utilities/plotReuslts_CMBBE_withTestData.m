

function plotReuslts_CMBBE_withTestData(savedir)

fp = filesep;

onBody = 'parent';
mainDir = fileparts(fileparts([mfilename('fullpath') '.m']));
tesdataDir = [mainDir '\TestData\'] ; % Base Directory to base results directory.

if nargin < 1 
   savedir = [tesdataDir fp 'results_figures'];
end

if isfolder(savedir)
    mkdir(savedir)
end

legs = {'l' 'r'};
penalties = {'0' '10' '100' '500' '1000'};
resultsDirs = dir([tesdataDir fp 'results_SO_*']);
muscleForces = struct;
contactForces = struct;
joints = {'hip_x' 'hip_y' 'hip_z' 'knee_x' 'knee_y' 'knee_z'};

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
    count_loops = 0;

    for iPen = 1:length(penalties)
        
        curr_penalty = penalties{iPen};

        resultsDirs = dir([tesdataDir fp 'results_SO_right_*_Pen' curr_penalty '*']);
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
        end

        for iJoint = 1:length(joints)
            contactForces.(['Pen_' curr_penalty]).(joints{iJoint}) = [];
        end

        % loop through each trial
        for iFolder = 1:length(resultsDirs)
            count_loops = count_loops +1;
            
            force_file = [resultsDirs(iFolder).name fp 'results_forces.sto'];
            force_data = load_sto_file(force_file);

            contactForces_file = [resultsDirs(iFolder).name fp 'results_JointReaction_JointRxn_ReactionLoads.sto'];
            contactForces_data = load_sto_file(contactForces_file);
            
            look_for_substrings = {['hip_' l], ['knee_' l], ['ankle_' l]};
            [contactForces_data] = resulstant_JCF(contactForces_data,look_for_substrings,fs);
    
            if contains(onBody,'child')
                contactForces.(['Pen_' curr_penalty]).(joints{1})(:,end+1) = contactForces_data.(['hip_' l '_norm']);
                contactForces.(['Pen_' curr_penalty]).(joints{1})(:,end+1) = contactForces_data.(['hip_' l '_on_femur_' l '_in_femur_' l '_fx_norm']);
                contactForces.(['Pen_' curr_penalty]).(joints{2})(:,end+1) = contactForces_data.(['hip_' l '_on_femur_' l '_in_femur_' l '_fy_norm']);
                contactForces.(['Pen_' curr_penalty]).(joints{3})(:,end+1) = contactForces_data.(['hip_' l '_on_femur_' l '_in_femur_' l '_fz_norm']);
                
                contactForces.(['Pen_' curr_penalty]).(joints{4})(:,end+1) = contactForces_data.(['walker_knee_' l '_on_tibia_' l '_in_tibia_' l '_fx_norm']);
                contactForces.(['Pen_' curr_penalty]).(joints{5})(:,end+1) = contactForces_data.(['walker_knee_' l '_on_tibia_' l '_in_tibia_' l '_fy_norm']);
                contactForces.(['Pen_' curr_penalty]).(joints{6})(:,end+1) = contactForces_data.(['walker_knee_' l '_on_tibia_' l '_in_tibia_' l '_fz_norm']);
                
            elseif contains(onBody,'parent')
                contactForces.(['Pen_' curr_penalty]).(joints{1})(:,end+1) = contactForces_data.(['hip_' l '_on_pelvis_in_pelvis_fx_norm']);
                contactForces.(['Pen_' curr_penalty]).(joints{2})(:,end+1) = contactForces_data.(['hip_' l '_on_pelvis_in_pelvis_fy_norm']);
                contactForces.(['Pen_' curr_penalty]).(joints{3})(:,end+1) = contactForces_data.(['hip_' l '_on_pelvis_in_pelvis_fz_norm']);
                
                contactForces.(['Pen_' curr_penalty]).(joints{4})(:,end+1) = contactForces_data.(['walker_knee_' l '_on_femur_' l '_in_femur_' l '_fx_norm']);
                contactForces.(['Pen_' curr_penalty]).(joints{5})(:,end+1) = contactForces_data.(['walker_knee_' l '_on_femur_' l '_in_femur_' l '_fy_norm']);
                contactForces.(['Pen_' curr_penalty]).(joints{6})(:,end+1) = contactForces_data.(['walker_knee_' l '_on_femur_' l '_in_femur_' l '_fz_norm']);
            end
            
            time_range = [min(force_data.time) max(force_data.time)];

            idx_time = [find(ik_data.time==time_range(1)): find(ik_data.time==time_range(2))]';
            x_time = 0:100';
            
            % load IK and ID data (only use the iterations of the first
            % penalty, after that kinematics and kienctics just repeat)
            if count_loops <= length(resultsDirs)
                ik.hip_flexion(:,end+1) = TimeNorm(ik_data.(['hip_flexion_' l])(idx_time),fs);
                ik.knee_angle(:,end+1) = TimeNorm(ik_data.(['knee_angle_' l])(idx_time),fs);
                ik.ankle_angle(:,end+1) = TimeNorm(ik_data.(['ankle_angle_' l])(idx_time),fs);

                id.hip_flexion(:,end+1) = TimeNorm(id_data.(['hip_flexion_' l '_moment'])(idx_time),fs);
                id.knee_angle(:,end+1) = TimeNorm(id_data.(['knee_angle_' l '_moment'])(idx_time),fs);
                id.ankle_angle(:,end+1) = TimeNorm(id_data.(['ankle_angle_' l '_moment'])(idx_time),fs);
            end

                
            for iMuscle = 1:length(muscles_of_interest)
                iMuscle = muscles_of_interest{iMuscle};
                muscleForces.(['Pen_' curr_penalty]).(iMuscle)(:,end+1) = TimeNorm([force_data.(iMuscle)],fs);
            end
        end
    end

    cd(savedir)
    save(['results_' l '.mat'],"contactForces","muscleForces","ik","id","muscles_of_interest","joints")
    %% plot external biomech
    [ha, pos,FirstCol,LastRow,LastCol] = tight_subplotBG(2,3);
    kinematics_color = [0.5 0.5 0.1];

    % plot kinematics
    axes(ha(1))
    plotShadedSD(mean(ik.hip_flexion,2),std(ik.hip_flexion,0,2),kinematics_color);
    ylabel('joint angle (deg)')

    axes(ha(2))
    plotShadedSD(mean(ik.knee_angle,2),std(ik.knee_angle,0,2),kinematics_color);

    axes(ha(3))
    plotShadedSD(mean(ik.ankle_angle,2),std(ik.ankle_angle,0,2),kinematics_color);

    % plot moments
    first_moments_plot = 4;
    axes(ha(first_moments_plot))
    plotShadedSD(mean(id.hip_flexion,2),std(id.hip_flexion,0,2),kinematics_color);
    ylabel('joint moment (Nm)')
    xlabel('Gait cycle(%)')
    
    axes(ha(first_moments_plot+1))
    plotShadedSD(mean(id.knee_angle,2),std(id.knee_angle,0,2),kinematics_color);
    xlabel('Gait cycle(%)')
    
    axes(ha(first_moments_plot+2))
    plotShadedSD(mean(id.ankle_angle,2),std(id.ankle_angle,0,2),kinematics_color);
    xlabel('Gait cycle(%)')
     
    tight_subplot_ticks(ha,LastRow,0)
    mmfn_inspect
    saveas(gcf,[savedir fp 'ExtBiomech_results_' l '.tiff'])
    close all
    %% plot muscle forces
    [ha, pos,FirstCol,LastRow,LastCol] = tight_subplotBG(length(muscles_of_interest),0,[0.01 0.02],[],[0.03 0.08]);
    
    last_plot_not_muscle = 0;
    Plot_colors = colorBG(0,length(penalties));
    for iMuscle = 1:length(muscles_of_interest)
        for iPen = 1:length(penalties)
            axes(ha(last_plot_not_muscle+iMuscle))

            MuscleName = muscles_of_interest{iMuscle};
            force_data = muscleForces.(['Pen_' penalties{iPen}]).(MuscleName);

            plotShadedSD(mean(force_data,2),std(force_data,0,2), Plot_colors(iPen,:));
           
            if any(iMuscle == FirstCol)
                ylabel('Muscle force (N)')
            end
            if any(iMuscle == LastRow)
                xlabel('Gait cycle(%)')
            end
        end
        ylim([0 max(ylim)*1.15])
        t = title(MuscleName,'Interpreter','none');
        t.Position(2) = t.Position(2) *0.92;
    end
    ax = gca;
    lg = legend(ax.Children(2:2:end),flip(penalties));
    lg.Interpreter = "none";
    lg.Position = [0.94 0.5 0.05 0.09];
    tight_subplot_ticks(ha,LastRow,0)

    mmfn_inspect
    saveas(gcf,[savedir fp 'MuscleForces_results_' l '.tiff'])

    %% plot contact forces
    [ha, pos,FirstCol,LastRow,LastCol] = tight_subplotBG(length(joints));
    last_plot_not_contact_force = 0;
    Plot_colors = colorBG(0,length(penalties));
    for iJoint = 1:length(joints)
        for iPen = 1:length(penalties)
            axes(ha(last_plot_not_contact_force+iJoint))

            JointName = joints{iJoint};
            force_data = contactForces.(['Pen_' penalties{iPen}]).(JointName);

            plotShadedSD(mean(force_data,2),std(force_data,0,2), Plot_colors(iPen,:));
            title(JointName,'Interpreter','none')
            if any(iJoint == FirstCol)
                ylabel('Contact force (N)')
            end
            if any(iJoint == LastRow)
                xlabel('Gait cycle(%)')
            end
        end
    end

    % appearance
    ax = gca;
    lg = legend(ax.Children(2:2:end),flip(penalties));
    lg.Interpreter = "none";

    tight_subplot_ticks(ha,LastRow,0)

    mmfn_inspect
    
    saveas(gcf,[savedir fp 'JCF_results_' l '.tiff'])



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
function [contactForces_data] = resulstant_JCF(contactForces_data,look_for_substrings,fs)

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
