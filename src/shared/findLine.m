%% find line
% data = cell 
% msdg = string
% rng = double with the range of lines to find (eg [-2:2] = 2 lines before until 2 lines after
% OUTPUT
%   m = cell where each element represent one line
%
function [m,ln] = findLine (data,msg,rng)
f = 0;   % find
ln = 0;  % line
while f == 0
    ln = ln+1;
    if contains(data{ln},msg)
        f = 1;
    elseif ln == length(data)
        ln =[];
        m = [];
        disp ('string not found')
        return
    end
end
% fprintf('\n %s \n',data{ln})
m = {data{ln+rng}};
for fl = 1:length(m)
    m{fl} = split(m{fl},' ');
end
end