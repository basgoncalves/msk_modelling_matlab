%% Description - Goncalves, BM (2019)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% this function filters and plots .
%
% INPUT
%   subjectDir = directory of the subject forlder 

%-------------------------------------------------------------------------
%OUTPUT
%   subjectDir = directory of the subject forlder 
%   folderData = struct incldng
%       name
%       folder
%       date
%       bytes
%       isdir
%       datenum

%% start Function

function [subjectDir,folderData]=FindSubjectDir (subjectDir)
%% find the folder of the subject to analyse IF not specified

if nargin ==0
    subjectDir = uigetdir('','Select subject folder');
end
%% get Files in the subject folder and subject code
cd(subjectDir);

folderData = dir;

