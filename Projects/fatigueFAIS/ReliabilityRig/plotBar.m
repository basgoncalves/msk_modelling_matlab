% This fucntion plots a bar graph 
% 
% INPUT 
%   dataBar = maxTorqueRig;
%   labelsBar = labelsMeanRig;
%   groups = groupsRig;

function mybar = plotBar (dataBar, labelsBar, groups)



if isempty(dataBar)~=1
    figure('NumberTitle', 'off', 'Name', 'Individual Max Torque Rig');    % create figure
    mybar = bar (1: length (dataBar),dataBar);                            % create bar graph
    set(gca,'XTick',groups);                                            % set one tick for each group (+1 to put the name of the group in the second bar graph, looks better)
    xticklabels(labelsBar);                                               
    set(gca,'TickLabelInterpreter','none');                               % do not use subscript after "_"
    xtickangle (45);                                                      % change tick angle to 45 degrees
    Dim = get(0,'ScreenSize');       
    set(gcf,'Position',[Dim(3)/4 Dim(4)/3 1000 500]);                            % resize the figure [Xpos Ypos Xsize Ysize]
    
    ylabel ('Y label');
    set(gca,'TickLabelInterpreter','none')
    set(get(gca,'ylabel'),'rotation',0,'HorizontalAlignment','right')
    text(1:length(dataBar),round(dataBar)...
        ,num2str(round(dataBar)'),'vert','bottom','horiz','center');
    box off
    title (sprintf ('No Title, Edit in the code'));
    
    %% change bar coulours (NOTE: use groupsRig)
    mybar.FaceColor = 'flat';                                             % allow changing bar colour
    for c = 1: length(labelsBar)                                          % loop through all the conditions (e.g. B_ABD, B_ADD..)
        
        colour = rand ();                                                 % define the colour for each condition
        for b = groups(c):groups(c+1)                                     % loop through each trail (1,2,3...)
            mybar.CData(b,:) = [c*0.1 colour 0];                          % colour with the tones of orange [red green blue]
        end
    end
end
