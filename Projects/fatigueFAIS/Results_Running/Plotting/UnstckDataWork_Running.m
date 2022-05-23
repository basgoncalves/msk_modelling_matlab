
% UnstckDataWork_Running

PosWork=[];
NegWork=[];
Vel=[];
% loop through the groups in column one
for ii =1:size(G,2)
    Sec = find(G(:)==ii); %define a setion
    PosWork(1:length(J(:)),ii) = [PosWork_hip(Sec); PosWork_knee(Sec); PosWork_ankle(Sec)];
    NegWork(1:length(J(:)),ii) = [NegWork_hip(Sec); NegWork_knee(Sec); NegWork_ankle(Sec)];
end

Vel_RM = [MeanRun.MaxVel;MeanRun.MaxVel;MeanRun.MaxVel];
deltaVel = (Vel_RM(:,end)-Vel_RM(:,1))./Vel_RM(:,1)*100;

AbsWorkRM = [J(:) [pfW_hip; pfW_knee; pfW_ankle] [nfW_hip; nfW_knee;nfW_ankle] [peW_hip; peW_knee; peW_ankle] [neW_hip; neW_knee; nfW_ankle]...
    PosWork NegWork Vel_RM deltaVel];

RelWorkRM = [RelWorkRM Vel_RM deltaVel];
[RelWorkDiff,SDdiff] = DiffNcol (RelWorkRM(:,2:end-1),2);
LabelsRM = {'Joint','pfW_1','pfW_end','nfW_1','nfW_end','peW_1','peW_end','neW_1','neW_end','PosWork_1','PosWork_end','NegWork_1','NegWork_end',...
    'Velocity_1','Velocity_end','deltaVel'};


%unstack data 
UnStack = [];
UnSatackLabels ={};
N = max(RelWorkRM(:,1));
joints ={'hip','knee','ankle'};
for ii = 2:size(RelWorkRM,2)
    for c = 1:N
    rows = find(RelWorkRM(:,1)==c);
    UnStack = [UnStack RelWorkRM(rows, ii)];
    Y = sqrt((mod(ii,2)-2)^2); % 1 for odd 2 for even numbers
    Lab = [LabelsRM{ii} '_' joints{c}];
    UnSatackLabels =[UnSatackLabels Lab];
    end
    

end

[UnStackDiff,SDdiff] = DiffNcol (UnStack,2);