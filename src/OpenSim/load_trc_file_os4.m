function out = load_trc_file_os4(filename)

% function data = load_trc_file(filename,delimiters)
%
% This function loads a TRC file and stores each X, Y, Z column in a field
% named after the marker the data is associated with (taken from header)
%
% Input: filename - the TRC filename
%
% Output: Stucture containing the data
%
% Author: Glen Lichtwark 
% Last Modified: 13/10/2015

if nargin < 1
    [fname, pname] = uigetfile('*.*', 'File to load - ');
    file = [pname fname];
else file = filename;    
end

[file_data,s_data]= readtext(file, '\t', '', '', '');

headings = file_data(5,:);
out = struct;
for i = 1:length(headings)
    fname = headings{i};
    out.(fname) = cell2mat(file_data(7:end,i));
end