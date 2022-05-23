%% Description - Goncalves, BM (2019)
%
% Create inverse dynamics xml for each trial
% Run after creating inverse kinematics
%
%--------------------------------------------------------------------------
function InverseDynamics_PostRRA (DirSetupID,model_file_rra)

fp = filesep;
setupXML = xml_read(DirSetupID);
setupXML.InverseDynamicsTool.model_file = model_file_rra;
[DirID,~] = fileparts(DirSetupID);

% % RRA kinematics
% RRAKinematics = [DirRRA fp trialName fp 'RRA' fp trialName '_Kinematics_q.sto'];
% setupXML.InverseDynamicsTool.coordinates_file = RRAKinematics;

outputfile = ['inverse_dynamics_RRA.sto'];
setupXML.InverseDynamicsTool.output_gen_force_file = outputfile;
IDxmlPath = [DirID fp 'setup_ID_rra.xml'];
copyfile([DirID fp 'out.log'],[DirID fp 'out_IK.log'])

root = 'OpenSimDocument'; Pref.StructItem = false;
xml_write(IDxmlPath, setupXML, root,Pref);
% run ID
import org.opensim.modeling.*
cd(fileparts(IDxmlPath))
[~,log_mes] = dos(['id -S ' IDxmlPath],'-echo');

disp(' ')
disp('New inverse dynamics');
disp([outputfile])
disp(' ')



