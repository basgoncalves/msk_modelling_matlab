% caclulate the difference between each pair of columns 

function TestDiff = orderDiff (data)
[~,X]= size(data);

for ii = 1:2:X
    data1 = data(:,ii);
    data2 = data(:,ii+1);
    TestDiff (:,ii) = (data2 - data1)./ data1 * 100;
end

for ii = fliplr(2:2:X-1)
    TestDiff (:,ii)=[];
end


GapBtwTrials = 6;
A= [];
[~, Ncol] = size (TestDiff);
currentTrial = 1; 
for ii = 1:2:Ncol/2
   A(ii) = currentTrial;
   A(ii+1) = currentTrial+GapBtwTrials;
   currentTrial= currentTrial+1;
end

GapBtwTrials = 6;
[~, Ncol] = size (TestDiff);
currentTrial = Ncol/2+1; 
for ii = Ncol/2+1:2:Ncol
   A(ii) = currentTrial;
   A(ii+1) = currentTrial+GapBtwTrials;
   currentTrial= currentTrial+1;
end


NewDescription = description (:,A);
TotalData = TestDiff (:,A);