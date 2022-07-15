function CEINMSData = clearBadData_JCFFAI(CEINMSData,trial)
%% clear bad data

% EMG
CEINMSData.MeasuredEMG.GL.(trial)(:,35)=NaN;

% Force
CEINMSData.MuscleForces.gaslat.(trial)(:,35)=NaN;
CEINMSData.MuscleForces.tibant.(trial)(:,35)=NaN;
% contact forces
CEINMSData.ContactForces.hip_x.(trial)(:,21)=NaN;
CEINMSData.ContactForces.hip_y.(trial)(:,21)=NaN;
CEINMSData.ContactForces.hip_z.(trial)(:,21)=NaN;
CEINMSData.ContactForces.hip_resultant.(trial)(:,21)=NaN;

CEINMSData.ContactForces.ankle_x.(trial)(:,35)=NaN;
CEINMSData.ContactForces.ankle_y.(trial)(:,35)=NaN;
CEINMSData.ContactForces.ankle_z.(trial)(:,35)=NaN;
CEINMSData.ContactForces.ankle_resultant.(trial)(:,35)=NaN;

% contributions
muscles = fields(CEINMSData.MuscleContributions_ap);

for imusc =1:length(muscles)
    CEINMSData.MuscleContributions_ap.(muscles{imusc}).(trial)(:,21)        = NaN;
	CEINMSData.MuscleContributions_vert.(muscles{imusc}).(trial)(:,21)      = NaN;
    CEINMSData.MuscleContributions_ml.(muscles{imusc}).(trial)(:,21)        = NaN;
    CEINMSData.MuscleContributions_resultant.(muscles{imusc}).(trial)(:,21) = NaN;
end
