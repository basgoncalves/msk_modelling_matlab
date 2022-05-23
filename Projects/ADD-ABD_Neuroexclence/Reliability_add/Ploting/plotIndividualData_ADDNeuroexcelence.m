ydata= ABD_sit;
[Nsubjects, c] = size(ydata);


xdata = repmat(1:c, Nsubjects, 1);
plot(xdata(:,1),ydata(:,1),'o',xdata(:,2),ydata(:,2),'r o')

xlim([0 c+1]);
xticks(1:c);
xticklabels({'Male' 'Female'});
legend ('Male', 'Female');
title('Adduction sitting')


figure
ydata= ABD_sup;
[Nsubjects, c] = size(ydata);


xdata = repmat(1:c, Nsubjects, 1);
plot(xdata(:,1),ydata(:,1),'o',xdata(:,2),ydata(:,2),'r o')

xlim([0 c+1]);
xticks(1:c);
xticklabels({'Male' 'Female'});
legend ('Male', 'Female');
title('Adduction supine')




%% add empty columns 

% clear empty cells
for ii = size (Data,2)  % loop through every column
    NonEmpty = find(~cellfun(@isempty,Data));
    Data = Data (NonEmpty);
end

% add a blank columns after each column
n = 2;
nc = floor(size (Data,2)/n);
for c=1:nc
    C(:,(n*c+c-n):(n*c+c-1)) = Data(:,(n*(c-1)+1):n*c);
end
    