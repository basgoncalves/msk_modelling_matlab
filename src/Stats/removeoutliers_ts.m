%Function to remove outliers Andres Schmidt, RWTH 2017
% % 'data'    gives the respective vector that holds the data
% 
% % 'factor1' determines the maximum factor of the standard deviation 
% %           in the moving window
% 
% % 'step'    gives the width of the moving average window. For analysing the 
% %           deviation of a value at point i the values of i-step trough 
% %           i+step are respected
% 
% % 'factor2' determines the maximum factor of the standard deviation with 
% %           respect to the complete series
% 
% % 'laps'    gives the number of loops i.e. determines how often the data
% %           should be corrected. After each loop the descriptive statistics 
% %           are adapted to the series which is the result of the previous loop
% 
% % 'MWF'     with (1) or without(0) moving window filter
% %           
% 
% % 'rplAVG'  with (1) or without(0) replacing outlier with average
% %
% %
% % if window is activated value will be replaced by window average
% % if window is not activated(0) then value will be replaced with time series average;
% % call like e.g.:   ps_data(:,x)=removeoutliers(ps_data(:,x),3,6,3,1,0,0);
function [clean_data]   =   removeoutliers_ts(data,factor1,step,factor2,laps,MWF,rplAVG)
clear inp
inp=data;
for z=1:laps
   if MWF==1    
        for ii=step+1:length(inp)-step-1
            cstest=(inp(ii-step:ii+step,:));
            devCSmax=nanmean(cstest)+factor1*nanstd(cstest);
            devCSmin=nanmean(cstest)-factor1*nanstd(cstest);
            for j=1:size(inp,2)
             if rplAVG==1
               if inp(ii,j)>devCSmax(:,j) || inp(ii,j)<devCSmin(:,j), inp(ii,j)=nanmean(cstest); end  
             else
               if inp(ii,j)>devCSmax(:,j) || inp(ii,j)<devCSmin(:,j), inp(ii,j)=NaN; end
             end
            end         
         end
    else   
       devCSmax=nanmean(inp)+factor2*nanstd(inp);
       devCSmin=nanmean(inp)-factor2*nanstd(inp);
        for j=1:size(inp,2)
               if rplAVG==1
                inp(find(inp(:,j)>devCSmax(j)),j)=nanmean(inp);
                inp(find(inp(:,j)<devCSmin(j)),j)=nanmean(inp);
               else 
                inp(find(inp(:,j)>devCSmax(j)),j)=NaN;
                inp(find(inp(:,j)<devCSmin(j)),j)=NaN;
              end
        end
   end
end
clean_data=[]; 
clean_data=inp;  
 
