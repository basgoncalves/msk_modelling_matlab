for imusc = 1: 10000
    if mod(imusc,10) == 0
        disp(imusc)
    end
    
    model2 = Model(dirModel);
    
    
    if model.updForceSet().getSize() > model.getCoordinateSet().getSize()                                           % remove previous added muscle
        model.updForceSet().remove(model.getCoordinateSet().getSize());
    end
    disp(musc_name)
    model.updForceSet().append(model2.getMuscles().get(musc_name));
    
end