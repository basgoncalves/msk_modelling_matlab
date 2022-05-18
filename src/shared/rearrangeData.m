% find data Basilio Goncalves 2019
%
% INPUT
%   data = double
%   labels = cell 
%   trialNames = cell
%   MatchWholeWord = 1 for "yes" (default) or 2 for "no"; 

function OrganizedData = rearrangeData (data,Datalabels,LabelsOrder)

if contains(class(LabelsOrder),'char')
    LabelsOrder=cellstr(LabelsOrder);
elseif ~contains(class(LabelsOrder),'cell')
    error('trialNames should be of cell or char type')
end

if size (data,2) ~= size (Datalabels,2)
   error ('data and labels should have the same number of columns')
   return 
end

OrganizedData = zeros(1,length(LabelsOrder));
for ii = 1:length(Datalabels)
    
    col = find(contains(LabelsOrder,Datalabels{ii}));
    if ii >length(LabelsOrder) || isempty(col)
        break
    end
    
    OrganizedData(1:length(data(:,ii)),col)= data(:,ii);
    
end
OrganizedData(OrganizedData==0)=NaN;
