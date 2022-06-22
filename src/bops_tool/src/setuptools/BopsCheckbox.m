function [OutValues,OutConditions] = BopsCheckbox(Conditions,Values,TitleText)

if nargin < 2 || isempty(Values) || length(Values) ~= length(Conditions)
    Values = zeros(length(Conditions),1);
end

if nargin < 3
    TitleText = 'Select the boxes you want';
end

OutValues = Values;

Xsize_text = length(TitleText)*0.005;
Ysize_window = length(Conditions)*0.08;
if Ysize_window > 0.95; Ysize_window = 0.95; end
Ypos_window = 1-Ysize_window;

FigureHandle = figure('units','pixels','position',[200,200,150,50],...                                              % create figure handle
    'toolbar','none','menu','none');
set(gcf,'units','normalized','outerposition',[0.4 Ypos_window Xsize_text Ysize_window])


% Create checkboxes
yPos = 0.7/length(Values);
for i = 1:length(Conditions)                                                                                        % add tick boxes for each condition
    Xsize_text = length(Conditions{i})*0.1;
    TickHandles(i) = uicontrol('style','checkbox','units','normalized',...
        'position',[0.1,0.85-yPos*i,Xsize_text,0.02],'string',Conditions{i},'value',Values(i));                      
end

TextHandle = uicontrol('style','text','units','normalized',...                                                      % add text
    'position',[0.1,0.9,0.9,0.05],'string',TitleText);

ok_button = uicontrol('style','pushbutton','units','normalized',...                                                 % add the ok button
    'position',[0.25,0.05,0.5,0.05],'string','Ok');

ok_button.UserData = struct;
ok_button.UserData.TickHandles = TickHandles;
ok_button.UserData.Values = OutValues;

ok_button.Callback = @updateOutValues;
uiwait(gcf)

load OutValues                                                                                                      % load updated values
OutConditions = Conditions(find(OutValues)); % without "find does not work"

delete OutValues.mat                                                                                                % delete updata

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateOutValues(src,events)                                                                                % function to update the values of the tick boxes

NConditions = length(src.UserData.Values);
OutValues = src.UserData.Values;

for i = 1:NConditions                                                                                               % loop throug all contidions and check wheter or not box is ticked
    OutValues(i) = src.UserData.TickHandles(i).Value;
end
src.UserData.Values = OutValues;
save OutValues OutValues                                                                                            % save reasults in a mat file to be used outside the function

close(gcf)

