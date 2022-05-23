%% Basilio Goncalves (2020)
%
% to be used with the fucntion 'FrequencySpikes_Demuse.m'
% No copyright

figure
yyaxis right
plot (ForceData)
ylabel ('Force');
ax=gca;
ax.YAxis(2).Visible = 'off'; % do not show second axis
hold on
yyaxis left
plot(x,y,'.','MarkerSize',8,'Color', [0.25 0.25 0.25] )
plot(xPol,PoliFunct,'LineWidth', 1.5,'Color', [0 0 0])
ax.YAxis(1).Color ='k';
hold off

%% plot_parameters_Demuse
ax = gca;
FS = 20; %fontsize
xlim([0 length(Vector)]);                                               % limits of the x axis

Nsamples = length (Vector);                                              % number of samples
time = round(Nsamples/fs,2);
xticks(0:Nsamples/4:Nsamples);                                         % devide the length of X axis in 5 equal parts (https://au.mathworks.com/help/matlab/creating_plots/change-tick-marks-and-tick-labels-of-graph-1.html)
xticklabels(0:time/4:time);                                            % rename the X labels with the time in sec

xlabel ('Time (s)');
ylabel ('Frequency (Hz)');

% make figure nice
set(gcf,'Color',[1 1 1]);
set(gca,'box', 'off', 'FontSize', FS);
set(findobj('-property','LineWidth'),'LineWidth',1);
ax.Position = [0.15    0.2    0.7    0.7];

fig=gcf;
set(findall(fig,'-property','FontSize'),'FontSize',FS)

pf = sprintf('Polynomial Fit (r = %.2f)', sqrt(Rsq(MU)));
lg = legend ({'Instantaneous Frequencies',pf, 'Force'},'FontSize', FS*0.8);
lg.Box = 'off';
lg.Position = [0.5    0.8    0.6    0.15];

pos = get(0, 'Screensize')/2;           % half screen size = [Xposition Yposition Xsize Ysize]
pos(1) = pos(3)/2;
pos(2) = pos(4)/2;
set(gcf, 'Position', pos);
