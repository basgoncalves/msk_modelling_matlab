%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Add the muslce force data to the StOpt file to ensure the confiration is
% similar. Also removes the torque acutators
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS (check if they are in the path)
%   xml_read
%   
%INPUT
%   PlotMuscles = 1 (yes) or 0 (no)
%-------------------------------------------------------------------------
%OUTPUT
%

function resultsDir = CombineSOandCEINMS(CEINMSdir,osimFiles,PlotMuscles)

fp = filesep;
[~,TrialName] = DirUp(osimFiles.emg,2);

SO = load_sto_file(SOdir);
       
CEINMS_mforces = load_sto_file([CEINMSdir fp 'MuscleForces.sto']);
CEINMS_torques = load_sto_file([CEINMSdir fp 'Torques.sto']);
IK = load_sto_file(osimFiles.IKresults);
ID = load_sto_file(osimFiles.IDresults);
% find the indexes of times that match in both SO and CEINMS
T = find(ismember(round(CEINMS_mforces.time,3),round(IK.time,3)));
fld = fields(CEINMS_mforces);

ForceData = struct;
ForceData.time = CEINMS_mforces.time(T);
% add CEINMS muscles to the force file 
for i = 2:length(fld) % start from 2 not to include time
    muscle = fld{i};
    if PlotMuscles == 1
        figure
        hold on
        plot (SO.(muscle))
        plot (CEINMS_mforces.(muscle)(T))
        legend('SO','CEINMS')
        title(muscle)
        ylabel('Muscle Force(N)')
        ax = gca;
        ax.Position = [0.2 0.11 0.7 0.8];
        mmfn
        saveas(gcf,[muscle '.jpeg'])
        close all
    end
    ForceData.(muscle) = CEINMS_mforces.(muscle)(T);
    
end


% ActNames = getModelActuators(model_file);
ActNames = {'lumbar_ext','lumbar_bend','lumbar_rot',...
    'shoulder_flex_r','shoulder_add_r','shoulder_rot_r',...
    'elbow_flex_r','pro_sup_r','wrist_flex_r','wrist_dev_r',...
    'shoulder_flex_l','shoulder_add_l','shoulder_rot_l',...
    'elbow_flex_l','pro_sup_l','wrist_flex_l','wrist_dev_l'};
IDflds = fields(ID);

for i = 1:length(ActNames)
    
    idx = find(contains(IDflds,ActNames{i})); % field ID
    
    ForceData.(Reserves{i})(T,1) = 0;
end




% make reserve actuators = 0
Reserves = {'FX';'FY';'FZ';'MX';'MY';'MZ';...
    'hip_flexion_r_reserve';'hip_adduction_r_reserve';'hip_rotation_r_reserve';...
    'knee_angle_r_reserve';'ankle_angle_r_reserve';...
    'hip_flexion_l_reserve';'hip_adduction_l_reserve';'hip_rotation_l_reserve';...
    'knee_angle_l_reserve';'ankle_angle_l_reserve'};

Reserves = fields(ID);
idx = find(contains(Reserves,{'time'})); 
Reserves(idx) = [];
fld = fields(CEINMS_torques);
for i = 1:length(Reserves)
    
    if sum(contains(fields(CEINMS_torques),strrep(Reserves{i},'_moment','')))>0
        idx = find(contains(fields(CEINMS_torques),strrep(Reserves{i},'_moment','')));
        Reserve = ID.(Reserves{i})(T,:) - CEINMS_torques.(fld{idx})(T,:);
        ForceData.(strrep(Reserves{i},'_moment','_reserve')) = Reserve;
    else
        ForceData.(strrep(Reserves{i},'_moment','_reserve'))(T,1) = 0;
    end
    
end

% write new STO
resultsDir = [fileparts(SOdir) fp 'forcefile_CEINMS.sto'];
write_sto_file_SO(ForceData, resultsDir)
% SO2 = load_sto_file(resultsDir);

