% AbsoluteWork_Running
% calculate absolute work 

N = size(pfW_hip,1);
Ngroups = size(pfW_hip,2);
NJoints = 3;

% groups
G = zeros([size(pfW_hip)]);
for ii =1:size(G,2)
    G(:,ii)=ii;
end
% joints
J = zeros([size(pfW_hip)]);
for ii =1:3
    J(:,ii)=ii;
end


%running velocity 
Vel = MeanRun.MaxVel(:);
CTime =  MeanRun.ContacTime(:)*1000; %in ms

PosWork_hip = sum([pfW_hip(:) peW_hip(:)],2);
PosWork_knee = sum([pfW_knee(:) peW_knee(:)],2);
PosWork_ankle = sum([pfW_ankle(:) peW_ankle(:)],2);

NegWork_hip = sum([nfW_hip(:) neW_hip(:)],2);
NegWork_knee = sum([nfW_knee(:) neW_knee(:)],2);
NegWork_ankle = sum([nfW_ankle(:) neW_ankle(:)],2);

AbsJointWork=[];                         
AbsJointWork = [G(:) pfW_hip(:) pfW_knee(:) pfW_ankle(:) nfW_hip(:) nfW_knee(:) nfW_ankle(:) peW_hip(:) peW_knee(:) peW_ankle(:) neW_hip(:) neW_knee(:) neW_ankle(:)...
    PosWork_hip PosWork_knee PosWork_ankle NegWork_hip NegWork_knee NegWork_ankle Vel CTime];