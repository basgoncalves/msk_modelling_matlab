% S = getOSIMVariablesFAI(testedLeg)
% Creates a structure with the names of the variables to be used in the FAI
% project
% 
% OUTPUT
%   S = struct with all the varibale names and coordinates for the assigned dofs 

function S = getOSIMVariablesFAI(testedLeg,osimModelFilename,dofList)

fp = filesep;
warning off
CurrentDir = fileparts(mfilename('fullpath'));
if nargin==0
    testedLeg='R'; osimModelFilename=[CurrentDir fp 'Rajagopal2015_FAI.osim']; 
    RecordedEMG = {'        VM','        VL','        RF','       GRA','        TA','   ADDLONG','   SEMIMEM','      BFLH','        GM','        GL','       TFL','   GLUTMAX','   GLUTMED','      PIRI','    OBTINT','        QF'};
else
    DynamicElabfiles = dir([DirUp(osimModelFilename,1) fp 'dynamicElaborations' fp]);
    DynamicElabfiles = DynamicElabfiles([DynamicElabfiles.isdir]);
    DynamicElabfiles(1:2) = []; DynamicElabfiles(contains({DynamicElabfiles.name},'maxemg'))=[];
    EMGmot = importdata([DynamicElabfiles(3).folder fp DynamicElabfiles(3).name fp 'emg.mot']);
    RecordedEMG = EMGmot.colheaders(2:end);
end
    
s = lower(testedLeg); 

if ~exist('dofList')
    dofList = {['hip_flexion_' s];['hip_adduction_' s];['hip_rotation_' s];['knee_angle_' s];['ankle_angle_' s];};
end

S= struct;
S.RecordedEMG = RecordedEMG;

S.muscles_of_interest =  struct;
S.muscles_of_interest.Iliopsoas     = {['iliacus'],['psoas']};
S.muscles_of_interest.Hamstrings    = {['bflh'],['bfsh'],['semimem'],['semiten']};
S.muscles_of_interest.Gmax          = {['glmax1'],['glmax2'],['glmax3']};
S.muscles_of_interest.Gmed          = {['glmed1'],['glmed2'],['glmed3']};
S.muscles_of_interest.Gmin          = {['glmin1'],['glmin2'],['glmin3']};
S.muscles_of_interest.RecFem        = {['recfem']};
S.muscles_of_interest.TFL           = {['tfl']};
S.muscles_of_interest.Adductors     = {['addbrev'],['addlong'],['addmagDist'],['addmagIsch'],['addmagMid'],['addmagProx'],['grac']};
S.muscles_of_interest.Vasti         = {['vasint'],['vaslat'],['vasmed']};
S.muscles_of_interest.Gastroc       = {['gaslat'],['gasmed']};
S.muscles_of_interest.Soleus        = {['soleus']};
S.muscles_of_interest.Tibilais      = {['tibant']};

S.muscles_of_interest.All       ={['addbrev'],['addlong'],['addmagDist'],['addmagIsch'],['addmagMid'],['addmagProx'],...
    ['grac'],['bflh'],['semimem'],['semiten'],['glmax1'],['glmax2'],['glmax3'],['glmed1'],['glmed2'],['glmed3'],...
    ['glmin1'],['glmin2'],['glmin3'],['iliacus'],['psoas'],['recfem'],['sart'],['soleus'],['tfl'],['tibant'],['vasint'],['vaslat'],['vasmed']};

S.CEINMS_muscles = {['vasmed_' s];['vaslat_' s];['recfem_' s];['grac_' s];['tibant_' s];...
['addlong_' s];['semiten_' s];['bflh_' s];['gasmed_' s];['gaslat_' s];['tfl_' s];['glmax1_' s];['glmax2_' s];['glmax3_' s]};
% ST = stance; SW = swing; p = positive; n = negative; f = flexor; e = extensor;
S.workVariables = {'STpfW','STnfW','STpeW','STneW','SWpfW','SWnfW','SWpeW','SWneW'};
% AP = anterio-posterior | ML = medio lateral | V = vertical
S.grfVariables = {'AP' 'ML' 'V'}; 
% spatiotemporal variables
S.spatiotempVariables = {'Vmax' 'Amax' 'StepTime' 'ContactTime' 'PosVmax' 'StepLength' 'StepFreq'};

dofsimple = dofList;
dofsimple=strrep(dofsimple,'n_l','n');
dofsimple=strrep(dofsimple,'n_r','n');
dofsimple=strrep(dofsimple,'e_l','e');
S.dofsimple=strrep(dofsimple,'e_r','e');

S.coordinates = dofList;
S.moments = strcat(dofList,'_moment');

import org.opensim.modeling.*
S.DOFmuscles = struct;
S.AllMuscles = {};
S.Joints = {};
S.ContactForces = struct;
S.ContactForcesGenric = {};

osimModel = Model(osimModelFilename);
osimModel.initSystem();
idx = ~contains(dofList,{'pelvis' 'lumbar'});
dofList= dofList(idx);
for i=1:length(dofList)
    currentDofName = dofList{i};
    [S.DOFmuscles.(currentDofName),S.Joints(i)] = getMusclesOnDof_BG(currentDofName, osimModel);
    S.AllMuscles =  unique([S.AllMuscles S.DOFmuscles.(currentDofName)]);
    S.ContactForces.(dofList{i}) = {[S.Joints{i} '_x'] [S.Joints{i} '_y'] [S.Joints{i} '_z']};
    S.ContactForcesGenric = [S.ContactForcesGenric  [S.Joints{i} '_x'] [S.Joints{i} '_y'] [S.Joints{i} '_z']];
end
S.ContactForcesGenric = strrep(S.ContactForcesGenric,['_' s],'');

% dof directions (angles and internal moments)
S.DOFdirections = struct;
for i=1:length(dofList)
    
    if contains(dofList{i}, 'ankle_angle')
        S.DOFdirections.(dofList{i})= {'(-) plantar | dorsi (+)'};
    elseif contains(dofList{i}, 'knee_angle')
         S.DOFdirections.(dofList{i})= {'(-) ext | flex (+)'};
     elseif contains(dofList{i}, 'hip_flexion')
         S.DOFdirections.(dofList{i})= {'(-) ext | flex (+)'};  
    else 
         S.DOFdirections.(dofList{i})= {'(-) | (+)'};  
    end
end

