%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Plot data for a single trial and single varibale(i.e 'sto' file)
%-------------------------------------------------------------------------
%
% fileName = name of the sto file to load and plot the contributions
%
% see also
% LoadResults_BG
% mmfn
% mergeFigures
%% Start function
function [MODEL,EXP,CONTRIB,CONTRIB_CL,time] =IAAtrialPlot(DirResultsIAA,fileName,s,cl,TimeWindow)


% muscles from Rajogapal (2015)
musclesL = {'time' ['edl_' s] ['ehl_' s] ['fdl_' s] ['fhl_' s] ['iliacus_' s]...
    ['psoas_' s] ['perbrev_' s] ['perlong_' s] ['sart_' s] ['vasint_' s] ...
    ['addbrev_' s] ['addlong_' s] ['addmagDist_' s] ['addmagIsch_' s] ['addmagMid_' s] ...
    ['addmagProx_' s] ['bfsh_' s] ['bflh_' s] ['glmax1_' s] ['glmax2_' s] ['glmax3_' s] ...
    ['glmed1_' s] ['glmed2_' s] ['glmed3_' s] ['glmin1_' s] ['glmin2_' s] ['glmin3_' s] ...
    ['gaslat_' s] ['gasmed_' s] ['grac_' s] ['semiten_' s] ['semimem_' s] ['soleus_' s] ...
    ['tfl_' s] ['tibant_' s] ['recfem_' s] ['vaslat_' s] ['vasmed_' s]...
    ['edl_' cl] ['ehl_' cl] ['fdl_' cl] ['fhl_' cl] ['iliacus_' cl]...
    ['psoas_' cl] ['perbrev_' cl] ['perlong_' cl] ['sart_' cl] ['vasint_' cl] ...
    ['addbrev_' cl] ['addlong_' cl] ['addmagDist_' cl] ['addmagIsch_' cl] ['addmagMid_' cl] ...
    ['addmagProx_' cl] ['bfsh_' cl] ['bflh_' cl] ['glmax1_' cl] ['glmax2_' cl] ['glmax3_' cl] ...
    ['glmed1_' cl] ['glmed2_' cl] ['glmed3_' cl] ['glmin1_' cl] ['glmin2_' cl] ['glmin3_' cl] ...
    ['gaslat_' cl] ['gasmed_' cl] ['grac_' cl] ['semiten_' cl] ['semimem_' cl] ['soleus_' cl] ...
    ['tfl_' cl] ['tibant_' cl] ['recfem_' cl] ['vaslat_' cl] ['vasmed_' cl]...
    'gravity' 'velocity' 'allactuators' 'inertial' 'MODELTOTAL' 'EXPERIMENTAL'}';


if ~exist('TimeWindow')
    TimeWindow =[];
end

[IAA,LabelsIAA] = LoadResults_BG ([DirResultsIAA fileName],...
    TimeWindow,musclesL,0);
time = IAA(:,1);
TestedLegMuscles = {};
TestedLegMuscles{1} ={['glmax1_' s] ['glmax2_' s] ['glmax3_' s]};               % glutes
TestedLegMuscles{2} ={['gaslat_' s] ['gasmed_' s] ['soleus_' s]};               % gastroc
TestedLegMuscles{3} ={['bfsh_' s] ['bflh_' s] ['semiten_' s] ['semimem_' s]};   % hamstrings
TestedLegMuscles{4} ={ ['recfem_' s] ['tfl_' s] ['iliacus_' s] ['psoas_' s]};   % hip flexors
TestedLegMuscles{5} ={ ['vaslat_' s] ['vasmed_' s] ['vasint_' s]};              % vasti
% Others
TestedLegMuscles{6} = {['edl_' s] ['ehl_' s] ['fdl_' s] ['fhl_' s] ['iliacus_' s]...
    ['psoas_' s] ['perbrev_' s] ['perlong_' s] ['sart_' s] ['vasint_' s] ...
    ['addbrev_' s] ['addlong_' s] ['addmagDist_' s] ['addmagIsch_' s] ['addmagMid_' s] ...
    ['glmed1_' s] ['glmed2_' s] ['glmed3_' s] ['glmin1_' s] ['glmin2_' s] ['glmin3_' s] ...
    ['addmagProx_' s]};
