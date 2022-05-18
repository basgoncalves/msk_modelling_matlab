%% Description - Goncalves, BM (2020)
% remove letters and other characters form a char array and create a double
% with only the number in the char array
%-------------------------------------------------------------------------
%INPUT
%   String = string to convert to mat 
%-------------------------------------------------------------------------
%OUTPUT
%   OUTPUT = double with all the letters removed 
%--------------------------------------------------------------------------


function OUTPUT = CleanStr2Num (String)

% delete asterisks or any other characthers that are not numbers
if contains(class(String),'char')
    OUTPUT = erase(String,'*');
    OUTPUT = erase(OUTPUT,'a');
    OUTPUT = erase(OUTPUT,'b');
    OUTPUT = erase(OUTPUT,'#');
    OUTPUT = str2num(OUTPUT);
else
    OUTPUT = String;
end