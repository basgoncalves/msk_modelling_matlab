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

try Plot_Individual_MuscleContributions;
catch e %e is an MException struct
    fprintf(1,'The identifier was:\n%s \n',e.identifier);
    fprintf(1,'There was an error! The message was:\n%s \n',e.message);
end

HCFx = HCF.Fx.(curr_musc)(:,subj_cols);
HCFy = HCF.Fy.(curr_musc)(:,subj_cols);
HCFz = HCF.Fz.(curr_musc)(:,subj_cols);

HCFres = sum3Dvector(HCFx,HCFy,HCFz);

h = tight_subplotBG(4,0)
axes(h(1)); plot(HCFx)
axes(h(2)); plot(HCFy)
axes(h(3)); plot(HCFz)
axes(h(4)); plot(HCFres)


HCFx = CEINMSData.(param).(variableList{3}).(trial)(:,cols);
HCFy = CEINMSData.(param).(variableList{2}).(trial)(:,cols)
HCFz = CEINMSData.(param).(variableList{4}).(trial)(:,cols)

HCFres = CEINMSData.(param).(variableList{1}).(trial)(:,cols)

h = tight_subplotBG(4,0)
axes(h(1)); plot(HCFx)
axes(h(2)); plot(HCFy)
axes(h(3)); plot(HCFz)
axes(h(4)); plot(HCFres)


variableList = {'hip_resultant' 'hip_y' 'hip_x' 'hip_z'};
trial = 'RunStraight1'
HCFx = CEINMSData.ContactForces.(variableList{3}).(trial)(:,sumHCF_subject_col);
HCFy = CEINMSData.ContactForces.(variableList{2}).(trial)(:,sumHCF_subject_col)
HCFz = CEINMSData.ContactForces.(variableList{4}).(trial)(:,sumHCF_subject_col)

HCFres = CEINMSData.ContactForces.(variableList{1}).(trial)(:,sumHCF_subject_col)

h = tight_subplotBG(4,0)
axes(h(1)); plot(HCFx)
axes(h(2)); plot(HCFy)
axes(h(3)); plot(HCFz)
axes(h(4)); plot(HCFres)

a={}
for i =1:2
    a{i} = datestr(now,'HH:MM:SS.FFF');
    pause(0.01)
end
a{1}==a{2}
