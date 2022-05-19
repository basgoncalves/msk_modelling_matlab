%% Description
% Goncalves, BM (2019)
%   Difference between each pair of trials
%
%
%-------------------------------------------------------------------------
%OUTPUT
%   TorqueDataAll = struct with the torque values for each subject for each
%   condition
%   description 
%%
function TestDiff = multiTestDif (TotalData)

data = TotalData;


[Y,X]= size(data);
TestDiff=[];
for ii = 1:2:X
    data1 = data(:,ii);
    data2 = data(:,ii+1);
    TestDiff (:,ii) = (data1 - data2)./ data1 * 100;
end

for ii = fliplr(2:2:X-1)
    TestDiff (:,ii)=[];
end