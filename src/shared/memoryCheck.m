
% command:
%   emtpy = continue memory log (default)
%   'reset' = reset memory log
%   'plot' = create a plot

function memoryCheck(command,timeLabel)

current_dir = fileparts(mfilename('fullpath'));
cd(current_dir)

if nargin < 1
    command = 'update';
end

if contains(command, 'update') || contains(command, 'plot')
    warning off
    data = readtable('memoryCheck.csv');
    data.time(end+1) = datetime('now');
elseif contains(command,'')
    data = table;
    data.time = datetime('now');
    data.memory_in_mb(1)=0;
    data.timeLabel = {'x'}; % random name that will be deleted
end

format shortg
c = clock;

a = memory;
mb = a.MemUsedMATLAB;

data.memory_in_mb(end) = mb./1000000;

if nargin < 2
    timeLabel = ['Label_' num2str(length(data.time))];
end

data.timeLabel{end} = timeLabel;

writetable(data,'memoryCheck.csv')
if  contains(command, 'plot')
    figure
    x = data.time;
    y = data.memory_in_mb;
    plot(x,y)
    ylim([0 a.MaxPossibleArrayBytes./1000000])
    ylabel ('memory in Mb (min to max)')
    xlabel('time')
end
