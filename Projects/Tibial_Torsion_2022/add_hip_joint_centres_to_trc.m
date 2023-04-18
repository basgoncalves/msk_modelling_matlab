

function add_hip_joint_centres_to_trc(statictrcpath,setupScaleXml_template)
%Hip joint center computation according to Harrington et al J.Biomech 2006

trc             = load_trc_file(statictrcpath);
Rate            = 1/(trc.Time(2) - trc.Time(1));


[trc] = add_HJC_Harrington(trc);                                                                                    % add HJC based on Harrington equations

% plot_hjc_3D(trc)                                                                                                  % use to confirm the position of th HJC (uncomment if needed)

Labels_struct = fields(trc);
CompleteMarkersData = [];
for i = 1:length(Labels_struct)                                                                                     % convert trc struct into double (data) and cell (lables)
    field_data = trc.(Labels_struct{i});
    for col = 1:size(field_data,2)
        CompleteMarkersData(:,end+1) = field_data(:,col);                                                           
    end
end

FullFileName = strrep(statictrcpath,'.trc','_HJC.trc');
writetrc(CompleteMarkersData,Labels_struct(2:end),Rate,FullFileName)

%============================================================================================%
function plot_hjc_3D (trc)
    % trc should be a struct resulting from "load_trc_file(trcPath)" with
    % the fields RHJC, LHJC, RASI, LASI, SACR
    
    f = figure;
    hold on
    labels = {'RASI','LASI','SACR','RHJC','LHJC'};
    for iLab = 1:length(labels)
        point = trc.(labels{iLab})(1,:);
        scatter3(point(1), point(2), point(3), 'filled', 'MarkerFaceColor', 'r'); % RASI in red
        text(point(1)+0.05, point(2), point(3), labels{iLab} , 'Color', 'k', 'FontSize', 10); % RASI label
    end
   
%============================================================================================%
function [trc_markers] = add_HJC_Harrington(trc_markers)
%Hip joint center computation according to Harrington et al J.Biomech 2006
%
%PW: width of pelvis (distance among ASIS)
%PD: pelvis depth = distance between mid points joining PSIS and ASIS 
%All measures are in mm
%Harrington formula:
% x= -0.24 PD-9.9
% y= -0.30PW-10.9
% z=+0.33PW+7.3
%Developed by Zimi Sawacha <zimi.sawacha@dei.unipd.it>
%Modified by Claudio Pizzolato <claudio.pizzolato@griffithuni.edu.au>

%Renamd for convenience 
LASIS = trc_markers.LASI';   %after transposition: [3xtime]
RASIS = trc_markers.RASI';
SACRUM = trc_markers.SACR';

for t=1:size(RASIS,2)

    %Right-handed Pelvis reference system definition    
    %Global Pelvis Center position
    OP(:,t)=(LASIS(:,t)+RASIS(:,t))/2;    
    
    PROVV(:,t)=(RASIS(:,t)-SACRUM(:,t))/norm(RASIS(:,t)-SACRUM(:,t));  
    IB(:,t)=(RASIS(:,t)-LASIS(:,t))/norm(RASIS(:,t)-LASIS(:,t));    
    
    KB(:,t)=cross(IB(:,t),PROVV(:,t));                               
    KB(:,t)=KB(:,t)/norm(KB(:,t));
    
    JB(:,t)=cross(KB(:,t),IB(:,t));                               
    JB(:,t)=JB(:,t)/norm(JB(:,t));
    
    OB(:,t)=OP(:,t);
      
    %rotation+ traslation in homogeneous coordinates (4x4)
    pelvis(:,:,t)=[IB(:,t) JB(:,t) KB(:,t) OB(:,t);
                    0 0 0 1];
    
    %Trasformation into pelvis coordinate system (CS)
    OPB(:,t)=inv(pelvis(:,:,t))*[OB(:,t);1];    
       
    PW(t)=norm(RASIS(:,t)-LASIS(:,t));
    PD(t)=norm(SACRUM(:,t)-OP(:,t));
    
    %Harrington formulae (starting from pelvis center)
    diff_ap(t)=-0.24*PD(t)-9.9;
    diff_v(t)=-0.30*PW(t)-10.9;
    diff_ml(t)=0.33*PW(t)+7.3;
    
    %vector that must be subtract to OP to obtain hjc in pelvis CS
    vett_diff_pelvis_sx(:,t)=[-diff_ml(t);diff_ap(t);diff_v(t);1];
    vett_diff_pelvis_dx(:,t)=[diff_ml(t);diff_ap(t);diff_v(t);1];    
    
    %hjc in pelvis CS (4x4)
    rhjc_pelvis(:,t)=OPB(:,t)+vett_diff_pelvis_dx(:,t);  
    lhjc_pelvis(:,t)=OPB(:,t)+vett_diff_pelvis_sx(:,t);  
    
    %Transformation Local to Global
    RHJC(:,t)=pelvis(1:3,1:3,t)*[rhjc_pelvis(1:3,t)]+OB(:,t);
    LHJC(:,t)=pelvis(1:3,1:3,t)*[lhjc_pelvis(1:3,t)]+OB(:,t);
