fp = filesep;
CheckSubjects ={};

Dir_drive = 'D:\3-PhD\Data\MocapData\ElaboratedData';
for ff = 1:length(Subjects)
    
    [Dir,Temp,SubjectInfo,Trials,Fcut] = getdirFAI(Subjects{ff});
    
    Dir_input = [Dir_drive fp strrep(Subjects{ff},'s','') fp 'pre'];
    copyfile([Dir_input fp 'acquisition.xml'],[Dir.Elaborated fp 'acquisition.xml'])    % create a copy in /ElaboratedData/Subject/
end