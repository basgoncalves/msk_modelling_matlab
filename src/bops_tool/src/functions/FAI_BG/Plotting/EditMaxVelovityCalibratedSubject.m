%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS (check if they are in the path)
%
%INPUT
%   DirCalibratedModel = [char] directory of the your ceinms calibrated
%   model
%       e.g. = 'E:\3-PhD\Data\MocapData\ElaboratedData\subject\session\ceinms\execution\simulations'
%-------------------------------------------------------------------------
%OUTPUT
%
%--------------------------------------------------------------------------
% NOTE - you may need to change the names of the motions and muslces
%% EditCalibratedSubject

function EditMaxVelovityCalibratedSubject(DirCalibratedModel,ADD,HMS,GLU,HFL,VAS,ANK,OTHER)

fp = filesep;

XML = xml_read (DirCalibratedModel);

% divide by muscle groups
Adductors = {'addbrev_','addlong_','addmagDist_','addmagIsch_','addmagMid_','addmagProx_','grac_'};
Hamstrings = {'bflh_','bfsh_','semimem_','semiten_'};
Glutes = {'glmax1_','glmax2_','glmax3_','glmed1_','glmed2_','glmed3_','glmin1_','glmin2_','glmin3_'};
HipFlexors = {'iliacus_','psoas_','recfem_','sart_','tfl_'};
Vasti = {'vasint_','vaslat_','vasmed_'};
Ankle = {'gaslat_r','gasmed_r','soleus_r','tibant_r','tibpost_r'};

% new strength coefficient each group of muscles
y = struct;
y.ADD= ADD; y.HMS = HMS; y.GLU = GLU; y.HFL = HFL; y.VAS = VAS; y.ANK = ANK; y.OTHER = OTHER;
% x tick labels
lb = struct;
lb.ADD ={}; lb.HMS ={}; lb.GLU ={}; lb.HFL ={}; lb.VAS ={}; lb.ANK ={}; lb.OTHER ={};
for k = 1: length({XML.mtuSet.mtu.strengthCoefficient})
    labels{k} = XML.mtuSet.mtu(k).name;
    
    if contains(labels{k},Adductors)&& ~isempty(y.ADD)
        XML.mtuSet.mtu(k).maxContractionVelocity   = y.ADD;
        lb.ADD{end+1} = XML.mtuSet.mtu(k).name;
        
    elseif contains(labels{k},Hamstrings)&& ~isempty(y.HMS)
        XML.mtuSet.mtu(k).maxContractionVelocity = y.HMS;
        lb.HMS{end+1} = XML.mtuSet.mtu(k).name;
        
    elseif contains(labels{k},Glutes) && ~isempty(y.GLU)
        XML.mtuSet.mtu(k).maxContractionVelocity = y.GLU;
        lb.GLU{end+1} = XML.mtuSet.mtu(k).name;
        
    elseif contains(labels{k},HipFlexors)&& ~isempty(y.HFL)
        XML.mtuSet.mtu(k).maxContractionVelocity = y.HFL;
        lb.HFL{end+1} = XML.mtuSet.mtu(k).name;
        
    elseif contains(labels{k},Vasti)&& ~isempty(y.VAS)
        XML.mtuSet.mtu(k).maxContractionVelocity = y.VAS;
        lb.VAS{end+1} = XML.mtuSet.mtu(k).name;
    
    elseif contains(labels{k},Ankle)&& ~isempty(y.ANK)
        XML.mtuSet.mtu(k).maxContractionVelocity = y.ANK;
        lb.ANK{end+1} = XML.mtuSet.mtu(k).name;
        
    elseif ~isempty(y.OTHER)
        XML.mtuSet.mtu(k).maxContractionVelocity = y.OTHER;
        lb.OTHER{end+1} = XML.mtuSet.mtu(k).name;
    end
    
end

%conver the curve data to strings
for k = 1:length({XML.mtuDefault.curve.xPoints})
    XML.mtuDefault.curve(k).xPoints = num2str(XML.mtuDefault.curve(k).xPoints);
    XML.mtuDefault.curve(k).yPoints = num2str(XML.mtuDefault.curve(k).yPoints);
end


for k = 1:length({XML.mtuSet.mtu.name})
    if isfield(XML.mtuSet.mtu(k),'curve') && ~isempty(XML.mtuSet.mtu(k).curve)
        XML.mtuSet.mtu(k).curve.xPoints = num2str(XML.mtuSet.mtu(k).curve.xPoints);
        XML.mtuSet.mtu(k).curve.yPoints = num2str(XML.mtuSet.mtu(k).curve.yPoints);
    end
end


cd(fileparts(DirCalibratedModel))

prefXmlWrite.StructItem = false;  % allow arrays of structs to use 'item' notation
prefXmlWrite.CellItem   = false;
fileout = DirCalibratedModel;
xml_write(fileout, XML, 'subject', prefXmlWrite);