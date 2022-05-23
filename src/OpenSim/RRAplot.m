% RRAplot

% example:
% File_pre = 'C:\Code\MATLAB\ExmpleMocapData\ElaboratedData\012\pre\inverseKinematics\Run_baselineA1\IK.mot'
% File_post = 'C:\Code\MATLAB\ExampleMocapData\ElaboratedData\012\pre\residualReductionAnalysis\Run_baselineA1\Run_baselineA1.mot'
% RRAplot(File_pre,File_post)
function RRAplot(File_pre,File_post)


% load IK before RRA
IK = LoadResults_BG (File_pre,[],[],[],1);
% load IK RRA
RRA = LoadResults_BG (File_post,[],[],[],1);



tight_subplotBG(3,3,[],[],[],0.95)
plot(IK)
plot(RRA)
legend ('IK', 'RRA')



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