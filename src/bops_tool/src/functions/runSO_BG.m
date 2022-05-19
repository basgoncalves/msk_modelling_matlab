function runSO_BG(Dir, Temp, trialName)
% Function to run SO for a single trial
%inputs:
%  model_file
%  coordinates_file
%  external_loads_file
%  results_directory
%  force_set_files (optional, but usually used)
%  XMLTemplate (used until problems with API will be solved)
%  lowpassfcut (optional)

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
fp = filesep;

import org.opensim.modeling.*

osimFiles = getosimfilesFAI(Dir,trialName); 
mkdir(osimFiles.SO)
osimFiles = getosimfilesFAI(Dir,trialName,osimFiles.SO); 
copyfile(Temp.SOActuators,osimFiles.SOactuators)
n = 150;
% adjustActuatorXML(ActuatorFile,hip,knee,ankle,lumbar,arm,elbow,pro,pelvis)
adjustActuatorXML(osimFiles.SOactuators,n,n,n,500,500,500,100,500)

SetupXML = xml_read(Temp.SOSetup);
%Set the model
SetupXML.AnalyzeTool.ATTRIBUTE.name = trialName;
SetupXML.AnalyzeTool.model_file = osimFiles.SOmodel;
SetupXML.AnalyzeTool.results_directory =  osimFiles.SO;
SetupXML.AnalyzeTool.coordinates_file = osimFiles.SOkinematics;
SetupXML.AnalyzeTool.external_loads_file =  osimFiles.SOexternal_loads_file;
SetupXML.AnalyzeTool.force_set_files = osimFiles.SOactuators;
% Get mot data to determine time range
motData = load_sto_file(osimFiles.SOkinematics);
SetupXML.AnalyzeTool.initial_time = motData.time(1);
SetupXML.AnalyzeTool.final_time = motData.time(end);
SetupXML.AnalyzeTool.output_precision = '4';

% filtering of coordinates
if nargin ==8
    SetupXML.AnalyzeTool.lowpass_cutoff_frequency_for_coordinates = (lowpassfcut);
elseif nargin<8 %else set the value in the XMLTemplate
    SetupXML.AnalyzeTool.lowpass_cutoff_frequency_for_coordinates = -1; %the default value is -1.0, so no filtering
end


root = 'OpenSimDocument';
Pref.StructItem = false;
xml_write(osimFiles.SOsetup, SetupXML, root,Pref);   % save setup xml
cd(osimFiles.SO)
dos(['analyze -S ',osimFiles.SOsetup]);                 % run static optimization tool in open sim 



