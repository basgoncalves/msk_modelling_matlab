%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               MOtoNMS                                   %
%                MATLAB MOTION DATA ELABORATION TOOLBOX                   %
%                 FOR NEUROMUSCULOSKELETAL APPLICATIONS                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Starting program for Static Elaboration: run the interface for static.xml
% file creation

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
% Adapted by Basilio Goncalves 2022

%%

function []=StaticInterface_BOPS

bops = load_setup_bops;
subject = load_subject_settings;

staticXML               = xml_read(bops.directories.templates.Static);
staticXML.FolderName    = relativepath(subject.directories.Input,bops.directories.mainData);

staticTrials =subject.trials.staticTrials;
if iscell(staticTrials)
    staticXML.TrialName = subject.trials.staticTrials{1};
else
    staticXML.TrialName = subject.trials.staticTrials;
end

data = btk_loadc3d([subject.directories.Input fp staticXML.TrialName '.c3d']);
trc_markers = fields(data.marker_data.Markers);
staticXML.trcMarkers = join(trc_markers,' ');                                                                       % set-up marker set

Njoints = length(staticXML.JCcomputation.Joint);
updateTemplateXML = 0;
for i = 1:Njoints
    
    iJoint      = staticXML.JCcomputation.Joint(i).Name;
    method      = staticXML.JCcomputation.Joint(i).Method;
    OG_markers  = staticXML.JCcomputation.Joint(i).Input.MarkerNames.Marker;
    
    
    if any(~contains(OG_markers,trc_markers))
        [indx,~] = listdlg('PromptString',['select ' iJoint '-' method ' markers'],'ListString',trc_markers); 
        staticXML.JCcomputation.Joint(i).Input.MarkerNames.Marker = trc_markers(indx);
        updateTemplateXML = 1;
    end 
end

Pref.StructItem=false;
Pref.CellItem=false;
if updateTemplateXML == 1   
    xml_write(bops.directories.templates.Static,staticXML,'static',Pref);                                           % update template XML (in case the new markers were added) 
end

xml_write([subject.directories.staticXML],staticXML,'static',Pref);

disp('Static interface complete')

