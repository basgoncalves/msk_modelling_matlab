



Folder = uigetdir();

%%
Files = sprintf('%s\\%s',Folder,'*.csv');
Files = dir(Files);

if contains(Folder, 'Block 4')
    DateW1 = '27/05/2019';
    DateW2 = '3/06/2019';
elseif contains(Folder, 'Block 5')
    DateW1 = '1/07/2019';
    DateW2 = '8/07/2019';
elseif contains(Folder, 'Block 6')
    DateW1 = '5/08/2019';
    DateW2 = '12/08/2019';
end



ii = 1;
Summary = {};
Summary{1,1} = [];
for ii = 1:length(Files)
    
    filename = Files(ii).name
    filepath = Files(ii).folder;
    cd(filepath)
    [NUM,TXT,RAW] = xlsread([filepath filesep filename]);
    StudentName =  split(filename,' ');
    Summary{1,end+1} = [StudentName{1} '_week_1'];
    Summary{1,end+1} = [StudentName{1} '_week_2'];
    
    ColW1 = find(strcmp(RAW(1,:),DateW1));

    ColW2 = find(strcmp(RAW(1,:),DateW2));
    
    ColWadd = find(strcmp(RAW(1,:),'add date'));
    
    if isempty(ColW1) && isempty(ColW2)
        continue
    else 
   
    if isempty(ColW1)
        ColW1 = [];
    elseif isempty(ColW2)
        ColW1 = ColW1(1):ColWadd(1)-1;
    end
    if isempty(ColW2)
        ColW2 = [];
    else
    ColW2 = ColW2(1):ColWadd(1)-1;
    end
  
    for row = 2:16
        Summary{row,1} = RAW{row,2};
        Summary{row,end -1} = sum((strcmpi(RAW(row,ColW1),'X')));
        Summary{row,end} = sum((strcmpi(RAW(row,ColW2),'X')));
    end
    end
    
end