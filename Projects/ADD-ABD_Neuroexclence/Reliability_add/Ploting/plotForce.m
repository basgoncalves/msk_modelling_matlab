%% Description
% Goncalves, BM (2019)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% this function filters and plots . 
% 
% INPUT
%   data = Columns vector with N rows
%   fs = sample frequency
%   TrialTitle 
%   Save = logical (0 or 1) to decide if 
%-------------------------------------------------------------------------
%OUTPUT
%   

function H = plotForce (data, fs, TrialTitle,Save)
if nargin ==1 
    fs = 2000;                                                             % standard sample size 
end

if nargin < 4 
    Save = 0;
end
%% Plot and save data graph for each subject
    
    H = figure ();
    plot (data);
    
    if nargin ==3 
        title (TrialTitle,'Interpret','None');
    end
    
    Nsamples = length (data);                                              % number of samples
    time = round(Nsamples/fs,2);                                           % time in sec = Number of samples / sample frequency
    
    xticks(0:Nsamples/5:Nsamples);                                         % devide the length of X axis in 5 equal parts (https://au.mathworks.com/help/matlab/creating_plots/change-tick-marks-and-tick-labels-of-graph-1.html)
    xticklabels(0:time/5:time);                                            % rename the X labels with the time in sec 
    xlabel ('Time (s)');
    ylabel ('Force / Torque (N or Nm)');
        
    
    
%% Save the file 

if Save == 1                                                               % if Save = 1 then save file
    filename = inputdlg...
        ('Type the name for the excel file or type nothing if you do not want to save' );
    if isempty (filename{1})~=1
        filename = sprintf ('%s.xlsx', filename{1});
        savefig (H,filename);                                              % save the force curve figure in the same folder
    end
end