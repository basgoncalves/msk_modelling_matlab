% flip the moments from openSim to match -> Internal Moments + Extension
% Negative
%
%INPUT
%   data = [NxM double]
%   momentName = [1xN char]

function output = FlipOSimMoment (data, momentName)

% hip extension/flexion moments already good
if contains(momentName, 'hip') && contains(momentName, 'moment') && contains(momentName, 'flexion')
    output = data;
    ylb = ('(-) ext / flex (+)');
    
    % hip abduction / adduction moments already good
elseif contains(momentName, 'hip') && contains(momentName, 'moment') && contains(momentName, 'adduction')
    output = data;
    ylb = ('(-) abd / add (+)');
    
    % hip external / internal rotation moments already good
elseif contains(momentName, 'hip') && contains(momentName, 'moment') && contains(momentName, 'rotation')
    output = data;
    ylb = ('(-) ext / int (+)');
    
    % flip knee extension/flexion moements (Derrick et al. 2020 recomend wrong)
elseif contains(momentName, 'knee') && contains(momentName, 'moment')
    output = -data;
    ylb = ('(-) ext / flex (+)');
    
    % ankle extension/flexion moements
elseif contains(momentName, 'ankle') && contains(momentName, 'moment')
    output = data;
    ylb = ('(-) plant / dorsi (+)');
    
    
end



figure
plot (data)
hold on
plot (output)
legend('Data','Data flipped')
ylabel (ylb);
title (momentName, 'Interpreter','none')
mmfn