%% Description
% Goncalves, BM (2019)
% https://www.researchgate.net/profile/Basilio_Goncalves
%merge columns 
% CALLBACK FUNCIONS
%   ReliCal_plus (Goncalves, BM 2019) - Updated May 2019
%   MultiBlandAltman (Goncalves, BM 2019)
%   
%
% INPUT
%   data = NxM double matrix.
%               N =  number of particiants (rows)
%               M = number of overall trials (columns)
%               
%
%   groups = number of columns to group
%             
%                 
%-------------------------------------------------------------------------
%OUTPUT
%   groupdata

%% STRAT FUNCTION
function [groupdata,newlabels] = groupcol (data,labels,groups)

count =1;
groupdata=[];
for i =1:groups:length(data)
    groupdata(:,count)= [data(:,i) ; data(:,i+1)];
    count = count+1;
end

% delete data from labels 
newlabels = labels;
for i =flip(1:groups:length(data))
newlabels (i+1:i+groups-1) = [];
end
