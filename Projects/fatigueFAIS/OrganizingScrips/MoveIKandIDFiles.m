
% MoveIKandIDFiles
% Organise IK and ID files in folders 
% September, 2020

function MoveIKandIDFiles (Subject)

DirC3D = ['E:\3-PhD\Data\MocapData\InputData\' Subject '\pre'];
OrganiseFAI

folderIKResults = sprintf('%s\\%s',[DirIK fp 'Results'],'*.mot');
Files = dir(folderIKResults);

for k = 1: length(Files)
   
    trialName = erase(Files(k).name,'_IK.mot');
    % create directory
    mkdir([DirIK fp trialName])
    cd(DirIK)
    folderIKxml = sprintf('%s\\%s',DirIK,'*.xml');
    % move xml file 
    XMLFiles = dir(folderIKxml);
    idx = find(contains({XMLFiles.name},trialName));
    movefile(XMLFiles(idx).name,[DirIK fp trialName fp 'setup_IK.xml'])
    % move mot file
    movefile([DirIK fp 'Results' fp trialName '_IK.mot'],[DirIK fp trialName fp 'IK.mot'])
    %move GaitCycle
    movefile([DirIK fp 'GaitCycle-' trialName '.mat'],[DirIK fp trialName fp 'GaitCycle.mat'])    
end


folderIDResults = sprintf('%s\\%s',[DirID fp 'results'],'*.sto');
Files = dir(folderIDResults);

for k = 1: length(Files)
   
    trialName = erase(Files(k).name,'_inverse_dynamics.sto');
    % create directory
    mkdir([DirID fp trialName])
    cd(DirID)
    folderIDxml = sprintf('%s\\%s',DirID,'*.xml');
    % move xml files
    XMLFiles = dir(folderIDxml);
    idx = find(contains({XMLFiles.name},trialName));
    movefile(XMLFiles(idx(1)).name,[DirID fp trialName fp 'grf.xml'])
    movefile(XMLFiles(idx(2)).name,[DirID fp trialName fp 'setup_ID.xml'])
    % move sto file
    movefile([DirID fp 'results' fp trialName '_inverse_dynamics.sto'],...
        [DirID fp trialName fp 'inverse_dynamics.sto'])
 
end