
function [leftLeg,rightLeg] = find_gait_cycles(ikFilePath,grfFilePath)

% owndir = fileparts([mfilename('fullpath') '.m']);
% cd(fileparts(fileparts(owndir)))
% activate_msk_modelling

bodyKinematics_folder = [fileparts(ikFilePath) '\BodyKinematics'];

% run body kinematics
if  ~exist(bodyKinematics_folder)
    setupBodyKinematics = xml_read();

end

pos_file = dir([bodyKinematics_folder fp '*_BodyKinematics_pos_global*']);
body_kin = load_sto_file([pos_file.folder fp pos_file.name]);

grf_struct = load_sto_file(grfFilePath);
grf_fields = fields(grf_struct);
names_grf_y = grf_fields(contains(grf_fields,'force_vy'));
names_grf_px = grf_fields(contains(grf_fields,'force_px'));

time = grf_struct.time;
x_values = [1:length(time)]';

n_forceplates = length(names_grf_px);


rightLeg = [];
leftLeg = [];
for iPlate = 1:n_forceplates
    grf_vertical_force = grf_struct.(names_grf_y{iPlate})(x_values);
    grf_ap_pos = grf_struct.(names_grf_px{iPlate})(x_values);
    pos_left = body_kin.calcn_l_X(x_values);
    pos_right = body_kin.calcn_r_X(x_values);

    [leg,frames] = find_leg_for_each_contact(grf_vertical_force,grf_ap_pos,pos_left,pos_right); 
    rightLeg = [rightLeg; time(frames(contains(leg,'r')))];
    leftLeg = [leftLeg; time(frames(contains(leg,'l')))];
end

rightLeg = sort(rightLeg);
leftLeg = sort(leftLeg);

%-----------------------------------------------------------------------------------------------------%
function [contact_leg,frames_contacts,frames_off] = find_leg_for_each_contact(grf_vertical_force,grf_ap_pos,pos_left,pos_right)


if ~exist('threshold_force') || isempty(threshold_force)
    threshold_force = 1;
end

% find frames of intial contact with forceplate
initial_contacts = find(grf_vertical_force >= threshold_force);
in_contact = zeros(1,length(grf_vertical_force))';
in_contact (initial_contacts) = 1;

frames_contacts = [];
frames_off = [];
gaitCycles = [];
for i = 1:length(in_contact)-1
    if in_contact(i) == 0 && in_contact(i+1) == 1
        frames_contacts(end+1) = i+1;
    elseif in_contact(i) == 1 && in_contact(i+1) == 0
        frames_off(end+1) = i+1;
    end
end


% difference between GRF position and calc AP position
contact_leg = {};
for iContact = 1:length(frames_contacts)
    foot_contact_frame = frames_contacts(iContact);
    [~,idx] = min(abs(grf_ap_pos(foot_contact_frame) - [pos_left(foot_contact_frame) pos_right(foot_contact_frame)]));
    
    if idx == 1
        contact_leg{end+1} = 'l';
    else 
        contact_leg{end+1} = 'r';
    end

end