TestedLegMuscles{7} =musclesL(2:end-6);

% external factors
TestedLegMuscles{end+1} = {'gravity'};
TestedLegMuscles{end+1} = [ 'velocity' ];
TestedLegMuscles{end+1} = ['allactuators'];
TestedLegMuscles{end+1} = ['inertial'];


CLLegMuscles = {};
CLLegMuscles{1} ={['glmax1_' cl] ['glmax2_' cl] ['glmax3_' cl]};               % glutes
CLLegMuscles{2} ={['gaslat_' cl] ['gasmed_' cl] ['soleus_' cl]};               % gastroc
CLLegMuscles{3} ={['bfsh_' cl] ['bflh_' cl] ['semiten_' cl] ['semimem_' cl]};   % hamstrings
CLLegMuscles{4} ={ ['recfem_' cl] ['tfl_' cl] ['iliacus_' cl] ['psoas_' cl]};   % hip flexors
CLLegMuscles{5} ={ ['vaslat_' cl] ['vasmed_' cl] ['vasint_' cl]};              % vasti
% Others
CLLegMuscles{6} = {['edl_' cl] ['ehl_' cl] ['fdl_' cl] ['fhl_' cl] ['iliacus_' cl]...
    ['psoas_' cl] ['perbrev_' cl] ['perlong_' cl] ['sart_' cl] ['vasint_' cl] ...
    ['addbrev_' cl] ['addlong_' cl] ['addmagDist_' cl] ['addmagIsch_' cl] ['addmagMid_' cl] ...
    ['glmed1_' cl] ['glmed2_' cl] ['glmed3_' cl] ['glmin1_' cl] ['glmin2_' cl] ['glmin3_' cl] ...
    ['addmagProx_' cl]};


Mnames = {'Glut max' 'Gas' 'Hams' 'HipFlex' 'VAS' 'Other' 'All muscles' 'gravity' 'velocity' 'all actuators' 'inertial'};

MODEL = IAA(:,end-1);
EXP = IAA(:,end);
MainFig = figure;
fullscreenFig (0.8,0.8)
xlabel('% stance')
rows = ceil(sqrt(length(TestedLegMuscles))); % Number of subplots on each row/col
cols = floor(sqrt(length(TestedLegMuscles))); % Number of subplots on each row/col

minY = min(min(IAA)); maxY = max(max(IAA));
for kk = 1:length(TestedLegMuscles)
    idx = contains(LabelsIAA,TestedLegMuscles{kk});
    contrib = sum(IAA(:,idx),2);%.*MODEL;
    minY = min([minY min(min(contrib))]);
    maxY = max([maxY max(max(contrib))]);
    
end

% muslce contributions
for kk = 1:length(TestedLegMuscles)
    f = figure;
    hold on
    plot (MODEL)
    plot(EXP,'--')
    ylim([minY maxY])
    % plot tested leg
    idx = contains(LabelsIAA,TestedLegMuscles{kk});
    contrib = sum(IAA(:,idx),2);%.*MODEL;
    plot(contrib)
    % plot contralateral  leg
    if kk <= length(CLLegMuscles)
        idx = contains(LabelsIAA,CLLegMuscles{kk});
        contrib_cl = sum(IAA(:,idx),2);%.*MODEL;
        plot(contrib_cl)
    end
    
    CONTRIB(:,kk) = contrib;
    CONTRIB_CL(:,kk) = contrib;
    title(Mnames{kk})
    
    if kk == 1
        lg = legend({'Model' 'Experimental' 'Tested Leg' 'Contralateral'});
    end
    
    if kk < length(TestedLegMuscles)-1
        xticks('')
    else
        xlabel('%stance')
    end
    
    if kk~= 1:cols:length(TestedLegMuscles)
        yticks('')
    else
        
    end
    mmfn
    f.CurrentAxes.FontSize = 70;
    mergeFigures (f, MainFig,[rows,cols],kk)
    close(f)
end

%

MainFig.Children(end-1).Position =[0.7413    0.1506    0.1091    0.0900]; % legend position




