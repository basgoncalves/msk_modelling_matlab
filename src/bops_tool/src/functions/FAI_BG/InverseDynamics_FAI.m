%% Description - Goncalves, BM (2021)
% Create inverse dynamics xml and run ID OS for each trial
%  after creating inverse kinematics

function InverseDynamics_FAI(Dir, Temp, trialName,Logic)

% create directories
warning off
fp = filesep;
root = 'OpenSimDocument';
Pref.StructItem = false;

TimeWindow = TimeWindow_FatFAIS(Dir,trialName);
[TestedLeg,CL,LongLeg,LongCL]  = findLeg(Dir.Elaborated,trialName);

DirIDtrial = [Dir.ID fp trialName]; mkdir(DirIDtrial);
[osimFiles] = getosimfilesFAI(Dir,trialName,DirIDtrial); % also creates the directories
   
copyfile(osimFiles.coordinates,osimFiles.ID)
copyfile(osimFiles.externalforces,osimFiles.IDexternalforces)
copyfile(osimFiles.IKresults,osimFiles.ID)

%% set GRF xml
GRFxml = xml_read(Temp.GRF);
nForcePlates = length(GRFxml.ExternalLoads.objects.ExternalForce);
deleteForcePlates =[];

Acq = xml_read([Dir.Input fp 'acquisition.xml']);
[trialType,trialNumber] = getTrialType(trialName);
fld = find(strcmp({Acq.Trials.Trial.Type},trialType));
fld = find([Acq.Trials.Trial(fld).RepetitionNumber] == str2num(trialNumber))+fld(1)-1;
StanceOnFP = Acq.Trials.Trial(fld).StancesOnForcePlatforms.StanceOnFP;

for FP = 1:nForcePlates
    if contains(StanceOnFP(FP).leg,'-')
        deleteForcePlates (end+1) = FP;
        continue
    end
    GRFxml.ExternalLoads.objects.ExternalForce(FP).ATTRIBUTE.name = StanceOnFP(FP).leg;
    GRFxml.ExternalLoads.objects.ExternalForce(FP).applied_to_body =  ['calcn_' lower(StanceOnFP(FP).leg(1))];
end
GRFxml.ExternalLoads.objects.ExternalForce(deleteForcePlates)= [];
GRFxml.ExternalLoads.datafile = osimFiles.IDexternalforces;
GRFxml.ExternalLoads.external_loads_model_kinematics_file = osimFiles.IDcoordinates;

xml_write(osimFiles.IDgrfxml, GRFxml, root,Pref);

%% ID setup xml 
XML = xml_read(Temp.IDSetup);
XML.InverseDynamicsTool.COMMENT = {};
XML.InverseDynamicsTool.ATTRIBUTE.name = trialName;
XML.InverseDynamicsTool.results_directory = osimFiles.ID;
XML.InverseDynamicsTool.time_range = TimeWindow;
XML.InverseDynamicsTool.coordinates_file = osimFiles.IDcoordinates;
XML.InverseDynamicsTool.output_gen_force_file = osimFiles.IDresults;
XML.InverseDynamicsTool.model_file = osimFiles.LinearScaledModel;
XML.InverseDynamicsTool.external_loads_file = osimFiles.IDgrfxml;

xml_write(osimFiles.IDsetup, XML, root,Pref);

%% run ID
if Logic==2 && exist(osimFiles.IDresults); return; end
import org.opensim.modeling.*
[~,log_mes] = dos(['id -S ' osimFiles.IDsetup],'-echo');
disp([trialName ' ID Done.']);




