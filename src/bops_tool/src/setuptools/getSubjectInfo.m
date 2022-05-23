

function Info = getSubjectInfo(subject)

if nargin ==0
    subject = selectSubjects;
    while length(subject) ~=1
        msg = msgbox('please select only one subject');
        uiwait(msg)
        subject = selectSubjects;
    end
end

bops        = load_setup_bops;
subjectinfo = table2struct(readtable([bops.directories.subjectInfoCSV]));
row         = contains({subjectinfo.ID},subject);

Info = subjectinfo(row);
if contains(Info.InstrumentedSide,'R')
    Info.NonInstrumentedSide = 'L';
else
    Info.NonInstrumentedSide = 'R';
end



