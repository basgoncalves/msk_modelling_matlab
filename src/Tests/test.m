model2 = Model(dirModel);
for imusc = 1: model2.getMuscles().getSize()
    musc_name =  model2.getMuscles().get(imusc-1).getName();
    
    if model.updForceSet().getSize() > model.getCoordinateSet().getSize()                                           % remove previous added muscle
        model.updForceSet().remove(model.getCoordinateSet().getSize());
    end
    disp(char(musc_name))
    model.updForceSet().append(model2.getMuscles().get(musc_name));
    %     model.initSystem();
    JR.setForcesFileName([dirSO, char(musc_name), '.sto']);
    
    %         runJRA_F1(analysis,model,dirModel,musc_name,JR,leg,dirSO)
end


for imusc = 1: 10000
    JR
end

model2 = Model(dirModel);
for imusc = 1:model2.getMuscles().getSize()
    musc_name =  model2.getMuscles().get(imusc-1).getName();
    JR.setForcesFileName([dirSO, char(musc_name), '.sto']);
    JR
end