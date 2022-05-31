
function runJRA_F1(analysis,model,dirModel,musc_name,JR,leg,dirSO)
import org.opensim.modeling.*
model2 = Model(dirModel);
if contains(char(musc_name),['_',leg]) && ~exist([dirSO, char(musc_name),'_InOnParentFrame_ReactionLoads.sto'],'file')
    % remove previous added muscle
    if model.updForceSet().getSize() > model.getCoordinateSet().getSize()
        model.updForceSet().remove(model.getCoordinateSet().getSize());
    end
    disp(char(musc_name))
    model.updForceSet().append(model2.getMuscles().get(musc_name));
%     model.initSystem();
    
    JR.setForcesFileName([dirSO, char(musc_name), '.sto']);
    
%     model.addAnalysis(JR)
    model.updAnalysisSet().adoptAndAppend(JR);
%     model.initSystem();
    
    analysis.setName(char(musc_name));
    analysis.setModel(model);
    memoryCheck('update',musc_name)
    analysis.run();
    memoryCheck('update',musc_name)
end

clear function