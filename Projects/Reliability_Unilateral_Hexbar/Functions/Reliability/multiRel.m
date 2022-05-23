%% Description
% Goncalves, BM (2019)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% this funtion calculates used the fucntion "ReliCal" to calculate 
% reliability parameters for every pair of trials. 
%   EXAMPLE:
%           Trial 1 VS Trial 2 | Trial 3 vs Trial 4 |.... 
% 
%
%
% CALLBACK FUNCIONS
%   ReliCal_plus (Goncalves, BM 2019) - Updated May 2019
%   MultiBlandAltman (Goncalves, BM 2019)
%   
%
% INPUT
%   TotalData = NxM double matrix.
%               N =  number of particiants (rows)
%               M = number of overall trials (columns)
%               TotalData =[];
%
%   description = 1xC Cell vector Cell =
%                 C = number of conditions 
%                 description = {};
%-------------------------------------------------------------------------
%OUTPUT
%   Rel = cell arrary with ICC, SEM, CV, MDC, heteroscedasticity and Bias values
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
%% STRAT FUNCTION
function Rel = multiRel (TotalData,description,Type)

[~,Ntrials] = size (TotalData);

%% Use to compare each X columns - NOTE: columns to be compared should have the exact same name followed by "-Number", e.g. jump-1, jump-2, jump-3

Dash = strfind(description,'-');                             % CHANGE if different charachter before number of trial e.g. "_"

if ~isempty(find(cellfun(@isempty,Dash), 1))                  % find if any of the names does not contatin a dash
 error('make sure all the trials names have are followed by ''-N''(e.g. AB-1, AB-2, ER-1, ER-2)') 
 return
end

NameTrial = description{1}(1:Dash{1}(end)-1);
NComparisons = 2;
Conditions = 1;

for ii = 1 :Ntrials
    PreviousTrial = NameTrial;
    Dash = strfind(description{ii},'-');
    NameTrial = description{ii}(1:Dash-1);
    if ii==Ntrials  &&  strcmp (PreviousTrial, NameTrial)==0                % if it's the last trial AND DIFFERENT name as before
        Conditions (NComparisons) = ii;
        NComparisons = NComparisons +1;
    elseif strcmp (PreviousTrial, NameTrial)==0                             % if it's DIFFERENT name than the previous one
        Conditions (NComparisons) = ii;
        NComparisons = NComparisons +1;
        
    end
    
end

Conditions (end+1) =  Ntrials+1;                                            % last condition +1 to get the last group of data 
%% Use to compare each 2 columns
% 
% NComparisons= 2;
% Conditions = 1:NComparisons:Ntrials;                                   

%%
data = TotalData (:,1:2);                                   %calculate example reliability to construct the length of the cell

Rel = {};
column = 2;

TotalData(TotalData==0) = NaN;

for ii = 2:length(Conditions)                                   % run through every group of same trials (e.g. 1-3 -> 4-5 ...) 

                                                                            
    data = TotalData (:,Conditions(ii-1):Conditions(ii)-1);
    
%     meanDiff(1:length(data),p) = data(:,2) - data(:,1);
%     BetweenDayMean(1:length(data),p) = (data(:,2) + data(:,1))/2;
    if exist('Type')
        Reliability = ReliCalc_plus (data,95,Type);                         %Temporal variable for reliability of each pair of trials 
    else 
        Reliability = ReliCalc_plus (data,95); 
    end
    

    [Rows1,~] = size (Reliability);                              % get number of rows as output from the ReliCal function
    [Rows2,~] = size(Rel);
    Rows = max(Rows1+1,Rows2);                                              % add one row. First row included the descrition 
    if Rows1+1 > Rows2
    Rel(2:Rows,1) = Reliability(1:end,1);
    end
    Rel(2:Rows1+1,column) = Reliability(1:end,2);
    Rel(1,column)= description(Conditions(ii-1));
    
    column = column+1;
end

%% All the Bland&Altman  plots
% MultiBlandAltman (TotalData,description)

% %% Save the file 
% 
% filename = inputdlg...
%     ('Type the name for the excel file or type nothing if you do not want to save' );
% if isempty (filename{1})~=1
% filename = sprintf ('%s.xlsx', filename{1});
% xlswrite(filename,Rel,1,'A1');
% end

