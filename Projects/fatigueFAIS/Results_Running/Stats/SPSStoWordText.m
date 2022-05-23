%% Description - Basilio Goncalves (2019)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% After exporting the data from univariate analysis from SPSS to xlsx (multiple analyises
% possible) re arranged the data to a friendly word format
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS
%INPUT
%   chose by the user the xlsx file
%-------------------------------------------------------------------------
%OUTPUT
%  Table with the data for descriptive, estimated and pairwise comparisons
%--------------------------------------------------------------------------

%% SPSStoWordText
fld = fields(Table);
txt = sprintf('mean difference %.2f J/kg [95%%CI %.2f to %.2f], P=%.3f, ?p2=%.3f',0.22,0.33,0.33,0.33,0.33);

for ii = 1: size(fld,1)
    
    fldname = fld{ii};
    ss = size(Table.(fldname),1);
    
     str = sprintf('__________________________________________');
    txt(end+1,1:length(str)) = str;
    
    str = sprintf('%s',fldname);
    txt(end+1,1:length(str)) = str;

    for row = 2:ss
        
    MeanDiff = split(Table.(fldname){row,6},'(');
    CI = split(MeanDiff{2},',');
    LB = str2num(CI{1});
    UB = str2num(CI{2}(1:end-1));
    MeanDiff = str2num(MeanDiff{1});
    Pval = str2num(Table.(fld{1}){row,7});
    Eta = str2num(Table.(fld{1}){row,8});
    
    VariableName = Table.(fld{1}){row,1};
    txt(end+1,1:length(VariableName)) = VariableName;
    
    str = sprintf('mean difference %.2f%% [95%%CI %.2f to %.2f%%], P=%.3f, ?p2=%.3f',MeanDiff, LB, UB,Pval,Eta);
    txt(end+1,1:length(str)) = str;

    end
end

