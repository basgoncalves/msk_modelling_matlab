
function subjects = selectSubjects(SelectAll,msg)

bops = load_setup_bops;

subjects = table2struct(readtable([bops.directories.subjectInfoCSV]));

if nargin < 1
   SelectAll = 0; 
end

if nargin < 2
   msg = 'select subjects:';                                            
end

if SelectAll == 0
    [indx,~] = listdlg('PromptString',msg,'ListString',{subjects.ID});                                              % select subjects                                                                                                
    subjects = {subjects(indx).ID};
elseif SelectAll == 1
    subjects = {subjects.ID};
end

if isempty(subjects)
    bops.subjects = struct;
else
    bops.subjects = subjects;
end

xml_write(bops.directories.setupbopsXML,bops,'bops',bops.xmlPref);                                                          % save settings

