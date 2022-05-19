%% SPM: Two-way repeated measures ANOVA + create patches for plots
% This section has been taken from SPM1D
% The inputs are as follows:
% Y = data; A = First Factor (i.e., treatment group_; B = nested factor
% (i.e., time point); SUBJ = subject ID

clc; clear;close all;
tmp = matlab.desktop.editor.getActive;
pwd = fileparts(fileparts(fileparts(tmp.Filename)));
addpath(genpath(pwd));
cd(fileparts(tmp.Filename))
folderNames = {'ID_hip_flexion'; 'ID_hip_adduction'; 'ID_hip_rotation';};
%     'ID_knee_flexion';...
%     'IK_hip_flexion'; 'IK_hip_adduction'; 'IK_hip_rotation'; 'IK_knee_flexion'; 'IK_pelvis_list';...
%     'IK_pelvis_rotation'; 'IK_pelvis_tilt'; 'IK_lumbar_bending'; 'IK_lumbar_extension'; 'IK_lumbar_rotation'};
fileNames = {'IK_HipFlex_SPM.mat';'IK_HipAdd_SPM.mat';'IK_HipRot_SPM.mat';};
%     'ID_KneeFlex_SPM.mat';...
%     'IK_HipFlex_SPM.mat';'IK_HipAdd_SPM.mat';'IK_HipRot_SPM.mat';'IK_KneeFlex_SPM.mat'; 'IK_PelvisList_SPM.mat';...
%     'IK_PelvisRot_SPM.mat'; 'IK_PelvisTilt_SPM.mat'; 'IK_LumbBend_SPM.mat';'IK_LumbExt_SPM.mat'; 'IK_LumbRot_SPM.mat';};

% folderNames = {'IK_lumbar_rotation'};
% fileNames = {'IK_LumbRot_SPM.mat'};

PatchArea = struct;
for k = 1:length(fileNames)
    
    load(fileNames{k}) % l
    
    Y=Y';
    
    %(1) Conduct SPM analysis:
    spmlist   = spm1d.stats.anova2onerm(Y, A, B, SUBJ);
    spmilist  = spmlist.inference(0.05);
    disp_summ(spmilist)
    % close all
    spmilist.plot();
    saveas(gcf, strcat(resDir,'spmList'), 'png');
    
    %(2) Plot:
%     close all
    fig = spmilist.plot('plot_threshold_label',false, 'plot_p_values',false, 'autoset_ylim',false);
    F = gcf;
    
    PA ={};
    for ii = 1:length(F.Children)
        L = F.Children(ii).Children;
        %     y = ;% the ve
        for kk = 1: length(L)
            PA{ii,kk} ={};
            if contains(class(L(kk)),'Patch')
                PA{ii,kk} = round([L(kk).XData],0);
            end
        end
    end
     PatchArea.(folderNames{k}) =PA;
%     close all
end
