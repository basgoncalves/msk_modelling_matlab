
function MaxTorqueMuscles(Dir,CEINMSSettings,trialName)

fp = filesep;
%check if model has the force
warning off
import org.opensim.modeling.*
osimModel = Model(CEINMSSettings.osimModelFilename);
dofListCell = split(CEINMSSettings.dofList ,' ')';
[~,Subject] = DirUp(Dir.Input,2);
SubjectInfo = getDemographicsFAI(Dir.Main,Subject);
S = getOSIMVariablesFAI(SubjectInfo.TestedLeg,CEINMSSettings.osimModelFilename,dofListCell);
load([Dir.CEINMSsimulations fp trialName fp 'OptimalSettings.mat'])
BestCeinmsDir = OptimalSettings.Dir;

CalibratedSubject = xml_read(CEINMSSettings.outputSubjectFilename);
PF_default = [CalibratedSubject.mtuDefault.curve(2).xPoints'  CalibratedSubject.mtuDefault.curve(2).yPoints'];
FV_default = [CalibratedSubject.mtuDefault.curve(3).xPoints'  CalibratedSubject.mtuDefault.curve(3).yPoints'];
FL_default = [CalibratedSubject.mtuDefault.curve(1).xPoints'  CalibratedSubject.mtuDefault.curve(1).yPoints'];
TF_default = [CalibratedSubject.mtuDefault.curve(4).xPoints'  CalibratedSubject.mtuDefault.curve(4).yPoints'];

MAFiles = dir([[Dir.MA fp trialName] '\*' '_MomentArm_' '*']);
MaxTorque = struct;
[ha,~,FirstCol,~] = tight_subplotBG(1,length(dofListCell),0.1,0.2,0.05,[169 200 1666 666]);
for k = 1:length(dofListCell)
    currentDof = dofListCell{k};
    muscleList = getMusclesOnDof_BG(currentDof, osimModel);
    
    for M = flip(1:length(muscleList))
        idxMtu = find(strcmp({CalibratedSubject.mtuSet.mtu.name},muscleList{M}));
        if isempty(idxMtu)
            muscleList(M) =[];
        end
    end
    
    [ID_os,~] = LoadResults_BG ([Dir.ID fp trialName fp 'inverse_dynamics_rra.sto'],...
        [],S.moments(k),1,0);
    
    [NormFibreLengths,~] = LoadResults_BG ([BestCeinmsDir fp 'NormFibreLengths.sto'],...
        [],muscleList,0,0);
    
    [NormFibreVelocities,~] = LoadResults_BG ([BestCeinmsDir fp 'NormFibreVelocities.sto'],...
        [],muscleList,0,0);
    
    [PA,~] = LoadResults_BG ([BestCeinmsDir fp 'PennationAngles.sto'],...
        [],muscleList,0,0);
    
    idMomArm = find(contains({MAFiles.name},currentDof));
    MomArms = load_sto_file([MAFiles(1).folder fp MAFiles(idMomArm(1)).name]);
    CEINMSdata = load_sto_file([BestCeinmsDir fp 'PennationAngles.sto']); % just to get the time stamp
    MomArms.time=round(MomArms.time,4);
    CEINMSdata.time=round(CEINMSdata.time,4);
    T = find(ismember(round(MomArms.time,3),round(CEINMSdata.time,3)));
    
    for M = 1:length(muscleList)
        idxMtu = find(strcmp({CalibratedSubject.mtuSet.mtu.name},muscleList{M}));
        
        OriginalMaxIsomForce =  CalibratedSubject.mtuSet.mtu(idxMtu).maxIsometricForce;
        ForceCoefficiente = CalibratedSubject.mtuSet.mtu(idxMtu).strengthCoefficient;
        MaxIsomForce = OriginalMaxIsomForce*ForceCoefficiente;
        Fv = interp1(FV_default(:,1),FV_default(:,2),NormFibreVelocities(:,M));
        Fl = interp1(FL_default(:,1),FL_default(:,2),NormFibreLengths(:,M));
   
        NormPassiveForce(:,M) = interp1(PF_default(:,1),PF_default(:,2),NormFibreLengths(:,M));
    
        maxMTUforce = (Fv.*Fl.*1+NormPassiveForce(:,M)).*MaxIsomForce.*cos(PA(:,M));
        
        MaxTorque.(currentDof)(:,M) = MomArms.(muscleList{M})(T).*maxMTUforce;
    end
    axes(ha(k)); hold on;
    [Nrows,~] = size(MaxTorque.(currentDof));
    PositiveValues = MaxTorque.(currentDof)(:,sum(MaxTorque.(currentDof)>0)==Nrows);
    NegativeValues = MaxTorque.(currentDof)(:,sum(MaxTorque.(currentDof)<0)==Nrows);
    plot(sum(PositiveValues,2)./SubjectInfo.Weight);
    plot(sum(NegativeValues,2)./SubjectInfo.Weight);
    plot(ID_os./SubjectInfo.Weight)
    yticklabels(yticks);xticklabels(xticks);
    title(currentDof,'Interpreter','none')
    if any(k==FirstCol)
        lg = legend({'Sum of torques with Positive Mom Arm*' 'Negative Mom Arm*' 'Inverse Dynamics'});
        lg.Position = [0.23 0.86 0.16 0.12];
    end
    
    mmfn_inspect('% gait cycle','Torque (Nm/Kg)')
    
end

tt = text(0.5,0.5,'* individual muscle torque = [f(v)*F(l)*1 + NormPassiveForce].*MaxIsomForce.*cos(PA)');
tt.Units ='normalized';
tt.Position = [-3 -0.22 0];