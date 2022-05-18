% swaps the first part of a vector with the last based on an index value
% e.g. input = [1 2 3 4 5]; SplitIdx = 3; Filter = 1 (yes) 0 (no); output = [3 4 5 1 2]

function output = SwapSections(input,SplitIdx,Filter,fs)
output=[];

for col = 1:size(input,2)
    NoNaNCol = input(:,col);
    NoNaNCol(~isnan(NoNaNCol));
    Nrows = length(NoNaNCol);
    
    
    
    S1 = NoNaNCol(1:SplitIdx(col));     % segment 1 (from 1 to cutoff)
    
    S2 = NoNaNCol(SplitIdx(col)+1:end); % segment 2 (from cutoff+1 to end)
    NoNaNCol (:) = NaN;
    NoNaNCol(end+1:end+length(S2))= S2;
    NoNaNCol(end+1:end+length(S1))= S1;
    NoNaNCol (isnan(NoNaNCol))=[];
    
    if exist('Filter') && Filter == 1
    %     filter force to remove artifacts
    Fnyq = fs/2;
    fcolow = 50;                                                                 % passband frequency
    
    [b,a] = butter(2,fcolow*1.25/Fnyq,'low');
    NoNaNCol = filtfilt(b,a,NoNaNCol);                                             % low pass filter;

    end
    output(1:length(NoNaNCol),end+1) = NoNaNCol;
end

output(output==0) = NaN;