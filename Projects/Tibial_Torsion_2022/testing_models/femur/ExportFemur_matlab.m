clc
clear all
close all

%% import and export the femur xml file from and to matlab 

%import the model femur as a struct
dataFemur = xml2struct('C:\Users\hulda\Documents\Delft\Delft_secondyear\Thesis\OpenSim\Gait2392_MDP_deformed\OpenSimToMatlab\femur\femur.xml');
%export the model
TestFemur_Matlab = struct2xml(dataFemur);
%write the model as an xml file
FID = fopen('testFemur_MATLAB.xml','w');
fprintf(FID,TestFemur_Matlab);
fclose(FID);