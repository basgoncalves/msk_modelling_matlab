% find_duplicate_files.m
%
%   This script finds duplicate files constrained by 'filetype' within the directory 'parentDIR'.
%       'filetype' (set below) describes file extension.  ex:  '*.m';  '*.mat';  'bestfunc.m';  '*' (all files).
%       'parentDIR' is the directory (and sub dirs.) to search.  ex: 'C:\Users\adanz\Documents\MATLAB';  'C:\Program Files\MATLAB\R2013a\';  'C:\'.
%   These two parameters are set here at the beginning.
%
%   I chose to run this as a script rather than function for simplicity.  Unwanted vars are cleared at the end
%   leaving you with the following outputs in your workspace:
%       dup_count:  the number of duplicate filenames found
%       DUPLICATES_names: an array of file names that have duplicates
%       DUPLICATES_paths: an array of paths segments by duplicate files (the portion of path defined in 'parentDIR' is removed'
%       filetype and parentDIR (the inputs) will also be in the workspace.
%
%   IMPORTANT:  This script uses a custom fuction, 'getfiles.m' by Dan Nyren found on mathworks.com
%               http://www.mathworks.com/matlabcentral/fileexchange/47459-getfiles-m
%
% 150322  Adam Danz
function find_duplicate_files
%% PPARAMETERS
activeFile = matlab.desktop.editor.getActive;                                                                       % get dir of the current file
addpath(activeFile.Filename)                                                                          
%enter parent directory (will search all sub dirs, too).
parentDIR = 'C:\Users\adanz\Documents\MATLAB';
%enter file extention or a specific or partial filename
filetype = '*.m';                                   %'*.m' for mfiles    '*.mat' for mat files

%% This could take a while depending on your params
allPs = getfiles(filetype, parentDIR);              %this is a custom func, generates list of all paths to all 'm' files
allFs = cell(numel(allPs),1);                       %storage bin
%trim paths to get filenames
wb1 = waitbar(0);                                   %display a waitbar
for i = 1:numel(allPs)                              %for each file in allMs
    namestart = max(find(allPs{i}=='\'))+1;         %char idx for beginning of filename within path
    allFs{i} = allPs{i}(namestart:end);             %all filenames (trimmed from paths)
    allPs_trim{i} = allPs{i}(numel(parentDIR)+1:end);  %trims the parentDIR from all paths since it will always be the same (save display output)
    waitbar(i/numel(allPs), wb1, 'Preparing lists of all files in all subdirectories'); %update waitbar
end

DUPLICATES_paths = {};                              %create storage bin
DUPLICATES_names = {};                              %create storage bin
dup_count = 0;                                      %counts num of dups
wb2 = waitbar(0);                                   %display waitbar
%find matches in allFs
for i = 1:numel(allFs)
    matches = find(strcmp(allFs, allFs(i)));                    %idx of matches (scalar mean no match, vector are matches)
    if length(matches)>1 && sum(strcmp(DUPLICATES_names, allFs(i))) < 1 %if there is a duplicate AND this dup hasn't already been listed
        clc, dup_count = dup_count + 1                          %display live count of duplicates
        DUPLICATES_names(end+1) = allFs(i);                     %list of filenames of dups
        DUPLICATES_paths(end+1: end+length(matches)) = allPs_trim(matches);  %list of paths from dup files
        DUPLICATES_paths(end+1) = {' '};                        %add a blank line between matches
    end
    waitbar(i/numel(allFs), wb2, 'Preparing lists of all duplicate files'); %update waitbar
end
%clear unwanted vars from workspace
close ([wb1 wb2])
clearvars = {'allFs', 'allPs', 'allPs_trim', 'i', 'matches', 'namestart', 'wb1', 'wb2', 'clearvars'};
clear (clearvars{:});
%convert to column vectors
DUPLICATES_paths = DUPLICATES_paths';
DUPLICATES_names = DUPLICATES_names';
% % Display outputs
% clc
% disp(['There are ', num2str(dup_count), ' duplicate files'])
% disp('File names:')
% DUPLICATES_names'
% disp('Paths')
% DUPLICATES_path'

function [ FileList ] = getfiles( varargin )
%GETFILES Creates a list of files from optional file extensions and/or
%keywords in all folders and subfolders in current or supplied directory
%
%Author: Dan Nyren August 2014
%__________________________________________________________________________
% SYNTAX :
%
%   FileList=GETFILES(Input1,...,Input3)
%__________________________________________________________________________
% INPUTS :
%
% NOTE: Input order does not matter, however there can only be a maximum of
%       3 inputs.
%
%    File Keyword/Extension :
%                          -Any File Extension in '*.*' format. If no file
%                           extension input is provided, output will be all
%                           files within specified directory.
%                          -Keywords can also be provided to narrow search
%                           where asterisk (*) is a wildcard(example:
%                           '*sample*.csv' will output all files ending in
%                           sample___.csv such as fastsample1.csv or
%                           sample0132.csv).
%                          -Multiple filenames can be provided, separated
%                           by spaces (in the form '*.ext1 *.ext2' where
%                           all of the files of all of the extensions
%                           listed will be output.
%                          -Any of the above can be combined to create
%                           large keyword/extension combinations.
%
%    Directory :           Location of folder to search within. If no
%                          directory is provided, the current working
%                          directory will be used. NOTE: Supplying a
%                          directory will add that directory to the current
%                          working directory. To return to old directory,
%                          use CD.
%
%    Specific Files:       Matrix used to select specific files from output
%                          list. If no matrix is provided entire list will
%                          be output.
%__________________________________________________________________________
% EXAMPLES :
%
%    FileList=GETFILES;
%        Outputs a list of all the files in the current working directory.
%
%    FileList=GETFILES('*.csv');
%        Outputs a list of all of the *.csv (comma separated value) files
%        in the current working directory.
%
%    FileList=GETFILES('*sample.csv');
%        Outputs a list of all of the files ending in  sample.csv in the
%        current working directory.
%
%    FileList=GETFILES('C:\Program Files\MATLAB\R2013a\licenses')
%        Outputs a list of all of the files in the licenses folder (and any
%        subfolders) of the licenses folder in the MATLAB program files.
%
%    FileList=GETFILES([1,3:5,18])
%        Outputs files 1, 3, 4, 5, and 18 from the sorted list of the files in
%        the current working directory.
%
%    FileList=GETFILES('*.txt','C:\Program Files\MATLAB\R2013a\',[4,18:20])
%        Ouputs *.txt files 4, 18, 19, and 20 from the R2013a folder (and
%        any subfolders) of the MATLAB program files.
%__________________________________________________________________________
% NOTES :
%
%  -Supplying a directory will add that directory to the current working
%  directory
%
%  -Filename endings can also be provided to narrow search example:
%  '*sample.csv' will output all files ending in sample.csv)
%
%  -Use UIGETDIR to interactively get directory path and pass it to
%  GETFILES
%
%  -The first files in the list will generally be the files from the main
%  folder selected
%
%
% See also DIR, UIGETDIR, CD,  TYPE
% source: http://www.mathworks.com/matlabcentral/fileexchange/47459-getfiles-m
switch nargin
    case{0}
        FileList=systemfiles('*.*');
    case{1}
        if cellfun(@(x) isempty(strfind(x,':\')),varargin) && ~cellfun(@isnumeric,varargin);
            % There is not a directory input or a numeric input (there is a file type)
            FileList=systemfiles(varargin{1});
        elseif cellfun(@isnumeric,varargin)
            % There is a matrix input
            FileList=systemfiles('*.*');
            if ~isempty(FileList)
                FileList=FileList(varargin{1}); % Keep only wanted files
            else
                disp('No Files Found')
            end
        else
            % There is a directory input
            cd(varargin{1})
            FileList=systemfiles('*.*');
        end
    case{2}
        if ~cellfun(@isnumeric, varargin)
            % No numeric input, therefore a directory and file type are
            % inputs
            idx=cellfun(@(x) ~isempty(strfind(x,':\')),varargin); % separate which cell is directory or file type
            cd(varargin{idx}); % change working directory to the one selected
            FileList=systemfiles(varargin{~idx}); % Find Files in Directory
            
        elseif nnz(cellfun(@(x) isempty(strfind(x,':\')),varargin))==2 && nnz(cellfun(@isnumeric,varargin))~=2
            % There is a file type and a matrix input
            idx=cellfun(@isnumeric,varargin); % separate which cell is matrix or file type
            FileList=systemfiles(varargin{~idx}); % Find Files in Directory
            if ~isempty(FileList)
                FileList=FileList(varargin{idx}); % Keep only wanted files
            else
                disp('No Files Found')
            end
        else
            % There is a directory and a matrix input
            idx=cellfun(@isnumeric,varargin); % separate which cell is directory or matrix type
            cd(varargin{~idx}) % change working directory to the one selected
            FileList=systemfiles('*.*'); % Find Files in Directory
            if ~isempty(FileList)
                FileList=FileList(varargin{idx}); % Keep only wanted files
            else
                disp('No Files Found')
            end
        end
    case{3}
        % There is a file type, directory, and matrix input
        idxm=cellfun(@isnumeric,varargin); % separate which cell is a matrix
        idxd=cellfun(@(x) ~isempty(strfind(x,':\')),varargin); % separate which cell is a directory
        
        cd(varargin{idxd}) % change working directory to the one selected
        FileList=systemfiles(varargin{~(idxm+idxd)}); % Find Files in Directory
        if ~isempty(FileList)
            FileList=FileList(varargin{idxm}); % Keep only wanted files
        else
            disp('No Files Found')
        end
end

function [ Files ]=systemfiles(ext)
% Perform a search through every layer of the folder to find all input files
[~, list]=system(['dir /S /B ', ext]);
% Parse list to separate files
Files=regexp(list,'.*','match','dotexceptnewline');

