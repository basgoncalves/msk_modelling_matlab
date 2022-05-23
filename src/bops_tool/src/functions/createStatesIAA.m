% create a states.sto ready to be used by the induced acceeleration analaysis 
% plugin from 
% This states file must include segment positions (degrees), segment velocities(deg/sec)
% activations(0-1) and fibre length 


function [States,colheaders] = createStatesIAA (DirRRA, DirMA, DirStOpt, DirCEINMS_exe, TrialName)

fp = filesep;
States = load_sto_file([DirRRA fp TrialName '_states.sto']);
Length_CEINMS = load_sto_file([DirCEINMS_exe fp 'simulations' fp TrialName fp 'FibreLengths.sto']);
Activation_CEINMS = load_sto_file([DirCEINMS_exe fp 'simulations' fp TrialName fp 'Activations.sto']);
Length_MA = load_sto_file([DirMA fp TrialName fp '_MuscleAnalysis_FiberLength.sto']);
Activation_StOpt = load_sto_file([DirStOpt fp TrialName fp '_StaticOptimization_activation.sto']);


% common frames indexes between Activations and 'States'
[~,frames]=intersect(round(States.time,3),Activation_CEINMS.time);  

% make States the same length as activations
flds = fields(States);
for k = 1:length(flds)
    fname = flds{k};
    States.(fname) = States.(fname)(frames);
    colheaders{k} = fname;
end

% make Length (muscle analysis) same length as activations(CEINMS)
flds = fields(Length_MA);
for k = 1:length(flds)
    fname = flds{k};
    Length_MA.(fname) = Length_MA.(fname)(frames);
end

% make activations (StOpt)same length as activations(CEINMS)
flds = fields(Activation_StOpt);
for k = 1:length(flds)
    fname = flds{k};
    Activation_StOpt.(fname) = Activation_StOpt.(fname)(frames);
end



% add activations and lengths to the states struct
flds = fields(Activation_CEINMS);

if contains(flds{2}(end),'r')
    CL = 'l'; % contralateral leg
else 
    CL = 'r';
end

for k = 2:length(flds)
    fname = flds{k};
    States.([fname '_activation']) = Activation_CEINMS.(fname);
    colheaders{end+1}= [fname '.activation'];
    States.([fname '_fiber_length']) = Length_CEINMS.(fname);
    colheaders{end+1}= [fname '.fiber_length'];    
end

% add length data for the contralateral leg 
flds = fields(Length_MA);
for k = 1:length(flds)
    fname = flds{k};
    if contains(fname(end),CL)
        States.([fname '_fiber_length']) = Length_MA.(fname);
        colheaders{end+1}= [fname '.fiber_length'];    
    end
end


% add length data for the contralateral leg 
flds = fields(Activation_StOpt);
for k = 1:length(flds)
    fname = flds{k};
    if contains(fname(end),CL)
        States.([fname '_activation']) = Activation_StOpt.(fname);
        colheaders{end+1}= [fname '.activation'];    
    end
end

% add obt_internus_r1 from StOpt and MA
fname = 'obt_internus_r1';
States.([fname '_fiber_length']) = Length_MA.(fname);
colheaders{end+1}= [fname '.fiber_length'];
States.([fname '_activation']) = Activation_StOpt.(fname);
colheaders{end+1}= [fname '.activation'];
