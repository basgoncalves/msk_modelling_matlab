
function [MTUForce,PassiveForce,ActiveForce,MaxIsomForce,muscleList] = getCEINMSForces...
    (calibratedSubject,CEINMSdirectory,dofList,TimeWindow)

fp = filesep;

if ~exist('TimeWindow')
    TimeWindow=[];
end

cd(fileparts(calibratedSubject));CalibratedSubject = xml_read(calibratedSubject);
PF_default = [CalibratedSubject.mtuDefault.curve(2).xPoints'  CalibratedSubject.mtuDefault.curve(2).yPoints'];
FV_default = [CalibratedSubject.mtuDefault.curve(3).xPoints'  CalibratedSubject.mtuDefault.curve(3).yPoints'];
FL_default = [CalibratedSubject.mtuDefault.curve(1).xPoints'  CalibratedSubject.mtuDefault.curve(1).yPoints'];
TF_default = [CalibratedSubject.mtuDefault.curve(4).xPoints'  CalibratedSubject.mtuDefault.curve(4).yPoints'];

import org.opensim.modeling.*
osimModel = Model(CalibratedSubject.opensimModelFile);
muscleList = getMusclesOnDof_BG(dofList, osimModel);

for M = flip(1:length(muscleList))
    idxMtu = find(strcmp({CalibratedSubject.mtuSet.mtu.name},muscleList{M}));
    if isempty(idxMtu); muscleList(M) =[]; end
end

[MTUForce,~] = LoadResults_BG ([CEINMSdirectory fp 'MuscleForces.sto'],...
    TimeWindow,muscleList,0,0);

[Act,~] = LoadResults_BG ([CEINMSdirectory fp 'Activations.sto'],...
    TimeWindow,muscleList,0,0);

[NormFibreLengths,~] = LoadResults_BG ([CEINMSdirectory fp 'NormFibreLengths.sto'],...
    TimeWindow,muscleList,0,0);

[NormFibreVelocities,~] = LoadResults_BG ([CEINMSdirectory fp 'NormFibreVelocities.sto'],...
    TimeWindow,muscleList,0,0);

[PA,~] = LoadResults_BG ([CEINMSdirectory fp 'PennationAngles.sto'],...
    TimeWindow,muscleList,0,0);

[NormTendonLengths,~] = LoadResults_BG ([CEINMSdirectory fp 'NormTendonLengths.sto'],...
    TimeWindow,muscleList,0,0);




for M = 1:length(muscleList)
    idxMtu = find(strcmp({CalibratedSubject.mtuSet.mtu.name},muscleList{M}));
    
    OriginalMaxIsomForce =  CalibratedSubject.mtuSet.mtu(idxMtu).maxIsometricForce;
    ForceCoefficiente = CalibratedSubject.mtuSet.mtu(idxMtu).strengthCoefficient;
    OptFibreLength = CalibratedSubject.mtuSet.mtu(idxMtu).optimalFibreLength;
    MaxIsomForce = OriginalMaxIsomForce*ForceCoefficiente;
        
%     FV_default = interp1(FV_default(:,1),FV_default(:,2),1:length(NormFibreVelocities))';
    Fv = interp1(FV_default(:,1),FV_default(:,2),NormFibreVelocities(:,M));
    Fl = interp1(FL_default(:,1),FL_default(:,2),NormFibreLengths(:,M));
    Ft = interp1(TF_default(:,1),TF_default(:,2),NormTendonLengths(:,M));
    
%     
%     [ha, ~,FirstCol, LastRow] = tight_subplotBG(1,3,0.1,0.15,0.05,[100 269 1600 420]);
%     axes(ha(1));plot(FV_default(:,1),FV_default(:,2)); title('Default F-V curve')
%     xlabel('Norm Velocity');ylabel('Norm Force')
%     axes(ha(2));plot(NormFibreVelocities(:,M),Fv); title('NormFibreVelocities')
%     axes(ha(3));plot(Fv); title('Force(v)');
%     
    NormPassiveForce(:,M) = interp1(PF_default(:,1),PF_default(:,2),NormFibreLengths(:,M));
    PassiveForce(:,M) = NormPassiveForce(:,M).*MaxIsomForce;
       
    MTUforeBAS = (Fv.*Fl.*Act(:,M)+NormPassiveForce(:,M)).*MaxIsomForce;
    ActiveForce(:,M) = (Fv.*Fl.*Act(:,M)+NormPassiveForce(:,M)).*MaxIsomForce.*cos(PA(:,M));
    TendonForce = ActiveForce;
    
%     ActiveForce = MTUForce(:,M)./cos(PA(:,M));
% figure
% hold on
% plot(MTUForce(:,M)./MaxIsomForce)
% plot(PassiveForce(:,M))
% plot(ActiveForce(:,M))
% plot(ActiveForce(:,M).*cos(PA(:,M)))
% legend('MTU','Passive','Active')
% % active force = (MTU force - Passive Force)
% ActiveForce = (MTUForce - PassiveForce)./cos(PA);
% 

end


