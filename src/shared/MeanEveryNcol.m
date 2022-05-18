

% mean of every N columns [1:N:end],[2:N:end],...[N:N:end]

function [MeanData,SDdata] = MeanEveryNcol (data,N)

MeanData = [];
SDdata =[];
data(data==0)=NaN;

 %  check if Number of coluns is devisable by N
   if size(data,2)/N ~= round(size(data,2)/N)
   error ('Number of columns should be devisable by N')  
   end

for ii = 1:N
   cols = ii:N:size(data,2);
   
  
   MeanData(:,end+1)= nanmean (data(:,cols),2);
   SDdata(:,end+1)= nanstd (data(:,cols),0,2);
end

