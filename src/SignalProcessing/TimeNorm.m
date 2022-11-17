% time normalise axis
%
% Data = double matix 
% fs = samping frequency
%
%   TimeNormalizedData = time normalised data (from 1:101) for each column
%   in Data

function TimeNormalizedData = TimeNorm (Data,fs)

TimeNormalizedData=[];

for col = 1: size (Data,2)
    
    currentData = Data(:,col);
    currentData(isnan(currentData))=[];
    if length(currentData)<3
        TimeNormalizedData(1:101,col)= NaN;
        continue
    end
     
    timeTrial = 0:1/fs:size(currentData,1)/fs;
    timeTrial(end)=[];
    Tnorm = timeTrial(end)/101:timeTrial(end)/101:timeTrial(end);
    
    TimeNormalizedData(1:101,col)= interp1(timeTrial,currentData,Tnorm)';
end