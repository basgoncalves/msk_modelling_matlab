
Conditions = fields(MeanEMG_perSubj)';
Muscle = 'BF';
%only 15 channels (16th is a sum)
MVC = [];
MVC(:,1) = nanmean(MeanEMG_perSubj.MVC.(Muscle)(:,1:5),2);
MVC(:,2) = nanmean(MeanEMG_perSubj.MVC.(Muscle)(:,6:10),2);
MVC(:,3) = nanmean(MeanEMG_perSubj.MVC.(Muscle)(:,11:15),2);
for CC = {'25' '50' '75'}
    
    idx= find(contains(Conditions,CC));
    for i = idx
        
        if contains(Conditions{i},'pre')
            pre = [];
            pre(:,1) = nanmean(MeanEMG_perSubj.(Conditions{i}).(Muscle)(:,1:5),2);
            pre(:,2) = nanmean(MeanEMG_perSubj.(Conditions{i}).(Muscle)(:,6:10),2);
            pre(:,3) = nanmean(MeanEMG_perSubj.(Conditions{i}).(Muscle)(:,11:15),2);
        else
            post = [];
            post(:,1) = nanmean(MeanEMG_perSubj.(Conditions{i}).(Muscle)(:,1:5),2);
            post(:,2) = nanmean(MeanEMG_perSubj.(Conditions{i}).(Muscle)(:,6:10),2);
            post(:,3) = nanmean(MeanEMG_perSubj.(Conditions{i}).(Muscle)(:,11:15),2);
        end
    end
    % normalise
    pre = pre./MVC*100;
    pre (pre==0) = NaN;
    
    post = post./MVC*100;
    post (post==0) = NaN;
    
    %% plot
    figure
    hold on
    N = [];
    cMat = lines;
    % plot Pre
    for col = 1:size(pre,2) % loop through channels
        y = pre(:,col);
        x = zeros(length(y),1);
        x(:) = col-0.2;
        plot(x,y,'.','MarkerSize',20)
        N(col) = sum(~isnan(y));
    end
     % plot mean and CI
    x = [0.8 1.8 2.8];
    y = nanmean(pre);
    er = nanstd(pre)./sqrt(N)*1.96;
    errorbar(x,y,er,'k')
    plot(x,y,'k.','MarkerSize',30,'MarkerFaceColor',cMat(col,:))
    
    
    %plot post
     for col = 1:size(post,2) % loop through channels
        y = post(:,col);
        x = zeros(length(y),1);
        x(:) = col+0.2;
        plot(x,y,'d','MarkerSize',7,'MarkerFaceColor',cMat(col,:),'MarkerEdgeColor',cMat(col,:))
        N(col) = sum(~isnan(y));
     end
     % plot mean and CI
    x = [1.2 2.2 3.2];
    y = nanmean(post);
    er = nanstd(post)./sqrt(N)*1.96;
    errorbar(x,y,er,'k')
    plot(x,y,'kd','MarkerSize',10,'MarkerFaceColor','k')
     %% fix plot
    xlim([0 4])
   
    ax = gca;
    ax.Position =[0.18 0.11 0.75 0.81];
    legend(ax.Children([6 1 2]),'mean pre', 'mean post' ,'95%CI','Individual proximal','middle','distal')
    title(sprintf('%s %% MVC',CC{1}),'Interpreter','none')
    xticks([1 2 3])
    xticklabels({'Distal', 'Middle', 'Proximal'})
    xlabel('Muscle regions')
    yl = ylabel(sprintf('EMG amplitude\n (%% of MVIC)   '));
    yl.Rotation = 0;
    yl.HorizontalAlignment = 'right';
    mmfn
    
    
end
