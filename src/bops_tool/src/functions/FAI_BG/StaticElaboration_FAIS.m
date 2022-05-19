% Run static elaboration Fatigue FAIS
% Basilio Goncalves 2019


% copy static file to the staticelaboration  folder
source = [DirMocap filesep 'static.xml'];
copyfile (source, StaticElaborationFilePath);

StaticInterface_BG(DirC3D,StaticElaborationFilePath)
runStaticElaboration(StaticElaborationFilePath)
close all