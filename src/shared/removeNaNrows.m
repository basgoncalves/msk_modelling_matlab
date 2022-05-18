
function [out,RemovedIdx] = removeNaNrows (data)
RemovedIdx = [];
out = data;
for ii = 1:size(out,1)
    
    if sum(isnan(out(ii,:)))==length(out(ii,:))
        RemovedIdx(end+1) = ii; 
    end
    
end

out(RemovedIdx,:)=[];
