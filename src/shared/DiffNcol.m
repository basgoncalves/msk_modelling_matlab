% diff of columns [1:N-1],[N+1:2*N],...

function [DiffData,SDdiff] = DiffNcol (data,N)

DiffData = [];
SDdiff =[];
data(data==0)=NaN;
for ii = 1:N:size(data,2)
    
   DiffData(:,end+1)= nanmean (data(:,ii:ii+N-1),2);
   SDdiff(:,end+1)= nanstd (data(:,ii:ii+N-1),0,2);
end

