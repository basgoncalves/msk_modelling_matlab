
% RelativeWork_Running

% groups of 3 columns (Hip, knee and ankle)
groups = 2:3:size(AbsJointWork,2); % start on 2 becase first column is the group column
RelWork = [G(:)];
RelWorkRM  = [J(:)];
for ii = 1:length(groups)-1
 idx = groups(ii):groups(ii+1)-1;
 TotW = sum(AbsJointWork(:,idx),2);
 RelWork= [RelWork AbsJointWork(:,idx)./TotW*100];

 for g = 1:Ngroups
    Sec = find(G(:)==g);
    RM = AbsJointWork(Sec,idx)./TotW(Sec)*100;
    RelWorkRM = [RelWorkRM RM(:)];                % relative work with repeated measures in different columns 
 end
end


RelWork = [RelWork Vel CTime];


StancePerc = (100- MeanRun.FootContacts);
StancePerc_sd = std(100- MeanRun.FootContacts);

Labels = {'RunningTrial' 'pfW_hip','pfW_knee','pfW_ankle','nfW_hip','nfW_knee','nfW_ankle','peW_hip','peW_knee','peW_ankle','neW_hip','neW_knee','neW_ankle',...
    'PosWork_hip','PosWork_knee','PosWork_ankle','NegWork_hip','NegWork_knee','NegWork_ankle','Velocity', 'ContactTime'};