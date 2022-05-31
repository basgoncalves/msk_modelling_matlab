import org.opensim.modeling.*
dirModel = 'C:\Users\Bas\Documents\3-PhD\MocapData\ElaboratedData\015\pre\015_Rajagopal2015_FAI_originalMass_opt_N10_hans.osim';
dirIK = 'C:\Users\Bas\Documents\3-PhD\MocapData\ElaboratedData\015\pre\InverseKinematics\Run_baseline1\IK.mot';
model = Model(dirModel);

motstorage = Storage(dirIK);


imusc = 1;

for i =  1:100
    
    model2 = Model(dirModel);
    musc_name =  model2.getMuscles().get(imusc-1).getName();
    model.updForceSet().remove(model.getCoordinateSet().getSize());
    disp(char(musc_name))
    
    model.updForceSet().append(model2.getMuscles().get(musc_name));
%     model.initSystem();
    
    JR.setForcesFileName([dirSO, char(musc_name), '.sto']);
    
    model.addAnalysis(JR)
%     model.updAnalysisSet().adoptAndAppend(JR);
%     model.initSystem();
    disp(i)
    
end



for imusc = 11: 20 %  model2.getMuscles().getSize()
    musc_name =  model2.getMuscles().get(imusc-1).getName();
    memoryCheck('update',musc_name)
    if ~isequal(muscles_of_interest,'all') && ~contains(char(musc_name),muscles_of_interest)
        continue
    end
    runJRA_F1(analysis,model,dirModel,musc_name,JR,leg,dirSO)
end
memoryCheck('plot')

% from https://simtk.org/tracker/index.php?func=detail&aid=1998&group_id=91&atid=322
for istep = 1:10000
    import org.opensim.modeling.*
    Mod = Model('E:\3-PhD\Data\MocapData\ElaboratedData\009\pre\009_Rajagopal2015_FAI_originalMass_opt_N10_hans.osim');
    state = Mod.initSystem();
    
    CoordSet = Mod.getCoordinateSet;
    currentDof = CoordSet.get(2);
    
    currentDof.setValue(state,0,1);
    
end




% https://www.simtk.com/tracker/index.php?func=detail&aid=3141&group_id=91&atid=322

import org.opensim.modeling.*;

% Inspect a model.

model = Model(dirModel);

model.updForceSet().remove(model.getCoordinateSet().getSize());

bodyList = model.getBodySet(); % Get the Model's BodyList
i = 0;
iter = ; % Start the iterator at the beginning of the list
while i~=(bodyList.getSize()) % Stay in the loop until the iterator reaches the end of the list
    iter.getName() % Print name to console
    iter = bodyList.get(i); % Move the iterator to the next body in the list
    i = i+1;
end