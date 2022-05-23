
function [TestedLeg,CL,LongLeg,LongCL] = findLeg(DirElaborated,trialName)

fp = filesep;
DirMocap = DirUp(DirElaborated,3);
[~,Subject] = DirUp(DirElaborated,2);
%Acquisition Info: load acquisition.xml
SubjectInfo = getDemographicsFAI(DirMocap,Subject);

TestedLeg ={};
if contains(trialName,'run','IgnoreCase',1) && contains(trialName,'3')
    TestedLeg = {'L'};
elseif contains(trialName,'run','IgnoreCase',1) && contains(trialName,'2')
    TestedLeg = {'R'};
else
    TestedLeg{1} = SubjectInfo.TestedLeg;
end

% get contralateral leg and long name 
if contains(TestedLeg ,'L')
   LongLeg = {'Left'};
   CL = {'R'};
   LongCL = {'Right'};
else
   LongLeg = {'Right'};
   CL = {'L'};
   LongCL = {'Left'};
end
     