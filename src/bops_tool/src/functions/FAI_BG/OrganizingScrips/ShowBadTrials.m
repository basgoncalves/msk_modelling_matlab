
function ShowBadTrials(DirC3D)

muscleString = {'        VM','        VL','        RF','       GRA',...
    '        TA','   ADDLONG','   SEMIMEM','      BFLH','        GM',...
    '        GL','       TFL','   GLUTMAX','   GLUTMED','      PIRI','    OBTINT','    QF'}; % the spaces are part of the name

% channels to look for in the c3dfile
ChannelNames = {'Voltage_1_VM';'Voltage_2_VL';'Voltage_3_RF';'Voltage_4_GRA';'Voltage_5_TA';...
    'Voltage_6_AL';'Voltage_7_ST';'Voltage_8_BF';'Voltage_9_MG';'Voltage_10_LG';...
    'Voltage_11_TFL';'Voltage_12_Gmax';'Voltage_13_Gmed_intra';'Voltage_14_PIR_intra';...
    'Voltage_15_OI_intra';'Voltage_16_QF_intra';};

cd(DirC3D)
load ('BadTrials.mat')

figure
pcolor(cell2mat(BadTrials));
mycolors = [0 1 0;1 1 0; 1 0 0];            % [green yellow red]
colormap(mycolors);
colorbar('Ticks',[0,1,2],'TickLabels',{'good','average','bad'});
NXticks = 1;
xticks (NXticks:NXticks:length(trialNames))
xticklabels (trialNames(NXticks:NXticks:length(trialNames)));
xtickangle (90);

yticks (1:length(muscleString));
NYticks = round(length(muscleString)/length(yticks));
yticklabels (muscleString(NYticks:NYticks:end));

fullscreenFig(0.9,0.9)


