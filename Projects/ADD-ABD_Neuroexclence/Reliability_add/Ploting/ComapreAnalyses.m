

Main = 'E:\4- Papers_Presentations_Abstracts\Papers\Goncalves-Validity&reliability_hip_strength\Results';
Old = load([Main '\TorqueDataAll_28May19.mat']);
Old = load([Main '\TorqueDataAll_May2019.mat']);
New = load([Main '\TorqueDataAll_April2021.mat']);

N = size(New.TorqueDataAll.FinalData,2);
figure
[ha, pos] = tight_subplot(6,5,0.05,0.05,0.05);
set(gcf, 'Position', [1 41 1920 963]);

for i = 1:N
   axes(ha(i))
   hold on 
   D = round(Old.TorqueDataAll.FinalData(:,i),0);
   D(:,2) = round(New.TorqueDataAll.FinalData(:,i),0);
   bar(D)
   title(New.TorqueDataAll.LabelsAll(i),'Interpreter', 'none')
   mmfn_inspect
   if i>25
       xticks(1:length(D))
       xticklabels(xticks)
   end
end
lg = legend({'Old' 'New'});
lg.Position =  [0.1813    0.9424    0.0365    0.0275];
saveas (gcf,'E:\4- Papers_Presentations_Abstracts\Papers\Goncalves-Validity&reliability_hip_strength\Results\CompareAnalysis.jpeg')

%% compare validity
idx = find(contains(New.TorqueDataAll.LabelsValidity,{'F-' 'IR-' 'ER-'}));
figure
[ha, pos] = tight_subplot(3,2,0.05,0.05,0.05);
set(gcf, 'Position', [1 41 1920 963]);
for i = 1:length(idx)
   axes(ha(i))
   hold on 
   D = Old.TorqueDataAll.Validity(:,idx(i));
   D(:,2) = round(New.TorqueDataAll.Validity(:,idx(i)),0);
   bar(D)
   title(New.TorqueDataAll.LabelsAll(idx(i)),'Interpreter', 'none')
   mmfn_inspect
   if i==5 || i ==6
       xticks(1:length(D))
       xticklabels(xticks)
   end
end
lg = legend({'Old' 'New'});
lg.Position =  [0.1813    0.9424    0.0365    0.0275];

%% remove outliers
Old = load('E:\3-PhD\1-ReliabilityRig\Testing\TorqueDataAll_28May19.mat');
New = load('E:\3-PhD\1-ReliabilityRig\Testing\TorqueDataAll_April2021.mat');

description = New.TorqueDataAll.LabelsAll;
TotalData = New.TorqueDataAll.FinalData;
[New.TorqueDataAll.FinalData_NoOutliers,New.TorqueDataAll.Outliers] = multiOutliers (TotalData,description);
Npvalue = cell2mat(New.TorqueDataAll.Outliers(6,2:end));

description = Old.TorqueDataAll.LabelsAll;
TotalData = Old.TorqueDataAll.FinalData;
[Old.TorqueDataAll.FinalData_NoOutliers,Old.TorqueDataAll.Outliers] = multiOutliers (TotalData,description);
Npvalue = cell2mat(Old.TorqueDataAll.Outliers(6,2:end));

N = size(New.TorqueDataAll.FinalData_NoOutliers,2);
figure
[ha, pos] = tight_subplot(6,5,0.05,0.05,0.05);
set(gcf, 'Position', [1 41 1920 963]);

for i = 1:N
   axes(ha(i))
   hold on 
   D = round(Old.TorqueDataAll.FinalData_NoOutliers(:,(i)),0);
   D(:,2) = round(New.TorqueDataAll.FinalData_NoOutliers(:,(i)),0);
   bar(D)
   title(New.TorqueDataAll.LabelsAll((i)),'Interpreter', 'none')
   mmfn_inspect
   if i>25
       xticks(1:length(D))
       xticklabels(xticks)
   end
end
lg = legend({'Old' 'New'});
lg.Position =  [0.1813    0.9424    0.0365    0.0275];
