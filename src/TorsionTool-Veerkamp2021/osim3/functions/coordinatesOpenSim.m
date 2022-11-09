%-------------------------------------------------------------------------%
% Copyright (c) 2021 % Kirsten Veerkamp, Hans Kainz, Bryce A. Killen,     %
%    Hulda Jónasdóttir, Marjolein M. van der Krogt      		          %
%                                                                         %
% Licensed under the Apache License, Version 2.0 (the "License");         %
% you may not use this file except in compliance with the License.        %
% You may obtain a copy of the License at                                 %
% http://www.apache.org/licenses/LICENSE-2.0.                             %
%                                                                         % 
% Unless required by applicable law or agreed to in writing, software     %
% distributed under the License is distributed on an "AS IS" BASIS,       %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         %
% implied. See the License for the specific language governing            %
% permissions and limitations under the License.                          %
%                                                                         %
%    Authors: Hulda Jónasdóttir & Kirsten Veerkamp                        %
%                            February 2021                                %
%    email:    k.veerkamp@amsterdamumc.nl                                 % 
% ----------------------------------------------------------------------- %
% The vertices for the bone are rotated back to fit the coordinate system
% in Opensim
% --------------------------------------------------------------------

function [output]=coordinatesOpenSim(input)
Rx = [1 0 0; 0 cos(-pi/2) -sin(-pi/2); 0 sin(-pi/2) cos(-pi/2)];
Rzz = [cos(pi/2) -sin(pi/2) 0; sin(pi/2) cos(pi/2) 0; 0 0 1];

R = Rx* Rzz;
output = (R*input')';
