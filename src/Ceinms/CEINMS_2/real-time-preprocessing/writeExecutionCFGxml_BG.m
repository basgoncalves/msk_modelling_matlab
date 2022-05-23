% Copyright (C) 2014 Hoa X. Hoang
% Hoa X. Hoang <hoa.hoang@griffithuni.edu.au>
% PLEASE DO NOT REDISTRIBUTE WITHOUT PERMISSION
%__________________________________________________________________________
% write execution cfg file xml
% old script only copied the template, this function will read template and
% write out, this is useful for individually changing muscles and other settings
% Note the order of the field is important, will give error if out of order
% Todo:
%       -
function writeExecutionCFGxml_BG(nmsModel, cfgExeDir, fileOut, dofList,Adjusted,Synt)
%========default preferences==================================
fp = filesep;
prefDef.templateExXML = cfgExeDir;
prefDef.tendonType = 'equilibriumElastic'; %'stiff' 'integrationElastic'
prefDef.tendonTolerance = 0.000000001;
prefDef.activationType ='exponential'; %'piecewise'

%muscles being filled with static opt
prefDef.synthMTUs = Synt; 

% muscles being adjusted, leave blank if wanting to use emg inputs only
prefDef.adjustMTUs = Adjusted; 
			               		      
% values for assisted mode to adjust muscle excitation and torque tracking errors, see Sartori et al 2014
% best location might be to optimize it during calibration using the calibration trials
prefDef.alpha = 1; % alpha * MOMtracking error (sum of abs difference between predicted and exp), arbitrarily fixed at 1
prefDef.beta = 2; % beta * sum excitation square, don't use 0. 1 would be the same parameters as default opensim static opt
prefDef.gamma = 5; % gamma * EMGtracking error (sum of absolute differences between adjusted and experimental EMG-excitations)
%some might not be used as not using simulated annealing for execution in hybrid mode
prefDef.dofSet = dofList; % degrees of freedom for all the joints
prefDef.noEpsilon = 4;
prefDef.rt = 0.3;
prefDef.T = 20000;
prefDef.NS = 15;
prefDef.NT = 5;
prefDef.epsilon = 0.001;
prefDef.maxNoEval = 200000;

%Calibration File
prefXmlRead.Str2Num = 'never';
tree=xml_read(prefDef.templateExXML, prefXmlRead);

%% NMS model
%type
if strcmp(nmsModel, 'Hybrid') || strcmp(nmsModel, 'Assisted') || strcmp(nmsModel, 'StaticOpt')
    
    nmsModelType = 'hybrid'; %in case this changes in the future
    tree.NMSmodel.type.(nmsModelType) = struct; %xml_write will delete if empty matrix, so must be structure if wanting to keep
    tree.NMSmodel.type.(nmsModelType).alpha = num2str(prefDef.alpha);%hybrid & staticOpt = 1; assisted = 1
    tree.NMSmodel.type.(nmsModelType).beta = num2str(prefDef.beta);%hybrid & staticOpt = 1; assisted = 2 (varied from 0 to 300) shouldn't be set to 0 thought
    tree.NMSmodel.type.(nmsModelType).gamma = num2str(prefDef.gamma);%hybrid & staticOpt = 50; assisted = 50 (varied from o to 3000)
    tree.NMSmodel.type.(nmsModelType).dofSet = prefDef.dofSet;
    
    tree.NMSmodel.type.(nmsModelType).synthMTUs = prefDef.synthMTUs;% synthesizing missing EMGs
    tree.NMSmodel.type.(nmsModelType).adjustMTUs =  prefDef.adjustMTUs;% not adjusting any muscles, using emg iputs
    
    tree.NMSmodel.type.(nmsModelType).algorithm.simulatedAnnealing.noEpsilon = num2str(prefDef.noEpsilon);% %some might not be used as not using simulated annealing for execution in hybrid mode
    tree.NMSmodel.type.(nmsModelType).algorithm.simulatedAnnealing.rt = num2str(prefDef.rt);% most likely will be taken out in future versions
    tree.NMSmodel.type.(nmsModelType).algorithm.simulatedAnnealing.T = num2str(prefDef.T);%
    tree.NMSmodel.type.(nmsModelType).algorithm.simulatedAnnealing.NS = num2str(prefDef.NS);%
    tree.NMSmodel.type.(nmsModelType).algorithm.simulatedAnnealing.NT = num2str(prefDef.NT);%
    tree.NMSmodel.type.(nmsModelType).algorithm.simulatedAnnealing.epsilon = num2str(prefDef.epsilon);%
    tree.NMSmodel.type.(nmsModelType).algorithm.simulatedAnnealing.maxNoEval = num2str(prefDef.maxNoEval);%
elseif strcmp(nmsModel, 'Openloop')
    nmsModelType = 'openLoop';
    tree.NMSmodel.type.(nmsModelType) = struct;
else
    error('check nmsModelType (Hybrid, Assisted, StaticOpt, Openloop)')
end

% tendon
tree.NMSmodel.tendon.(prefDef.tendonType) = struct;
tree.NMSmodel.tendon.(prefDef.tendonType).tolerance = num2str(prefDef.tendonTolerance);

%activation
tree.NMSmodel.activation.(prefDef.activationType) = struct;

prefXmlWrite.StructItem = false;
prefXmlWrite.CellItem   = false;

xml_write(fileOut,tree,'execution',prefXmlWrite);
