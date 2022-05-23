function [fcut_coordinates, inputTrials, IKresultsDir, varargout] = MAinput(trialsList, varargin)
% Function asking input for MA 

% This file is part of Batch OpenSim Processing Scripts (BOPS).
% Copyright (C) 2015 Alice Mantoan, Monica Reggiani
% 
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
% 
%     http://www.apache.org/licenses/LICENSE-2.0
% 
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
%
% Alice Mantoan, Monica Reggiani
% <ali.mantoan@gmail.com>, <monica.reggiani@gmail.com>


%%

%Definition of lowpass frequency cut off for filtering coordinates
% num_lines = 1;
% options.Resize='on';
% options.WindowStyle='modal';
% defValue{1}='6';
% 
% dlg_title='Choose the low-pass cut-off frequency for filtering the coordinates_file data ';
% prompt ='lowpass_cutoff_frequency_for_coordinates (-1 disable filtering)';
% 
% answer = inputdlg(prompt,dlg_title,num_lines,defValue,options);
% 
% fcut_coordinates=str2num(answer{1});

fcut_coordinates=6;

%OPTIONAL:
if nargout>1
    
    %Selection of trials to elaborate from the list   
    [trialsIndex,v] = listdlg('PromptString','Select trials to elaborate:',...
        'SelectionMode','multiple',...
        'ListString',trialsList);
    
    inputTrials=trialsList(trialsIndex);
    
    %Get folder with Inverse Kinematics results to use for MA
    if nargout == 3           
        IKresultsDir = uigetdir(' ', 'Select folder with INVERSE KINEMATICS results to use');
    end
 
end   

