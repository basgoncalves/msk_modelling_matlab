% adjustmodelmass(scaleFactor, Model_In, Model_Out,RRA_Log)
%
% Inputs - scaleFactor (double) - amount to scale all muscle forces
%          Model_In (string) - existing model path and file name
%          Model_Out (string) - new model path and file name
%          RRA_Log = ['C:\Users\User\Desktop\OPENSIM_SCale_Test_BG\OPENSIM_SCale_Test\RRA\out.log'];
%          suggested mass adjustments
% ----------------------------------------------------------------------- %
% Adjust Model Mass
% This function will read in a model and a log file from RRA (or you can
% change to prescribe another file) and then add the new masses to the
% model and write out an amended model.
% You can also adjust the strength of the model should yuo wish using the
% scaleFactor.
% David Graham, Montana State University, 2020
% ----------------------------------------------------------------------- %
%
% BG added multiple RRA_Log and average those out

function [segment_mass,trials,bodyNames,MeanSegment_mass,original_mass] = adjustmodelmass_BG(scaleFactor,RRA_Log, Model_In, Model_Out)


import org.opensim.modeling.*

if nargin < 3
    [Model_In, path] = uigetfile('.osim');
    fileoutpath = [path Model_In(1:end-14),'_mass_adjusted.osim'];
    filepath = [path Model_In];
elseif nargin < 4
    fileoutpath = [Model_In(1:end-14),'_mass_adjusted.osim'];
    filepath = Model_In;
else
    filepath    = Model_In;
    fileoutpath = Model_Out;
end

%Create the Original OpenSim model from a .osim file
Model1 = Model(filepath);
Model1.initSystem;

% Create a copy of the original OpenSim model for the Modified Model
Model2 = Model(Model1);
Model2.initSystem;

% Rename the modified Model so that it comes up with a different name in
% the GUI navigator
[~,filename] = fileparts(Model_Out);
Model2.setName(filename);

% Get the set of muscles that are in the original model
Muscles1 = Model1.getMuscles();

%Count the muscles
nMuscles = Muscles1.getSize();

disp(['Number of muscles in orginal model: ' num2str(nMuscles)]);

% Get the set of forces that are in the scaled model
% (Should be the same as the original at this point.)
Muscles2 = Model2.getMuscles();

% Get the set of bodies that are in the original model
Bodies1 = Model1.getBodySet();

%Count the bodies
nBodies = Bodies1.getSize();
disp(['Number of bodies in orginal model: ' num2str(nBodies)]);

% Get the set of bodies that are in the scaled model
% (Should be the same as the original at this point.)
Bodies2 = Model2.getBodySet();

% Read the adjusted mass suggestions from the RRA log file
% and read the pelvis width scale factor from the Scale log file
for ii = 1:length(RRA_Log)
    
    % check if the log file exists
    if ~isempty(RRA_Log{ii})
        
        %check if the log file contains the term 'Final Average Residuals'
        var = importdata(RRA_Log{ii}, '\t');
        if sum(contains(var,{'Final Average Residuals'}))>0
            [segment_mass(:,ii), bodyNames(:,ii),original_mass(:,1)]= read_rra_mass(RRA_Log{ii});
            [~,trialName] = fileparts(fileparts(RRA_Log{ii}));
            trials{:,ii} = trialName;
        else 
           segment_mass(:,ii)=NaN;
           bodyNames(:,ii)=NaN;
           original_mass(:,1)=NaN;
        end
    end
end
MeanSegment_mass = nanmean(segment_mass,2);

%wrap_scale_factor = read_pelvis_scale(SCALE_Log);

% loop through forces and scale muscle Fmax accordingly (index starts at 0)
for i = 0:nMuscles-1
    
    %get the muscle that the original muscle set points to
    %to read the muscle type and the max isometric force
    currentMuscle = Muscles1.get(i);
    
    %define the muscle in the modified model for changing
    newMuscle = Muscles2.get(i);
    
    %define the new muscle force by multiplying current muscle max
    %force by the scale factor
    newMuscle.setMaxIsometricForce(currentMuscle.getMaxIsometricForce()*scaleFactor);
    
end

% loop through bodies and scale body mass accordingly (index starts at 0)
for i = 0:nBodies-1
    
    %get the body that the original body set points to
    %to read the body type and the body mass
    currentBody = Bodies1.get(i);
    
    %define the body in the modified model for changing
    newBody = Bodies2.get(i);
    
    %define the new body mass by multiplying current body mass
    %by the scale factor
    %newBody.setMass(currentBody.getMass()*scaleFactor);
    newBody.setMass(MeanSegment_mass(i+1));
    
end

Model2.print(fileoutpath);
disp(['The new model has been saved at ' fileoutpath]);

end

%% Function to read the RRA log

function [segment_mass,bodyNames,original_mass]=read_rra_mass(file)

% [file, pname] = uigetfile('*.log', 'Select C3D file');

var=importdata(file, '\t');
index = 1;

for i =1:length(var)
    if strfind(var{i},'new mass')
        ind1=find((var{i}==','), 1 );
        x=length(var{i});
        ind3=index;
        num(ind3,:)=str2num(var{i}(ind1+12:end));
        [segment_mass]=num;
        ind2 = split(var{i},'=');
        ind2 = split(ind2{2},',');
        num2(ind3,:)=str2num(ind2{1});
        [original_mass]=num2;
        body =  split(var{i},':');
        bodyNames(ind3,:)= body(1);
        index = index+1;
    end
end
end