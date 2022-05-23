
subjectDir = uigetdir ('Name','select folder containing all subjects');

%% get Files in the subject folder and subject code
cd(subjectDir);
Subjects = dir;
Subjects (1:2)=[];

for i=1:length (Subjects)
DatFolder = dir (sprintf('%s\\%s\\BiodexData',Subjects(i).folder, Subjects(i).name)); 
SubjectFolder = subjectDir;

    if exist (sprintf('%s\\%s\\BiodexData\\ElaboratedData',...
            Subjects(i).folder, Subjects(i).name),'dir')==7
        
        sprintf('%s already converted',Subjects(i).name)
        
    elseif length (DatFolder) == 2                                                 % if DatFolder is empty (2 = . and .. created by "dir" function)
        
        sprintf('%s is empty',Subjects(i).name)
        
    elseif    exist(Subjects(i).name,'dir')==7 &&...
            exist (sprintf('%s\\%s\\BiodexData',...
            Subjects(i).folder, Subjects(i).name),'dir')==7
        
        DatFolder = sprintf...
            ('%s\\%s\\BiodexData',...
            Subjects(i).folder, Subjects(i).name);
        dat2mat(DatFolder)
        cd(subjectDir);
        sprintf('%s converted',Subjects(i).name)
        
    end
    
    
end
