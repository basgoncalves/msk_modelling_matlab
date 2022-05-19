% Create multiple bland altmand plots and copy them to one single docked figure 
%
% REFERENCES
%   https://stackoverflow.com/questions/18477705/plotting-an-existing-matlab-plot-into-another-figure
%   

function MultiBlandAltman (TotalData,description)
[~,Ntrials] = size (TotalData);

Pairs = 1:2:Ntrials;                                   

Condition = 1;

for Trial = Pairs                                                      % run through every second data column 
                                                                      % remove semicolon to debug and find the trial that is giving error
    data = TotalData (:,Trial:Trial+1);
    data(data==0) = NaN;                                       %remove Zeros (https://au.mathworks.com/matlabcentral/answers/6038-convert-zeros-to-nan)
    data = rmmissing(data);                                    % delete all the rows with NaN 
    Figure.BAplot(Trial) = figure('WindowStyle', 'docked', ...
      'Name', sprintf('%s', description{Condition}), 'NumberTitle', 'off');     
    [baAH,fig] = BlandAltman_BG(data);
    hc = get (fig,'children');
    copyobj(hc,Figure.BAplot(Trial))    
    saveas(fig,description{Condition},'tiff');
    savefig (fig,description{Condition});
    mmfn
    Condition = Condition+1;
%     close (fig)
end

save BAplotsAll_NoOutliers