% after digitizing literature data using "https://apps.automeris.io/wpd/"
% this fucntion can be used to select multiple folders that must contain 2
% subfolders: "PNGfiles" and "CSVfiles".

function DigitizedData = csv2Mat_LiteratureData(PaperFolders)

fp = filesep; 
activeFile = matlab.desktop.editor.getActive;                                                                       % get dir of the current file
current_dir  = fileparts(activeFile.Filename);                                                                          
DigitizedData = struct;

if nargin<1 && exist("current_dir") == 0
    PaperFolders = uigetmultiple(cd,'Select the folders of the papers to conver data (eg. Lai2016)');
else
    if nargin < 1
        DirDigitized = dir([current_dir fp 'DigitizedData']);
        DirDigitized = DirDigitized([DirDigitized.isdir]);
        DirDigitized(1:3) = [];
        PaperFolders = {};
        for k=1:length(DirDigitized)
            PaperFolders{k,1} = [current_dir fp 'DigitizedData' fp DirDigitized(k).name];
        end

    else
        for k=1:length(PaperFolders)
            PaperFolders{k,1} = [current_dir fp 'DigitizedData' fp PaperFolders{k}];
        end

    end
end
    
for p = 1:length(PaperFolders)
    PaperData = struct;
    Files = dir([PaperFolders{p} fp 'CSVfiles' fp '*.csv']);
    for f = 1:length(Files)
        Data = csvread([Files(f).folder fp Files(f).name]);
        [~,idx] = sort(Data(:,1));
        SortedData = Data(idx,:);
        DataNorm = TimeNorm(SortedData,1);
        fname= strrep(Files(f).name,'.csv','');
        fname = strrep(fname,' ','_');
        PaperData.(fname) = DataNorm;
%         figure;plot(DataNorm);title(fname,'Interpreter','none')
    end
    filename = [PaperFolders{p} fp 'PaperData.mat'];
    save (filename,'PaperData')
    [~,PaperName] = fileparts(PaperFolders{p});
    PaperName = strrep(PaperName,' ','_');
    DigitizedData.(PaperName) = PaperData;
end

filename = [DirUp(PaperFolders{p},1) fp 'DigitizedData.mat'];
save (filename,'DigitizedData')