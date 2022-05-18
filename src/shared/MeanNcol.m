
% mean of columns [1:N-1],[N+1:2*N],...

function [MeanData,SDdata] = MeanNcol (data,N)

MeanData = [];
SDdata =[];
data(data==0)=NaN;
for ii = 1:N:size(data,2)
    
   MeanData(:,end+1)= nanmean (data(:,ii:ii+N-1),2);
   SDdata(:,end+1)= nanstd (data(:,ii:ii+N-1),0,2);
end

