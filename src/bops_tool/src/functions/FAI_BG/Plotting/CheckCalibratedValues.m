%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Compare all iterations of CEINMS exe and check best RMSE with torque
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS (check if they are in the path)
%   GCOS
%   LoadResults_BG
%
%INPUT
%   DirCalibratedModel = [char] directory of the your ceinms calibrated
%   model
%   e.g. = 'E:\3-PhD\Data\MocapData\ElaboratedData\007\pre\ceinms\calibration\calibrated\calibratedSubject.xml'
%--------------------------------------------------------------------------
% NOTE - you may need to change the names of the motions and muslces
%% CheckCalibratedValues


function CheckCalibratedValues(DirCalibratedModel,DirUncalibratedModel,side)

fp = filesep;

XML_cal = xml_read (DirCalibratedModel);
XML_uncal = xml_read (DirUncalibratedModel);

% divide by muscle groups
s= lower(side);
MGroups = struct;
MGroups.ADD = {['addbrev_' s],['addlong_' s],['addmagDist_' s],['addmagIsch_' s],['addmagMid_' s],...
['addmagProx_' s],['grac_' s]};
MGroups.HMS = {['bflh_' s],['bfsh_' s],['semimem_' s],['semiten_' s]};
MGroups.GLU = {['glmax1_' s],['glmax2_' s],['glmax3_' s],['glmed1_' s],['glmed2_' s],['glmed3_' s],...
['glmin1_' s],['glmin2_' s],['glmin3_' s]};
MGroups.HFL = {['iliacus_' s],['psoas_' s],['recfem_' s],['sart_' s],['tfl_' s]};
MGroups.VAS = {['vasint_' s],['vaslat_' s],['vasmed_' s]};
MGroups.ANK = {['gaslat_' s],['gasmed_' s],['soleus_' s],['tibant_' s],['tibpost_' s]};

Param = struct('ShapeFact',struct,'ActScale',struct,'optFibL',struct,'PenAng',struct,...
    'TendSlackLen',struct,'MaxConVel',struct,'MaxIsomForce',struct,'StrCoef',struct) ;
for P = fields(Param)'
    Param.(P{1}).ADD=[]; Param.(P{1}).HMS = []; Param.(P{1}).GLU = [];
    Param.(P{1}).HFL = []; Param.(P{1}).VAS = []; Param.(P{1}).ANK = [];
    Param.(P{1}).OTHER = [];
end

lb = struct;
lb.ADD ={}; lb.HMS ={}; lb.GLU ={}; lb.HFL ={}; lb.VAS ={}; lb.ANK ={}; lb.OTHER ={};
for k = 1: length({XML_cal.mtuSet.mtu.strengthCoefficient})
     labels{k} = XML_cal.mtuSet.mtu(k).name;
     for m = fields(MGroups)'
         if contains(labels{k},MGroups.(m{1}))
            f = m{1}; 
            break
         elseif contains(m{1},'ANK')
             f = 'OTHER';
             break
         end
     end

     Param.ShapeFact.(f)(end+1) = 1-XML_uncal.mtuSet.mtu(k).shapeFactor/ XML_cal.mtuSet.mtu(k).shapeFactor ;
     Param.ActScale.(f)(end+1) = XML_cal.mtuSet.mtu(k).activationScale;
     Param.optFibL.(f)(end+1) = 1-XML_uncal.mtuSet.mtu(k).optimalFibreLength/XML_cal.mtuSet.mtu(k).optimalFibreLength;
     Param.PenAng.(f)(end+1) = 1-XML_uncal.mtuSet.mtu(k).pennationAngle / XML_cal.mtuSet.mtu(k).pennationAngle.CONTENT;
     Param.TendSlackLen.(f)(end+1) = 1-XML_uncal.mtuSet.mtu(k).tendonSlackLength / XML_cal.mtuSet.mtu(k).tendonSlackLength;
     Param.MaxConVel.(f)(end+1) = XML_cal.mtuSet.mtu(k).maxContractionVelocity;
     Param.MaxIsomForce.(f)(end+1) = 1-XML_uncal.mtuSet.mtu(k).maxIsometricForce / XML_cal.mtuSet.mtu(k).maxIsometricForce;
     Param.StrCoef.(f)(end+1) = XML_cal.mtuSet.mtu(k).strengthCoefficient;

     lb.(f){end+1} = XML_cal.mtuSet.mtu(k).name;
end   
    

 TT={'shapeFactor' 'activationScale' 'optimalFibreLength' 'pennationAngle'...
     'tendonSlackLength' 'maxContractionVelocity' 'maxIsometricForce' 'StrengthCoeficients'};
c = 0;
for P = fields(Param)'
    c = c+1;
    figure
    hold on
    mmfn
    F = fields(Param.(P{1}));
    for k = 1:length(F)
        subplot(3,3,k)
        bar(Param.(P{1}).(F{k}))
        xticklabels(lb.(F{k}))
        xtickangle(45)
        mmfn
        ax = gca;
        ax.FontSize = 15;
        ax.Position(4) =  ax.Position(4)*0.7;
        title(F{k})
        
    end
    suptitle(TT{c})
    cd(fileparts(DirCalibratedModel))
    saveas(gcf,[TT{c} '.jpeg'])
end

disp(['figures saved at ' fileparts(DirCalibratedModel)])
close all