function [MAid, MATemplateXml, IKresultsDir, fcut_coordinates, inputTrials, varargout] = JCFinput(trialsList, varargin)
% Function asking input for Joint Contact Analysis 
%
% Copyright (C) 2014 Hoa X. Hoang
% Hoa X. Hoang
% <hoa.hoang@griffithuni.edu.au> 

%%
%Get processing identifier 
dialogText = 'Select a processing identifier for the Muscle Analysis';
MAid = char(inputdlg(sprintf(dialogText)));

%Get template for the XML setup file
originalPath=pwd;
cd('..')
TemplatePath=[pwd filesep fullfile('Templates','MAProcessing') filesep];   
cd(originalPath)

[filename, pathname] = uigetfile([TemplatePath '*.xml'], 'Select Muscle Analysis template');

MATemplateXml = [pathname filename]; 

%Get folder with Inverse Kinematics results to use for Muscle Analysis
IKresultsDir = uigetdir(' ', 'Select folder with INVERSE KINEMATICS results to use');

num_lines = 1;
options.Resize='on';
options.WindowStyle='modal';
defValue{1}='6';

dlg_title='Choose the low-pass cut-off frequency for filtering the coordinates_file data ';
prompt ='lowpass_cutoff_frequency_for_coordinates (-1 disable filtering)';


answer = inputdlg(prompt,dlg_title,num_lines,defValue,options);

fcut_coordinates=str2num(answer{1});
    
%%Selection of trials to elaborate from the list
if nargin ==1
    [trialsIndex,v] = listdlg('PromptString','Select trials to elaborate:',...
        'SelectionMode','multiple',...
        'ListString',trialsList);
    
    inputTrials=trialsList(trialsIndex);
end
