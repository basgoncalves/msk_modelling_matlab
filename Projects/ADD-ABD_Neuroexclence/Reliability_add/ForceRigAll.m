%% Description
% Goncalves, BM (2018)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% this script loops through all the folders subjects in one folder and
% calculates the maximum torque for each condition in each subject folder. 
% 
%
%--------------------------------------------------------------------------
% CALLBACK FUNCTIONS
%   ForceRig_butterworth (Goncalves, BM 2018)
%  
%--------------------------------------------------------------------------
% REFERENCES
%
% Weir, J. P. (2005). Quantifying Test-Rest Reliability Using the
% Intraclass Correlation Coefficient and the SEM.
% J Str Cond Res, 19(1), 231–240.
%
% Koo, T. K., & Li, M. Y. (2016). A Guideline of Selecting and
% Reporting Intraclass Correlation Coefficients for Reliability Research.
% Journal of Chiropractic Medicine, 15(2), 155–163.
%
% Field, A. Discovering Statistics Using SPSS (and sex and drugs and rock
% “n” roll).
% 3rd ed. SAGE Publications, Ltd, 2009.
%
% https://au.mathworks.com/matlabcentral/answers/159417-how-to-calculate-the-confidence-interval
%
% Atkinson, G., & Nevill, A. M. (1998). Statistical methods for assessing
% measurement error (reliability) in variables relevant to sports medicine.
% Sports Med, 26(4), 217-238

%% find the folder of the subject to analyse
clc
clear
fp = filesep;
% un commment below if needed
% convertToMat
% removeBiodexFoldersElaboration

MainFolder = 'E:\3-PhD\1-ReliabilityRig\Testing';
cd(MainFolder);
Files = dir;
Files (1:2) =[];
%% loop through all the subject folders
for n = 1:length (Files)                                       
% get the code of the subject and the directory of its folder
FileDir = [MainFolder fp Files(n).name];                                  % get the subject's code

if isfolder (FileDir)~=1                                    % if it is not a folder
    continue                                                % move to the next loop iteration    
end
% run the fucntion ForceRig 
TorqueDataAll = ForceRig_butterworth (FileDir);
% convertToCSV (FileDir)
end
%% Group final data 
[~,X]= size(TorqueDataAll.DataNoOffset);

TorqueDataAll.FinalData = [];
TorqueDataAll.FinalData(:,1:12) = TorqueDataAll.DataTorque(:,1:12);
TorqueDataAll.FinalData(:,13:X) = TorqueDataAll.DataNoOffset(:,13:X);
TorqueDataAll.FinalData(TorqueDataAll.FinalData==0) = NaN;

% add a space between every N cell amd add "_2" or "_1" after the name
A=TorqueDataAll.Labels;
N = 2;
nCol = size(A,N);

for ii = 1:N:nCol*2
   A = {A{1:ii}, sprintf('%s-2',A{ii}), A{ii+1:end}};
end
    
for ii = 1:N:nCol*2
   A{ii} =char({sprintf('%s-1',A{ii})});             % convert from cell to char each of the cells
end
TorqueDataAll.LabelsAll = A;

%% Validity set up (correct) 
[Y,X]= size(TorqueDataAll.FinalData);
TorqueDataAll.Validity = TorqueDataAll.FinalData;

for ii = 1:2:X
    TorqueDataAll.Validity(Y+1:Y+Y,ii) = TorqueDataAll.Validity(1:Y,ii+1);
end

TorqueDataAll.Validity(:,end-5:end) = [];          % delete the last 6 columns = combined task
[Y,X]= size(TorqueDataAll.Validity);

for ii = 2:2:X/2
    TorqueDataAll.Validity(:,ii) =  TorqueDataAll.Validity(:,ii+11);
    TorqueDataAll.Validity(:,ii+11)=0;
end
 TorqueDataAll.Validity(:,X/2+1:end)=[]; 
%% Labels Validity and add a space between every N cell amd add "_2" or "_1" after the name
TorqueDataAll.LabelsValidity = {'AB' 'AD' 'E' 'F' 'IR' 'ER'};
A=TorqueDataAll.LabelsValidity;

N = 2;
nCol = size(A,N);

for ii = 1:N:nCol*2
   A = {A{1:ii}, sprintf('%s-Rig',A{ii}), A{ii+1:end}};
end
    
for ii = 1:N:nCol*2
   A{ii} =char({sprintf('%s-Biodex',A{ii})});             % convert from cell to char each of the cells
end


TorqueDataAll.LabelsValidity = A;
 
 
save TorqueDataAll TorqueDataAll