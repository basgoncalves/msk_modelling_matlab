

BA = scatter(data(:,1),data(:,2));
ylabel(labels{1});
xlabel(labels{2});

title ('Hip external rotation','FontSize',14);

ylim([-80 80]);

% set axis to origin
set(gca,'XAxisLocation', 'origin');
set(gca,'YAxisLocation', 'origin');
set(gca,'FontSize',14);
box off

[0.13,0.11,0.775,0.8146825]