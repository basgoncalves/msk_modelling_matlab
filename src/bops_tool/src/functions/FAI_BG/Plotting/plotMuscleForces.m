%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Select folder that contains individual
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS (check if they are in the path)
%   TimeWindow_FatFAIS
%   LoadResults_BG
%   mmfn
%   DirUp
%INPUT
%   CEINMSdir = [char] directory of the your ceinms dta for one subject
%       e.g. = 'E:\3-PhD\Data\MocapData\ElaboratedData\subject\session\ceinms'
% designed for Rajagopal model
%   side = measured side, use {'R'} for right leg or {'L'} for right leg or
%   PlotContraLateral = 1 for yes, 0 for no;
%-------------------------------------------------------------------------
%OUTPUT
%  Plot with musc
%--------------------------------------------------------------------------
% NOTE - you may need to change the names of the motions and muslces
%
%
%% plotMuscleForces

function plotMuscleForces(Dir,trialName,SubjectInfo,PlotContraLateral)
tic
clc
warning off
%% Default settiong and directories
fp = filesep;
set(0,'DefaultAxesFontName', 'Consolas')

BestItr = findBestItr(Dir,trialName,SubjectInfo.TestedLeg);
CEINMSResultsdir = [BestItr{2,1} fp BestItr{2,2}];
TimeWindow = TimeWindow_FatFAIS(Dir,trialName);

%% muscle forces 
fprintf('plotting muscle forces... \n')

if ~exist('PlotContraLateral') || PlotContraLateral == 0
    s = lower(SubjectInfo.TestedLeg);
elseif PlotContraLateral == 1
    s = clLeg (SubjectInfo.TestedLeg);
end


MG = struct; % muscle groups;
MG.HAMS = {['bflh_' s],['bfsh_' s],['semiten_' s],['semimem_' s]};
MG.ANK = {['gasmed_' s],['gaslat_' s],['soleus_' s],['tibant_' s]};
MG.Adductors = {['addlong_' s],['addbrev_' s],['addmagDist_' s],['addmagIsch_' s],...
['addmagMid_' s],['addmagProx_' s],['grac_' s]};
MG.Glut= {['glmax1_' s],['glmax2_' s],['glmax3_' s],...
['glmed1_' s],['glmed2_' s],['glmed3_' s],...
['glmin1_' s],['glmin2_' s],['glmin3_' s]};
MG.HFlex = {['iliacus_' s],['psoas_' s],['sart_' s],['tfl_' s],['recfem_' s]};
MG.Quads = {['vasmed_' s], ['vaslat_' s],['vasint_' s]};

MG_EMG = struct; % muscle groups;
MG_EMG.HAMS = {'BFLH','','SEMIMEM',''};
MG_EMG.ANK = {['gasmed_' s],['gaslat_' s],['soleus_' s],['tibant_' s]};
MG_EMG.Adductors = {['addlong_' s],['addbrev_' s],['addmagDist_' s],['addmagIsch_' s],...
['addmagMid_' s],['addmagProx_' s],['grac_' s]};
MG_EMG.Glut= {['glmax1_' s],['glmax2_' s],['glmax3_' s],...
['glmed1_' s],['glmed2_' s],['glmed3_' s],...
['glmin1_' s],['glmin2_' s],['glmin3_' s]};
MG_EMG.HFlex = {['iliacus_' s],['psoas_' s],['sart_' s],['tfl_' s],['recfem_' s]};
MG_EMG.Quads = {['vasmed_' s], ['vaslat_' s],['vasint_' s]};


Mgroups = fields(MG);

% load model to normalise the muscle forces
CEINMSModel = [Dir.CEINMScalibration fp 'calibratedSubject.xml'];

% dock figures
% (https://au.mathworks.com/matlabcentral/answers/157355-grouping-figures-separately-into-windows-and-tabs)
figH    = gobjects(1, length(Mgroups)+1);

% plot muscle force/length 
for kk = 1:length(Mgroups)
    P = struct;% parameters
    [P.MuscleForce,Labels] = LoadResults_BG ([CEINMSResultsdir fp 'MuscleForces.sto'],...
        TimeWindow,MG.(Mgroups{kk}),0);
    
    P.MuscleForce = NormMuscleForce(CEINMSModel,P.MuscleForce,Labels);

    [P.FibreLength,~] = LoadResults_BG ([CEINMSResultsdir fp 'NormFibreLengths.sto'],...
        TimeWindow,MG.(Mgroups{kk}),0);

    [P.Activation,Labels] = LoadResults_BG ([CEINMSResultsdir fp 'Activations.sto'],...
        TimeWindow,MG.(Mgroups{kk}),0);
    
    [P.Velocity,Labels] = LoadResults_BG ([CEINMSResultsdir fp 'NormFibreVelocities.sto'],...
        TimeWindow,MG.(Mgroups{kk}),0);
 
    
    Ylab ={'Force(%max)','Norm Length','Activation (%max)'};
    Xlab = '% gait cycle';
    para = fields(P);% parameters    
    nrows = length(para);
    ncols = length(Labels);
    c = 0; % count subplots
    
    % doc figures
     figH(kk) = figure('WindowStyle', 'docked', ...
      'Name', sprintf('%s', Mgroups{kk}), 'NumberTitle', 'off'); 
    for p = 1:length(para) % Rows
        for m = 1:length(Labels) % columns
            % plot data
            c=c+1; subplot (nrows,ncols,c); plot(P.(para{p})(:,m))
            mmfn_CEINMS
            
            % ylims
            if contains(para{p},'Force'); ylim([0 2])
            elseif contains(para{p},'Length'); ylim([0 2])
            elseif contains(para{p},'Activation'); ylim([0 1])
            end

            % x Labels and x ticks and title
            if p == nrows;  xlabel(Xlab)
            elseif p ==1; title(strtrim(Labels{m}));xticks('');
            else; xticks(''); end

            %y ticks
            if m == 1;yl = ylabel(Ylab{p});
            else; yticks('');
            end        
        end 
    end
end

%% save data
cd(CEINMSResultsdir)
filename = ['Results_' s '.mat'];
save (filename, 'figH')
toc