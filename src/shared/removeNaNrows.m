
function [out,RemovedIdx] = removeNaNrows (data, Dim)
RemovedIdx = [];
out = data;

if nargin < 2
    Dim = 1;
end

if Dim == 1
    for iRow = 1:size(out,Dim)
        if sum(isnan(out(iRow,:)))==length(out(iRow,:))
            RemovedIdx(end+1) = iCol;
        end

    end
    out(RemovedIdx,:)=[];

elseif Dim == 2
    for iCol = 1:size(out,Dim)
        if sum(isnan(out(:,iCol)))==length(out(:,iCol))
            RemovedIdx(end+1) = iCol;
        end
    end
    out(:,RemovedIdx)=[];

else
    error('Dim input varible must be 1 (rows) or 2 (cols)')
end


