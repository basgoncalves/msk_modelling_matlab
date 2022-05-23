function stoFilesID=extractSTOfileContents(stoFiles)

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

stoFilesContents={ %SO
                  'activation' 
                  'force'       
                  %MA
                  'ActiveFiberForce'
                  'ActiveFiberForceAlongTendon'
                  'FiberActivePower'
                  'FiberForce'
                  'FiberLength'
                  'FiberPassivePower'
                  'FiberVelocity'
                  'Length'  
                  'Moment'
                  'MomentArm'
                  'MuscleActuatorPower'
                  'NormalizedFiberLength'
                  'NormFiberVelocity'
                  'PassiveFiberForce'
                  'PassiveFiberForceAlongTendon'
                  'PennationAngle'
                  'PennationAngularVelocity'
                  'TendonForce'
                  'TendonLength'
                  'TendonPower'
                  %CEINMS
                  'Activations'
                  'FiberLenghts' 
                  'FiberVelocities'
                  'MuscleForces'
                  'NormFiberLengths'
                  'NormFiberVelocities'
                  'PennationAngles'
                  'MeasuredExcitations'
                  };

nSTOfileContents=size(stoFilesContents,1);
nSTOfiles=size(stoFiles,2);

for k=1:nSTOfiles
    
    file=stoFiles{k};
    
    for i=1:nSTOfileContents
    
        index=strfind(file,stoFilesContents{i});
        
        if isempty(index)==0
            
            %stoFilesID{k}=stoFilesContents{i};
            stoFilesID{k}=file(index:end);
            stoFilesID{k}=regexprep(stoFilesID{k},'.sto','');
            
        end
    end
end

        