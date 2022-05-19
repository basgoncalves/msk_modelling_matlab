%% Description - Basilio Goncalves (2020)
%
%Select folder that contains individual
% CALLBACK FUNTIONS
%   E:\MATLAB\DataProcessing-master\src\emgProcessing\Functions
%   ImportEMGc3d
%   GetMaxForce
%INPUT
%   data = [N*M Double] with the data being ploted
%   FootContact = [1*M Double] with the location of foot contact
%-------------------------------------------------------------------------
%NOTES
%   Function will
%--------------------------------------------------------------------------
function plotFootContact(data,FootContact)


lines={'k','--k',':k','.k','k','--k',':k','.k'};
if size(data,2) > 8
    lines = [lines lines];
    warning 'on'
    warning ('series number excedes 8 and some lines will have the same style')
end
% create vertical line for foot contact
for FC = 1:length(FootContact)
    Ymax = max(ylim);
    Ymin = min(ylim);
    serie = data(:,FC);
    Xpos = mean(FootContact(FC))*length(serie(~isnan(serie)))/100;
    plot ([Xpos Xpos],[Ymin Ymax],lines{FC})
end