end

trc_markers.RHJC = RHJC';
trc_markers.LHJC = LHJC';

%============================================================================================%
function []= writetrc(markers,MLabels,VideoFrameRate,FullFileName)   
%
% The file is part of matlab MOtion data elaboration TOolbox for
% NeuroMusculoSkeletal applications (MOtoNMS). 
% Copyright (C) 2012-2014 Alice Mantoan, Monica Reggiani
%
% MOtoNMS is free software: you can redistribute it and/or modify it under 
% the terms of the GNU General Public License as published by the Free 
% Software Foundation, either version 3 of the License, or (at your option)
% any later version.
%
% Matlab MOtion data elaboration TOolbox for NeuroMusculoSkeletal applications
% is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
% without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
% PARTICULAR PURPOSE.  See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along 
% with MOtoNMS.  If not, see <http://www.gnu.org/licenses/>.
%
% Alice Mantoan, Monica Reggiani
% <ali.mantoan@gmail.com>, <monica.reggiani@gmail.com>
%
% Note: from an .m function developed by Thor Besier
% use the example_writetrc.mat and run:
% "writetrc(CompleteMarkersData,MarkersListjc{1}',Markers.Rate,FullFileName)"

%%

time=markers(:,1);
DataStartFrame=time(1)*VideoFrameRate+1;

%add frame column
frameArray=[(time(1)*VideoFrameRate+1):round(time(end)*VideoFrameRate+1)]';

markers=[frameArray markers];

nFrames=size(markers,1);
ncol=size(markers,2);
nMarkers=length(MLabels);

fid = fopen(FullFileName,'wt');
%fprintf('\n    --- Printing marker trajectory file ---    \n');

% Print header information
fprintf(fid,'PathFileType\t4\t(X/Y/Z)\t%s\n',FullFileName);
fprintf(fid,'DataRate\tCameraRate\tNumFrames\tNumMarkers\tUnits\tOrigDataRate\tDataStartFrame\n');
fprintf(fid, '%g\t%g\t%d\t%d\t%s\t%g\t%d\n', ...
    VideoFrameRate, VideoFrameRate, nFrames, nMarkers, 'mm', VideoFrameRate, DataStartFrame);
fprintf(fid,'Frame#\tTime');
for i = 1:nMarkers
    fprintf(fid,'\t%s\t\t%s',MLabels{i});
end
fprintf(fid,'\n\t\t');
for i = 1:nMarkers
    fprintf(fid,'X%d\tY%d\tZ%d\t',i,i,i);
end

fprintf(fid,'\n\n');

% Print data
for i= 1:nFrames
    for j=1:ncol
        if j == 1
            fprintf(fid,'%g\t',markers(i));
        else
            fprintf(fid,'%f\t',markers(i,j));
        end
    end
    fprintf(fid,'\n');
end

fclose(fid);

%============================================================================================%
function out = load_trc_file(filename)

% function data = load_trc_file(filename,delimiters)
%
% This function loads a TRC file and stores each X, Y, Z column in a field
% named after the marker the data is associated with (taken from header)
%
% Input: filename - the TRC filename
%
% Output: Stucture containing the data
%
% Author: Glen Lichtwark 
% Last Modified: 13/10/2015

if nargin < 1
    [fname, pname] = uigetfile('*.*', 'File to load - ');
    file = [pname fname];
else file = filename;    
end

[file_data,s_data]= readtext(file, '\t', '', '', 'empty2NaN');

% Replace all occurrences of 'nan' with NaN
file_data(strcmp(file_data, 'nan')) = {[NaN]};
file_data(cellfun(@isempty, file_data)) = {[NaN]};

% search the numerical data (in s_data.numberMask) to find when the block
% of data starts
a = find(abs(diff(sum(s_data.numberMask,2)))>0);
[m,n] = size(file_data);
% create an array with all of the data
num_dat = [file_data{a(end)+1:end,1:sum(s_data.numberMask(a(end)+1,:),2)}];
% reshape to put back into columns and rows
data = reshape(num_dat,m-a(end),sum(s_data.numberMask(a(end)+1,:),2));

% look at the labels (row 4) and go through and assign data to the label

% first find which cells have labels
c = find(s_data.stringMask(4,:)>0);
out = struct;
% now loop through all labels, create a new field name with the new label 
% name and assign the data from that column to the column of the next label 
for i = 1:length(c)
    fname = file_data{4,c(i)};
    try 
        out.(fname) = [];
    catch
        continue
    end

    if ~isempty(strfind(fname,'#'))
        fname(strfind(fname,'#')) = [];
    end

    if c(i) > size(data,2)
        break
    elseif i<length(c)
        out.(fname) = data(:,c(i):c(i+1)-1);
    else 
        out.(fname) = data(:,c(i):size(data,2));
    end
end

%====================================== END =================================================%
