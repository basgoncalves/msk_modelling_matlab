% plot EMG mean with indvidual values for different trials
%
% INPUT
%	ydata = MxN double matrix with N
%   LabelsBar = name of each barplot
%   ColorDots (optional)= vector with index of individual(s) to use plot
%   with color; IF NOT USED all data points will have different colors

function br = Plot_meanWindividual(ydata,LabelsBar,ColorDots,DotSize,NoIndividualData)

cla % clear content of the plot
if ~exist('DotSize')
    DotSize= 20;
    fprintf('default scatter size = %.f \n',DotSize)
end
if ~exist('ColorDots')
    ColorDots= [];
elseif ~contains(class(ColorDots),'double')
    error('variable "ColorDots" should be a double')
end

[Nsubjects, Nchannels] = size(ydata);
xdata = repmat(1:Nchannels, Nsubjects, 1);

if Nchannels~=length(LabelsBar)
    sprintf('size of ydata and Channels do not match')
    return
end


MeanEMG = nanmean(ydata);
CI = (nanstd(ydata)/sqrt(Nsubjects))*1.96;


% plot bar graph (NOTE: use multiple plots to make it easier to index
% legend)
br(1) = bar(xdata(1,:),nanmean(ydata),'DisplayName',...
    'cell2mat(MeanStrengthDifference(2:end,:))','FaceColor',[160/255 160/255 160/255]);          %check colors https://www.rapidtables.com/web/color/RGB_Color.html
hold on

% Create error bar vectors (positive and negative)
PositiveCI = CI;
NegativeCI = CI;
for ii = 1: length(MeanEMG)
    if MeanEMG <0
        PositiveCI(ii)= 0;
    else
        NegativeCI(ii)=0;
    end
end

br(2) = errorbar(xdata(1,:),MeanEMG,NegativeCI,PositiveCI,'color','k');               % error bar = (x,y,Lower,Upper)
br(2).LineStyle = 'none';
colors = [42:5:120];
countcolor = 1;
if nargin > 2 && nargin < 5
    % plot all the individual data 
    f1 = figure;
    [xPositions, yPositions, Label, RangeCut] = UnivarScatter(ydata);           %  version: <1.00> from 30/11/2015  Manuel Lera Ramírez: manulera14@gmail.com
    close (f1)
    
    
    for ii= 1: size(ydata,1)
       if ~ismember(ii,ColorDots)
        br(ii+2)=scatter(xPositions(ii,:), yPositions(ii,:),DotSize,...
            'MarkerEdgeColor','none',...
            'MarkerFaceColor',[0.00,0.45,0.74]);          % plot blue   
       
        end
    end
    
    % plot data of particulat individual in differenr color
    % do a different loop so they can be in front on the plot
    for ii= 1: size(ydata,1)
        c=[colorcube;colorcube]; % color - https://au.mathworks.com/help/matlab/colors-1.html
        if ismember(ii,ColorDots)
            br(ii+2)=scatter(xPositions(ii,:), yPositions(ii,:),DotSize*4,...
                'MarkerEdgeColor','none',...
                'MarkerFaceColor',c(colors(countcolor),:));         % plot colored dots 44= red; 50=green 60= blue;
            countcolor = countcolor +1;
        end
    end  
   
else
     % plot data of particulat individual in differenr color
    % do a different loop so they can be in front on the plot
    
    f1 = figure;
    [xPositions, yPositions, Label, RangeCut] = UnivarScatter(ydata);           %  version: <1.00> from 30/11/2015  Manuel Lera Ramírez: manulera14@gmail.com
    close (f1)
    
    
    for ii= 1: size(ydata,1)
        c=[colorcube;colorcube]; % color - https://au.mathworks.com/help/matlab/colors-1.html
        if ismember(ii,ColorDots)
            xPositions = br(1).XData;
            br(ii+2)=scatter(xPositions, yPositions(ii,:),DotSize*4,...
                'MarkerEdgeColor','none',...
                'MarkerFaceColor',c(colors(countcolor),:));         % plot colored dots 44= red; 50=green 60= blue;
            countcolor = countcolor +1;
        end
    end  
    
   
end


% [Nsubjects, ~] = size(ydata(all(~isnan(ydata),2),:));               % number of subject without NaN
% title (sprintf('Data for %.f subjects',Nsubjects));
xticks(1:length(LabelsBar));
xticklabels(LabelsBar(1,1:end));
xtickangle(45);
