%% copyTrials_FAI
% copy trials from folder with all the c3d files (C3Ddir) to 'strength',
% 'run' and 'DynamicTrials'

cd(SubjFolder)


mkdir ('strength');
mkdir ('run');
mkdir ('DynamicTrials');

% copy strength trials
cd(DirC3D)


destination = (sprintf('%s\\%s',SubjFolder,'strength'));
if length(dir(destination))<3
    LoadBar = waitbar(0,'Copying Strength Trials...');
    for ff = 1:length (Files)
        waitbar(ff/length (Files),LoadBar,'Copying Strength Trials...');
        for ii = 1:length(Isometrics_pre)
            isomTrial = Isometrics_pre{ii};
            if contains(Files(ff).name,isomTrial)
                source = Files(ff).name;
                copyfile (source, destination)             
            end
        end
    end
    delete (LoadBar)
end
close all


% copy dynamic trials
cd(DirC3D)
destination = (sprintf('%s\\%s',SubjFolder,'DynamicTrials'));
if length(dir(destination))<3
    LoadBar = waitbar(0,'Copying Dynamic Trials...');
    for ff = 1:length (Files)
        waitbar(ff/length (Files),LoadBar,'Copying Dynamic Trials...');
        for ii = 1:length(DynamicTrials)
            dynam = DynamicTrials{ii};
            if contains(Files(ff).name,dynam)
                source = Files(ff).name;
                copyfile (source, destination)
                
            end
        end
    end
    delete (LoadBar)
    fprintf ('number of dynamic files copied = %.f \n', size(ls(destination),1)-2)
else
    fprintf ('dynamic files already exist \n')
    
end
close all


% copy running trials
cd(DirC3D)
destination = (sprintf('%s\\%s',SubjFolder,'run'));
if length(dir(destination))<3
    LoadBar = waitbar(0,'Copying running Trials...');
    for ff = 1:length (Files)
        waitbar(ff/length (Files),LoadBar,'Copying running Trials...');
        if contains(Files(ff).name,'Run','IgnoreCase',true)&&contains(Files(ff).name,'1')
            source = Files(ff).name;
            copyfile (source, destination)
            
        end
        
    end
    delete (LoadBar)
    fprintf ('number of running files copied = %.f \n', size(ls(destination),1)-2)
else
    fprintf ('running files already exist \n')
end
close all


