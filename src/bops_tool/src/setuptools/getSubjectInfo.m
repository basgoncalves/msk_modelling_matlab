

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

% if current subject doesnt have data in the InfoCSV
try
    row = contains({subjectinfo.ID},subject);
    Info = subjectinfo(row);
catch
    createRowForSubject
end

if contains(Info.InstrumentedSide,'R')
    Info.NonInstrumentedSide = 'L';
else
    Info.NonInstrumentedSide = 'R';
end

    function createRowForSubject()
        fld = fields(subjectinfo);
     
        prompt = fld;
        dlgtitle = 'Input';
        dims = [1 35];
        
        Info = struct;
        Info.Age = '78';                                  % demographics from doi:10.1109/TBME.2016.2586891
        Info.DateOfBirth = '01-Jan-1978';
        Info.DateOfTesting = '01-Jan-2022';
        Info.DominantSide = 'R';
        Info.Group = 'Control';
        Info.Height_cm = '175';
        Info.ID = subject;
        Info.InstrumentedSide = 'R';
        Info.Mass_kg = '68';
        Info.Sex = 'M';
        Info.ToProcess = '1';
        definput = struct2cell(Info);
        Info = inputdlg(prompt,dlgtitle,dims,definput);
    end

end

