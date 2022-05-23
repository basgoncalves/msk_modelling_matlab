
function JoniReliability(DataDir)
warning off
fp = filesep;
currentPath = matlab.desktop.editor.getActive;
MainDir = fileparts(currentPath.Filename);
cd(MainDir)
if nargin==0
    DataDir = uigetdir('Select folder with all the data');
end
cd(DataDir)
folderTXT = sprintf('%s\\%s',DataDir,'*.txt');
files = dir(folderTXT);

data = importdata([DataDir fp files(1).name]);
if contains(DataDir,'cmj')
    labels = {'mass [kg]_BW','mass [kg]_extra','performance_index','COP [cm]_trace l','power [W/kg]_1/3','power [W/kg]_max','power [W/kg]_Conc.','power [W/kg]_Exc.','jump [cm]_height','Duration [ms]_total','Duration [ms]_Conc.','Duration [ms]_Exc.','Force [N]_Peak','Force [N]_Rel.','Impulse [Ns]_Conc.','Impulse [Ns]_Exc.'};
elseif contains(DataDir,'drop jump')
    labels = {'Jump_height [cm]','Jump_Power [W/kg]','Jump_RSI','Jump_Contact Time [ms]'};
elseif contains(DataDir,'trapbar')
    labels = {'Force [N]_Max','Force [N]_Max/BW','Time [ms]_peak','RFD 50 ms_abs [kg]','RFD 50 ms_rel [%]','RFD 50 ms_speed [kg/s]','RFD 100 ms_abs [kg]','RFD 100 ms_rel [%]','RFD 100 ms_speed [kg/s]','RFD 150 ms_abs [kg]','RFD 150 ms_rel [%]','RFD 150 ms_speed [kg/s]','RFD 200 ms_abs [kg]','RFD 200 ms_rel [%]','RFD 200 ms_speed [kg/s]'};
end

GroupData = struct;
GroupData.labels = labels;
GroupData.participant={};
LoadBar = waitbar(0,'Copying Strength Trials...');
for ii = 1: length (files)
    
    waitbar(ii/length (files),LoadBar,'Loading all the files...');
    nameTrial = files(ii).name;
    GroupData.participant{ii,1} = lower(strrep(files(ii).name,'.txt',''));
    data = importfile_Joni([DataDir fp nameTrial],1,4);
    [Nrow,Ncol]= size(data);

    for ll = 1:length(labels)
        col = find(strcmp(data(1,:),labels{ll}));       
        if ~isempty(col) && ~isempty(str2num(str2mat(data(2:Nrow,col(1)))))
            GroupData.(['labels' num2str(ll)])(ii,1:Nrow-1) = abs(str2num(str2mat(data(2:Nrow,col(1)))));
        else
            GroupData.(['labels' num2str(ll)])(ii,1:Nrow-1) = NaN;
        end
    end
end
delete(LoadBar)


%% run reliability script
DirNames = strsplit(DataDir,'\');
Param = fields(GroupData);
Rel=struct;
Nrows = round(sqrt(length(Param)));
Ncols = ceil(length(Param)/ Nrows);
MainFig = figure;
count = 1;
for ii = 3: length(Param)
    description = {'Trial-1','Trial-2', 'Trial-3'};
    
    TotalData = GroupData.(Param{ii})(:,1:3);
    if contains(GroupData.labels{ii-2},{'mass [kg]_BW','mass [kg]_extra',...
            'Force [N]_Max','Force [N]_Max/BW','Force [N]_Peak','Force [N]_Rel.'})
        TotalData(TotalData>2*nanmean(TotalData))=NaN;
        TotalData(TotalData<0.1*nanmean(TotalData))=NaN;
    end
    NoOutlierData = TotalData;
    GroupData.(Param{ii})(:,1:3) = TotalData;
    Rel.(Param{ii}) = multiRel (NoOutlierData,description,'C-1');
    
%     f = figure;
%     hold on
%     scatter(NoOutlierData(:,1),NoOutlierData(:,2),'r','filled')
%     scatter(NoOutlierData(:,2),NoOutlierData(:,3),'g','filled')
%     scatter(NoOutlierData(:,1),NoOutlierData(:,3),'b','filled')
%     mmfn
%     set(gca,'FontSize',50)
%     title(GroupData.labels{ii-2},'Interpreter','none')
%     mergeFigures(f,MainFig,[Nrows,Ncols],count)
%     close(f)
%     count= count+1;
end
% set(gcf,'Position',[414 163 1200 800])
% lg = legend({'Trial 1(x) vs 2(y)' 'Trial 2 vs 3' 'Trial 1 vs 3'});
% lg.Position = [0.01 0.6 0.07 0.05];
% saveas(gcf,['relationships.png'])
% close (gcf)
%% reformat data 
% FinalReliability={};
% 
% for ii = 3: length(Param)
% FinalReliability(:,1)= Rel.(Param{ii})(:,1); %
% FinalReliability(:,ii-1)= Rel.(Param{ii})(:,2);
% FinalReliability(1,ii-1)=GroupData.labels(ii-2);                         %labels
% end

% %% Save the xlsx  files
% if isempty (DirNames{end})~=1
% filename = 'reliability.xlsx';
% xlswrite(filename,FinalReliability,1,'A1');
% end
% close all 

%% save individual data 

filename = 'individualData.xlsx';
for ii = 3: length(Param)
   SheetName = strrep(GroupData.labels{ii-2},'[','');
   SheetName = strrep(SheetName,']','');
   SheetName = strrep(SheetName,'/','');
   xlswrite(filename,GroupData.labels(ii-2),SheetName,'A1');
   xlswrite(filename,[GroupData.participant num2cell(GroupData.(Param{ii}))],SheetName,'A2');
end

%% plots 
% f1 = figure;
% hold on
% dataBar = cell2mat(FinalReliability(3,2:end));
% dataErr = cell2mat(FinalReliability(5,2:end))-dataBar;
% ICCBar = bar(dataBar);
% LowerBar = zeros([1,length(GroupData.labels)]);
% x = 1:length(GroupData.labels);
% Erbar = errorbar(x,dataBar,[],dataErr);
% Erbar.LineStyle = 'none';
% Erbar.Color ='k';
% box off;
% xticks([x])
% xticklabels (GroupData.labels); xtickangle(45);ylim([0 1]);
% set(gca,'TickLabelInterpreter','none');
% title ('Intraclass correlation coefficient')
% ylim([0 1])
% mmfn
% disp(['all data analysed and Excel created in ' DataDir]);
% saveas(gcf,'ICC.png')
% close (gcf)