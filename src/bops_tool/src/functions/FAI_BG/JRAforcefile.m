%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Add the muslce force data to the StOpt file to ensure the confiration is
% similar. Also removes the torque acutators
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS (check if they are in the path)
%   xml_read
%   
%INPUT
%   PlotMuscles = 1 (yes) or 0 (no)
%-------------------------------------------------------------------------
%OUTPUT
%

function JRAforcefile(CEINMSdir,osimFiles,resultsDir)

fp = filesep;
      
CEINMS_mforces = load_sto_file([CEINMSdir fp 'MuscleForces.sto']);
CEINMS_torques = load_sto_file([CEINMSdir fp 'Torques.sto']);
SOresults = load_sto_file(osimFiles.SOforceResults);
IK = load_sto_file(osimFiles.IKresults);
ID = load_sto_file(osimFiles.IDRRAresults);
% find the indexes of times that match in both SO and CEINMS
CEINMS_mforces.time=round(CEINMS_mforces.time,4);
IK.time=round(IK.time,4);
T = find(ismember(round(CEINMS_mforces.time,3),round(IK.time,3)));

% % set all muscle forces to ZERO to investigate intersegmental forces.
% for i = 2:length(fld) % start from 2 not to include time
%     CEINMS_mforces.(fld{i})(:) = 0;
% end

% add CEINMS muscles to the force file 
ForceData = SOresults;
ForceData.time = CEINMS_mforces.time(T);
MusclesCEINMS = fields(CEINMS_mforces);
for i = 2:length(MusclesCEINMS) % start from 2 not to include time
    muscle = MusclesCEINMS{i};
    ForceData.(muscle) = CEINMS_mforces.(muscle)(T);
end

Reserves = fields(ForceData);
Reserves(contains(Reserves,MusclesCEINMS))=[];
idx = find(contains(Reserves,{'time'})); 
Reserves(idx) = [];
IDnames = strrep(fields(ID),'_moment','');
IDnames(contains(IDnames,'beta'))=[];
CEINMStorqueNames = fields(CEINMS_torques);
% [ha, ~,FirstCol, LastRow] = tight_subplotBG (length(Reserves),0,[0.03],[0.1 0.05],0.05,0);

for i = 1:length(Reserves)
    
    if contains(Reserves{i},IDnames)
        idx = find(contains(IDnames,strrep(Reserves{i},'_reserve','')));
        IDcurrent = ID.([IDnames{idx}  '_moment'])(T,:);
        
        if contains(Reserves{i},CEINMStorqueNames)
            idx = find(contains(CEINMStorqueNames,strrep(Reserves{i},'_reserve','')));
            CEINMScurrentTorque = CEINMS_torques.(CEINMStorqueNames{idx})(T,:);
            ForceData.(Reserves{i}) = IDcurrent - CEINMScurrentTorque;
        else      
            ForceData.(Reserves{i}) = IDcurrent;
        end
    elseif contains(Reserves{i},{'FX'})
        ForceData.(Reserves{i}) =  ID.pelvis_tx_force(T,:);
    elseif contains(Reserves{i},{'FY'})
        ForceData.(Reserves{i}) =  ID.pelvis_ty_force(T,:);
    elseif contains(Reserves{i},{'FZ'})
        ForceData.(Reserves{i}) =  ID.pelvis_tz_force(T,:);
        
    elseif contains(Reserves{i},{'MX'})
        ForceData.(Reserves{i}) =  ID.pelvis_list_moment(T,:);
    elseif contains(Reserves{i},{'MY'})
        ForceData.(Reserves{i}) =  ID.pelvis_rotation_moment(T,:);
    elseif contains(Reserves{i},{'MZ'})
        ForceData.(Reserves{i}) =  ID.pelvis_tilt_moment(T,:);
    else
        ForceData.(Reserves{i}) = zeros(length(T),1);
    end
%     
%     axes(ha(i)); hold on; plot(ForceData.(Reserves{i})); yticklabels(yticks); title(Reserves{i});
%     if contains(Reserves{i},IDnames)
%         plot(IDcurrent);
%     end
%     if contains(Reserves{i},CEINMStorqueNames)
%         plot(CEINMScurrentTorque);
%     end
%     
end

% write new STO
write_sto_file_SO(ForceData, resultsDir)
% SO2 = load_sto_file(resultsDir);

