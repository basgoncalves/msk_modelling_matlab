



Folder = uigetdir();

%%
Files = sprintf('%s\\%s',Folder,'*.csv');
Files = dir(Files);

Summary = {};
Summary{1,1} = [];
for ii = 1:length(Files)
    col = ii+1; % number of columns +1
    filename = Files(ii).name
    filepath = Files(ii).folder;
    cd(filepath)
    [NUM,TXT,RAW] = xlsread([filepath filesep filename]);
    StudentName =  split(filename,' - ');
    Summary{1,col} = strrep(StudentName{end},'.csv','');
    
    [Nrow,Ncol] = size(RAW);
    for row = 2:Nrow
        Summary{row,1} = RAW{row,2};
        Summary{row,col} = sum((strcmpi(RAW(row,:),'X')));
    end
end

cd(fileparts(Folder))
[~,filename] = fileparts(Folder);

