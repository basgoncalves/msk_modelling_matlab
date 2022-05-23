%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Main script for the reliability data
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS (check if they are in the path)
%   path = fd();
%   ImportEMGc3d
%   GetMaxForce
%INPUT
%   strengthDir
%-------------------------------------------------------------------------
%OUTPUT
%
%--------------------------------------------------------------------------

%% RigReliability

clear; clc; close all
fp = filesep;

AddToPath(matlab.desktop.editor.getActive)
DataDir ='E:\3-PhD\1-ReliabilityRig\Analysis';

cd(DataDir)
load([DataDir fp 'TorqueDataAll.mat'])
%% Bland Altman Plot
idx = find(contains(TorqueDataAll.LabelsValidity,{'F-' 'IR-' 'ER-'}));
MainFig = figure;
TitleText = {'Hip flexion' 'Hip internal rotation' 'Hip external rotation'};
count =1;
for i = idx(1:2:end)
    data = TorqueDataAll.Validity(:,i); % rig values
    data(:,2) = TorqueDataAll.Validity(:,i+1); % biodex values 
%     data(data==0) = NaN;
%     data = rmmissing(data);  
%     [NoOutlierData,Outliers] = rmoutliers(data(:,2)-data(:,1));
%     data(Outliers,:)=[];
%     [data,Outliers] = multiOutliers (data,TitleText(count));
%     [tf, lthresh, uthresh, center] = isoutlier(data);
%     data(tf) =NaN;
    [baAH,fig,x,y,deleted] = BlandAltmanPercentage_BG(data);
    data(deleted,:) = [];
    ylim([-100 100])
    xlabel('Mean torque (N.m)')
    title(TitleText{count})
    if count ~=1
        yticks('')
        ylabel('')
    else
        ylabel (sprintf('Torque difference \n Rig - MDD \n '))
        
    end
    mergeFigures(fig,MainFig,[1,3],count)
    count = count+1;
    close(fig)
end
set(gcf,'Position',[ 410         393        1306         420])
