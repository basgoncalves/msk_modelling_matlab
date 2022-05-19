%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               MOtoNMS                                   %
%                MATLAB MOTION DATA ELABORATION TOOLBOX                   %
%                 FOR NEUROMUSCULOSKELETAL APPLICATIONS                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ElaborationInterface.m

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
% Adapted Basilio Goncalves 2019

%%

function []=ElaborationInterface_BG(Dir,Fcut,MaxEMGTrials,DynamicTrials)

% addSharedPath()

%Comment the following line to disable the splashscreen
%runSplashScreen
runTerminalNote()

    
    
    %Trials Name
    c3dFiles = dir ([Dir.C3D filesep '*.c3d']);
    
    %Name correction/check
    for k=1:length(c3dFiles)
        trialsName{k} = regexprep(regexprep((regexprep(c3dFiles(k).name, ' ' , '')), '-',''), '.c3d', '');
    end
    
    %Acquisition Info: load acquisition.xml
    acquisitionInfo=xml_read([Dir.C3D filesep 'acquisition.xml']);
    
   
    
    
    
sprintf ('New elaboration.xml creates in \n %s',ElaborationFilePath)






