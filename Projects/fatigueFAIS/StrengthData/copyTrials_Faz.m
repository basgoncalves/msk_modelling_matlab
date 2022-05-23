%% copyTrials_Faz
% copy trials from folder with all the c3d files (C3Ddir) to 'strength',
% 'run' and 'DynamicTrials'

cd(SubjFolder)

Files = dir(SubjFolder); Files(1:2) = [];

for ff = 1:length (Files)
    cd([Files(ff).folder filesep Files(ff).name])
    mkdir ('emg');
    c3dFiles = dir([Files(ff).folder filesep Files(ff).name filesep '*.c3d']);
    for cc= 1 : length (c3dFiles)
        source = c3dFiles(cc).name;
        destination = ([Files(ff).folder filesep Files(ff).name filesep 'emg']);
        movefile (source, destination)
    end
    
end
