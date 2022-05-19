%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Setup and run induced acceleration analysis 
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS (check if they are in the path)
%   
%   
%INPUT
%   forcefiledir = directory of the mot file containing the external ground
%   rection forces to apply during Induced Acceleration Analysis
%   
%   AcqXML = acquisition XML from MOTONMS pipeline
%   GRFxml = ground reaction force XML used for IK, ID, IAA,...
%-------------------------------------------------------------------------
%OUTPUT
%

function [outDir,S,finalTime] = deleteForceIAA(forcefiledir,AcqXML,GRFxml,outDir)

fp = filesep;
S = load_sto_file(forcefiledir);
[~,TrialName]=fileparts(forcefiledir);

%find leg tested
if contains( AcqXML.Subject.Leg,'R')
    Leg ='Right';
else
    Leg='Left';
end

% find forceplates contacted
NumID = regexp(TrialName,'\d');
TType = TrialName(1:NumID-1);
TNumber = TrialName(NumID); % get the number of the trial
T = find(contains({AcqXML.Trials.Trial.Type},TType));
T2 = find([AcqXML.Trials.Trial(T).RepetitionNumber]==str2num(TNumber));
FP = find(contains({AcqXML.Trials.Trial(T(T2)).StancesOnForcePlatforms.StanceOnFP.leg},Leg));

fld = fields(S);
finalTime =[];
for i = 2:length(fld) % start from 2 not to count field "time"
   if contains(fld{i},'torque')
         n=  str2num(fld{i}(14));
   else
         n=  str2num(fld{i}(13));
   end
  
    if isempty(find(n==FP)) 
        S = rmfield(S,fld{i});
    else 
        idx = find(S.(fld{i}));
        if ~isempty(idx)
            finalTime = max([finalTime S.time(idx(end))]);
        end
    end 
end

% delete Forces and torques from xml file 
XML =  xml_read(GRFxml);

% loop through the external forces in the XML file 
for i = flip(1:length(XML.ExternalLoads.objects.ExternalForce))
    n = str2num(XML.ExternalLoads.objects.ExternalForce(i).force_identifier(end-2));
     if isempty(find(n==FP))
        XML.ExternalLoads.objects.ExternalForce(i)=[];
     else 
         
     end
end
root = 'OpenSimDocument'; % setting for saving XML files
Pref.StructItem = false;
xml_write(GRFxml, XML, root,Pref);

% write new Mot file 
write_sto_file(S, outDir);
