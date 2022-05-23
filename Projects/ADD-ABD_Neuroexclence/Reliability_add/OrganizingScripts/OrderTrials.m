
subject = subject+1;
trialNames = {'R_E' 'R_F' 'R_AB' 'R_AD' 'R_ER' 'R_IR' ...
    'R_EER' 'R_EAB' 'R_EABER' ...
    'B_E' 'B_F' 'B_AB' 'B_AD' 'B_ER' 'B_IR'};                                             % vector combining labels for all the conditions
order(1,2:16) = trialNames;
for ii = 1: length(trialNames)
choice = menu('', trialNames);
trialNames{choice}=[];
order{subject, choice+1}  = ii; 
end


Tesdiff = TorqueDataAll.TestDiff_FinalData;
A=cell2mat(order(2:end,2:end));
Columns = 1:2:30;
for ii = 1: 15
    data1 = Tesdiff(:,ii);
    data2= A(:,ii);
    [RHO(ii),PVAL(ii)] = corr(data1,data2);
    corrOrder (:,Columns(ii):Columns(ii)+1)=[data1, data2]
end


clc
clear 