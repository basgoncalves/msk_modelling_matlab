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

function [segment_mass,trials,bodyNames,MeanSegment_mass,original_mass] = adjustmodelmass_Average(dirRRA,in_model,out_model,TrialList)
%%
RRA_Log = {};
resid = [];
massAdj =[];
Adj =[];
for ii = flip(1:length(TrialList))                                                                                  % remove tirlas form the list that do not containkinematic results
    trialName = TrialList{ii};
    if ~isfile([dirRRA fp trialName fp trialName '_Kinematics_q.sto'])
        TrialList(ii)=[];
    end
end

for ii = 1:length(TrialList)
    trialName = TrialList{ii};
    m = []; % restrat m for each file (m = mass adjustmets for the whole body)
    OutLogDir = [dirRRA fp trialName fp 'out.log'];
    
    [m(:,end+1),residuals,~] = LoadResultsRRALog(OutLogDir);
    RRA_Log{ii} = OutLogDir;
    resid(:,ii) = residuals;
    Adj(:,ii) = m;
    
    %         if abs(m) > 4                                                                                        % remove large mass adjustments
    %             RRA_Log{ii} ={};
    %             resid(:,ii) = 0;
    %             continue
    %         end
    
    if ~isempty(m)                                                                                                  % add the mass to a variable with all the masses for each trial in each column
        massAdj(:,end+1) = m';
    end
end

scaleFactor = 1;
cd(dirRRA)

if abs(sum(sum(resid)))>0
    RRA_Log = RRA_Log(~cellfun(@isempty,RRA_Log));                                                                  % delete empty cells
    [segment_mass,trials,bodyNames,MeanSegment_mass,original_mass] = ...                                            % adjust model mass
        adjustmodelmass(scaleFactor,in_model,out_model);
else
    segment_mass= []; trials = {}; bodyNames = {}; MeanSegment_mass = []; original_mass = [];
    disp(' '); disp(['Mass adjustments  not performed - Residuals all above threshold'])
end

cd(dirRRA);
save Results segment_mass trials bodyNames MeanSegment_mass original_mass Adj

function adjustmodelmass(scaleFactor,RRA_Log, Model_In, Model_Out)
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

Model1 = Model(filepath);                                                                                           % Create the Original OpenSim model from a .osim file
Model1.initSystem;

Model2 = Model(Model1);                                                                                             % Create a copy of the original OpenSim model for the Modified Model
Model2.initSystem;

[~,filename] = fileparts(Model_Out);                                                                                % Rename the modified Model so that it comes up with a different name in the GUI navigator
Model2.setName(filename);

Muscles1 = Model1.getMuscles();                                                                                     % Get the set of muscles that are in the original model

nMuscles = Muscles1.getSize();                                                                                      % Count the muscles

disp(['Number of muscles in orginal model: ' num2str(nMuscles)]);

Muscles2 = Model2.getMuscles();                                                                                     % Get the set of forces that are in the scaled model (Should be the same as the original at this point.)

Bodies1 = Model1.getBodySet();                                                                                      % Get the set of bodies that are in the original model

nBodies = Bodies1.getSize();                                                                                        % Count the bodies
disp(['Number of bodies in orginal model: ' num2str(nBodies)]);

Bodies2 = Model2.getBodySet();                                                                                      % Get the set of bodies that are in the scaled model(Should be the same as the original at this point.)

for ii = 1:length(RRA_Log)                                                                                          % Read the adjusted mass suggestions from the RRA log file and read the pelvis width scale factor from the Scale log file
    
    if ~isempty(RRA_Log{ii})                                                                                        % check if the log file exists
        
        var = importdata(RRA_Log{ii}, '\t');
        if sum(contains(var,{'Final Average Residuals'}))>0                                                         % check if the log file contains the term 'Final Average Residuals'
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

for i = 0:nMuscles-1                                                                                                % loop through forces and scale muscle Fmax accordingly (index starts at 0)
    currentMuscle = Muscles1.get(i);                                                                                % get the muscle that the original muscle set points to read the muscle type and the max isometric force
    
    newMuscle = Muscles2.get(i);                                                                                    % define the muscle in the modified model for changing
    
    newMuscle.setMaxIsometricForce(currentMuscle.getMaxIsometricForce()*scaleFactor);                               % define the new muscle force by multiplying current muscle max force by the scale factor
end

% loop through bodies and scale body mass accordingly (index starts at 0)
for i = 0:nBodies-1
    
    currentBody = Bodies1.get(i);                                                                                   % get the body that the original body set points to read the body type and the body mass
    
    newBody = Bodies2.get(i);                                                                                       % define the body in the modified model for changing
    
    %newBody.setMass(currentBody.getMass()*scaleFactor);                                                            % define the new body mass by multiplying current body mass by the scale factor
    newBody.setMass(MeanSegment_mass(i+1)*scaleFactor);
    
end

Model2.print(fileoutpath);
disp(['The new model has been saved at ' fileoutpath]);

function [segment_mass,bodyNames,original_mass]=read_rra_mass(file)  % Function to read the RRA log

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