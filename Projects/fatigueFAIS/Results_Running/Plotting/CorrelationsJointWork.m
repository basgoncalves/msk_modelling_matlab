% Basilio Goncalves 2020
% CorrelationsJointWork

close all
cd(DirResults)
load JointWork_correlationData.mat
joints ={'Hip','Knee','Ankle'};
Styles = {'o', 'diamond','^','square'};
MSize = 5;
FS = 25;

SaveDir = [DirFigure filesep 'JointWork_RS'];

% titles
Titles = {};
Titles{end+1} = 'A';
Titles{end+1} = 'B';
% Titles{end+1} = 'C';
% Titles{end+1}  = 'D';

% Ynames (names of the data in the y axis)
Yname_all = {};
% Yname_all{end+1} = {'Positive', 'Negative'};
Yname_all{end+1} = {'H3','H4'};
Yname_all{end+1} = {'K3', 'K4'};
% Yname_all{end+1} = {'A1', 'A2'};

F=gcf;
close (F);
%% Correlation delta work vs delta speed
for tt = 1:length(Titles)
    Titl = Titles{tt};
    Yname = Yname_all {tt};
    if tt/2 ~= round(tt/2)                                  % if it an odd number (right column)
        YLab = '\Delta Work (%)';
    else
        YLab = '';
    end
    if tt == length(Titles) ||   tt == length(Titles)-1     % if last row
        XLab = '\Delta Speed (%)';
    else
        XLab = '';
    end
    
    LegOn = 'off';
    WorkData = CorrelationData;
    mmfn_corrJointWork                                          % make plots
    
    if tt/2 == round(tt/2)                                      % if it a odd number (left column)
        yticklabels('');
    end
    
    if tt == 1 || tt == 2                                       % if its a top row
        if tt ~= length(Titles) && tt ~= length(Titles)-1       % and not last row
            xticklabels('');
        end
    end
    
    F(tt)=gcf;
end

%% merge figs

MainFig = figure;
fullscreenFig(0.6,0.8)
for tt = 1:length(F)
    mergeFigures (F(tt), MainFig,[ceil(length(F)/2),2],tt)
end

%squeeze main figure plots together

for ii = 2:2:length(MainFig.Children)
    OrigianlPos = MainFig.Children(ii).Position;                                            % plot dimesions
    MainFig.Children(ii).Position (2) = OrigianlPos(2)*1;                                     % adjust y position
    MainFig.Children(ii).Position (4) = OrigianlPos(4)*0.8;                                 % adjust y length
    MainFig.Children(ii-1).Position(2) = ...
        MainFig.Children(ii).Position (2)+MainFig.Children(ii).Position (4);                % adjust position labels
end

MainFig. Position = [448         308        1141         543];
close(F)
cd(SaveDir)
saveas(MainFig, sprintf('CorrelationSpeedWork_Relative.jpeg'));

