function muscle_contributions = MuscleContribution2HCF(dirIK,dirMC,dirExternalLoadsXML,dirModel,musc_name,setupXML)
import org.opensim.modeling.*

ik = load_sto_file(dirIK);
initial_time = round(ik.time(1),3);
final_time = round(ik.time(end),3);

results_directory = dirMC;

XML = xml_read(setupXML);
XML.AnalyzeTool.COMMENT = {};
XML.AnalyzeTool.ATTRIBUTE.name = musc_name; 
XML.AnalyzeTool.model_file = relativepath(dirModel,results_directory);
XML.AnalyzeTool.initial_time = num2str(initial_time);
XML.AnalyzeTool.final_time = num2str(final_time);
XML.AnalyzeTool.results_directory = relativepath(results_directory,results_directory);
XML.AnalyzeTool.external_loads_file = relativepath(dirExternalLoadsXML,results_directory);
XML.AnalyzeTool.coordinates_file = relativepath(dirIK,results_directory);
XML.AnalyzeTool.replace_force_set = 'false';

XML.AnalyzeTool.AnalysisSet.objects.JointReaction.COMMENT = {};
XML.AnalyzeTool.AnalysisSet.objects.JointReaction.ATTRIBUTE.name = 'InOnParentFrame';
XML.AnalyzeTool.AnalysisSet.objects.JointReaction.on = 'true';
XML.AnalyzeTool.AnalysisSet.objects.JointReaction.start_time = num2str(initial_time);
XML.AnalyzeTool.AnalysisSet.objects.JointReaction.end_time = num2str(final_time);
XML.AnalyzeTool.AnalysisSet.objects.JointReaction.step_interval = 1;
XML.AnalyzeTool.AnalysisSet.objects.JointReaction.in_degrees = 'true';
XML.AnalyzeTool.AnalysisSet.objects.JointReaction.forces_file = ['.\' musc_name '.sto'];
XML.AnalyzeTool.AnalysisSet.objects.JointReaction.joint_names = 'hip_r hip_l';
XML.AnalyzeTool.AnalysisSet.objects.JointReaction.apply_on_bodies = 'parent';
XML.AnalyzeTool.AnalysisSet.objects.JointReaction.express_in_frame = 'parent';

prefXmlWrite.Str2Num = 'never'; prefXmlWrite.StructItem = false; prefXmlWrite.CellItem = false;
setupXML = [dirMC 'setup_JRA.xml'];
xml_write(setupXML, XML, 'OpenSimDocument',prefXmlWrite);

cd(results_directory)
logFileOut=[results_directory fp 'out.log'];% Save the log file in a Log folder for each trial
dos(['analyze -S ' setupXML ' > ' logFileOut]);

if nargout > 0
    muscle_contributions = load_sto_file([dirMC char(musc_name) '_InOnParentFrame_ReactionLoads.sto']);
end
% JCF = load_sto_file(['C:\Users\Bas\Documents\3-PhD\MocapData\ElaboratedData\009\pre\JointReactionAnalysis\Run_baseline1\JCF_JointReaction_ReactionLoads.sto']);
% figure; hold on
% plot(muscle_contributions.hip_r_on_pelvis_in_pelvis_fx)
% plot(JCF.hip_r_on_pelvis_in_pelvis_fx)
% title(musc_name)
% legend('muscle contribution', 'total HCF')
% close all
