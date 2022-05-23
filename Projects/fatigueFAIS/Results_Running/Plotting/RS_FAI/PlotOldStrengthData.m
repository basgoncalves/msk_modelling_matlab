%% Create structs
FAISrows = find(contains(SubjectCodes,Groups.FAIS));
CAMrows = find(contains(SubjectCodes,Groups.CAM));
CONrows = find(contains(SubjectCodes,Groups.Control));
TasksOfInterest = {'HE','HF','HAB','HER'};
TasksOfInterest_post = {'HE_post','HF_post','HAB_post','HER_post'};
Pre = struct;
Post = struct;
Diff = struct;
S = struct;
for i = 1:length(TasksOfInterest)
    col = find(strcmp(TasksOfInterest{i},Channels));
    S.Pre.(Channels{col}) = [];
    S.Pre.(Channels{col})(1:length(CONrows),1) = TorqueData(CONrows,col);
    S.Pre.(Channels{col})(1:length(FAISrows),2) = TorqueData(FAISrows,col);
    S.Pre.(Channels{col})(1:length(CAMrows),3) = TorqueData(CAMrows,col);
%     S.Pre.(Channels{col}) = rmoutliers( S.Pre.(Headings_pre{col}));
%     
%     col = find(strcmp(TasksOfInterest_post{i},ChannelsPost));
%     S.Post.(TasksOfInterest{i}) = [];
%     S.Post.(TasksOfInterest{i})(1:length(CONrows),1) = TorqueDataPost(CONrows,col);
%     S.Post.(TasksOfInterest{i})(1:length(FAISrows),2) = TorqueDataPost(FAISrows,col);
%     S.Post.(TasksOfInterest{i})(1:length(CAMrows),3) = TorqueDataPost(CAMrows,col);
%     S.Post.(TasksOfInterest{i}) = rmoutliers( S.Pre.(TasksOfInterest{i}));
%     
%     Diff.(Headings_pre{col}) = [];
%     Diff.(Headings_pre{col})(1:length(FAISrows),1) = MeanStrength_Diff(FAISrows,col);
%     Diff.(Headings_pre{col})(1:length(CAMrows),2) = MeanStrength_Diff(CAMrows,col);
%     Diff.(Headings_pre{col})(1:length(CONrows),3) = MeanStrength_Diff(CONrows,col);
end


figure
hold on
xall = [1 2 3 4];
Position = [-0.2 0 0.2];
for ii = 1:length(TasksOfInterest)
   
    x = Position+xall(ii);
    y = S.Pre.(TasksOfInterest{ii});
    y(y==0)=NaN;
    SD = nanmean(S.Pre.(TasksOfInterest{ii}));
    bar(x,nanmean(y))
    er =errorbar(x,nanmean(y),[],SD,'color','k');
     plot(x,y,'o','MarkerFaceColor',[0.2 0.2 0.2],...
        'MarkerEdgeColor','none','MarkerSize',5)
end

 x = Position+xall(ii);
    y = nanmean(S.Pre.(TasksOfInterest{ii}));
    SD = nanmean(S.Pre.(TasksOfInterest{ii}));
    bar(x,nanmean(y))
    er =errorbar(x,nanmean(y),[],SD,'color','k');
     plot(x,y,'o','MarkerFaceColor',[0.2 0.2 0.2],...
        'MarkerEdgeColor','none','MarkerSize',5)
%% Levene's test

group = fields(Groups);
time = {'Pre' 'Post'};

for i = 1:length(TasksOfInterest)
    y = [];
    for t = 1:2
        for g = 1:3
            condition = S.(time{t}).(TasksOfInterest{i})(:,g);
            condition(condition==0)=NaN;
            rows = [length(y)+1:length(y)+length(condition)];
            y(rows,end+1) = condition; 
        end
    end
    p(i)= vartestn(y);
    title([TasksOfInterest{i} ' p-value = ' num2str(p(i))])
    mmfn
    saveas(gcf,[savedir fp 'Levene_' TasksOfInterest{i} '.jpg'])
end


%% ANOVA 3way

group = fields(Groups);
time = {'Pre' 'Post'};
y = []; f1=[]; f2=[]; f3=[];
for i = 1:length(TasksOfInterest)
    for t = 1:2
        for g = 1:3
            condition = S.(time{t}).(TasksOfInterest{i})(:,g);
            condition(condition==0)=NaN;
            rows = [length(y)+1:length(y)+length(condition)];
            y(rows,1) = condition; 
            f1(rows,1) = t;
            f2(rows,1) = i;
            f3(rows,1) = g;
        end
    end
    [p,t,stats,~] = anovan(y,{f1 f3}, 'model','interaction','varnames',strvcat('time','Group'));

end

[p,t,stats,~] = anovan(y,{f1 f2 f3}, 'model','interaction','varnames',strvcat('time', 'Task','Group'));
[comparison,means,h,gnames] = multcompare(stats,'ctype','bonferroni');
%% test changes from pre to post - multiple comparisons with bonferoni corrections 
H = []; % 1= accept 0 = reject
p_diff = []; % pvalue
MD = [];
Ncomparisons = length(fields(Groups))*length(TasksOfInterest);
ALPHA = 0.05/Ncomparisons;
comb = combntns([1:3],2)'; % possible combinations 

anovan(y,group)


%% pre
for i = 1:length(TasksOfInterest) % columns (tasks)
    Data = Pre.(TasksOfInterest{i});
    Data(Data == 0) = NaN;
    for c = comb %   % FAIS vs CAM /FAIS vs CON /CAM vs CON
        [H(i,c),p_diff(i,c),Npvalue(i,c)] = compar2groups(Data(:,c(1)),Data(:,c(2)),ALPHA,2);
    end  
end    

%% post
for i = 1:length(TasksOfInterest) % columns (tasks)
    Data = Post.(TasksOfInterest{i});
    Data = rmoutliers(Data);
    for c = comb %   % FAIS vs CAM /FAIS vs CON /CAM vs CON
        [H(i,c),p(i,c),Npvalue(i,c)] = compar2groups(Data(:,c(1)),Data(:,c(2)),ALPHA,2);
    end  
end   


for i = 1:length(TasksOfInterest) % columns (tasks)    
    Data = Diff.(TasksOfInterest{i});
    Data = rmoutliers(Data);
    for c = comb %   % FAIS vs CAM /FAIS vs CON /CAM vs CON
        [H(i,c),p(i,c),Npvalue(i,c)] = compar2groups(Data(:,c(1)),Data(:,c(2)),ALPHA,2);
    end
end   

%%
Data = [];
for i = 1:length(TasksOfInterest) % columns (tasks)    
    for c = 1:3 %   % Pre vs Post for FAIS CAM and CON
        Data(:,1) = Pre.(TasksOfInterest{i})(:,c); % pre
        Data(:,2) = Post.(TasksOfInterest{i})(:,c);  % post
        Data = rmoutliers(Data);
        [H(i,c),p(i,c),Npvalue(i,c)] = compar2groups(Data(:,1),Data(:,2),ALPHA,1);
    end
end  


figure
hold on
x = [1 2 3 4];
Position = [-0.2 0 0.2];
for ii = 1:length(TasksOfInterest)
   
    bar(Position+x(ii),nanmean(S.Pre.(TasksOfInterest{ii})))
    
end


