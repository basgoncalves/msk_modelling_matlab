
function runJRA_F1(analysis,model,dirModel,musc_name,JR,leg,dirSO)
import org.opensim.modeling.*
model.addAnalysis(JR)
model.updAnalysisSet().adoptAndAppend(JR);
%     model.initSystem();

analysis.setName(char(musc_name));
analysis.setModel(model);
memoryCheck('update',musc_name)
analysis.run();

java.lang.System.gc()