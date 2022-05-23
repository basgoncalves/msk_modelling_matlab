%% Description --  Goncalves, BM (2019)
%
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% --------------------------------------
%OUTPUT
%   PolynomialData = Double with with the same number of channels as
%   inputData 
%
%   .mat = all the data used in the function and all the plots in one
%   figure
%   .txt = text file with PolynomialData
%   .xls = excel comaptible file with PolynomialData
%
%% Start Function
function PolynomialData = FrequencySpikes

close all                                           % close all figures
%% select file
[filename, pathname] = uigetfile('*.mat');
cd (pathname);
load (filename);

%%  Get Data and assign basic parameters

[nRow, nCol] = size (Data);
fs = SamplingFrequency;
Spikes = zeros(1,nCol);                                 % Index of the spikes for each channel

for col = 1: nCol                                         % loop through all the channels
    Vector = find(Data(:,col));                           % find the "ones"
    [yVect, xVect] = size (Vector);
    Spikes (1:yVect,col) = Vector;                        % add each index to the "Spikes" double
end

Spikes (end+1,:) = 0;                                   % add a Zero row at the end of Spikes to Run the Imstataneous Frequency
%% Frquency of spikes
FreqSpikes= Data;
FreqSpikesLong = Data;
for col = 1: nCol                                         % loop through all the channels
    Vector = Spikes (:,col);
    for row = 1: length (Vector)                         % loop through all the Spikes of each channel
        X1 = Vector (row,1);
        X2 = Vector (row+1,1);
        if X1 ==0 || X2 == 0                             % if Spikes are different than Zero
            if InstantFreq <= 4
                InstantFreq = 0; 
            end
            FreqSpikes(X1,col) = InstantFreq;               % use the same fquency as the last point
            FreqSpikesLong(X1,col) = InstantFreq;               % use the same fquency as the last point
            break                                            % end loop
        else                                             % if X1 or X2 = zero
            TimeBTWSamples = (X2-X1)/fs;                     % time between samples
            InstantFreq = 1 / TimeBTWSamples;                % "instantaneous" frequecy
            FreqSpikes(X1,col) = InstantFreq;
            FreqSpikesLong(X1:X2,col) = InstantFreq;
        end
    end

end

%% Remove first spike if it's less than 4Hz

for col = 1: nCol                                       % loop through all the channels
    Vector = find(FreqSpikes(:,col));                   % find the cells diffrerent than 0
    
    while FreqSpikes(Vector(1),col) <= 4                % check if the first spike is <4Hz
       FreqSpikes(Vector(1),col) = 0;
       Vector = find(FreqSpikes(:,col)); 
    end
    Vector = find(FreqSpikes(:,col));                   % find the cells diffrerent than 0
    FreqSpikesLong(1:Vector(1)-1,col)=0;                % all the spikes before the last spike >4Hz = 0
    
                  
    while FreqSpikes(Vector(end),col) <= 4              % check if the last spike is <4Hz
       FreqSpikes(Vector(end),col) = 0;
       Vector = find(FreqSpikes(:,col)); 
    end
    Vector = find(FreqSpikes(:,col));                   % find the cells diffrerent than 0
    FreqSpikesLong(Vector(end)+1:end,col)=0;            % all the spikes after the last spike >4Hz = 0
    
end

%% polynomial fit
PolynomialData = FreqSpikes;


for  col = 1: nCol                                  % loop through all the channels
Vector = FreqSpikesLong (:,col);                    % plateus to use on the polynomial function    
Vector2 = FreqSpikes (:,col);                       % individual spikes for the graph



SpikesCol = find(FreqSpikes(:,col));
InitialSpike = SpikesCol (1);
FinalSpike = SpikesCol (end);

x = (InitialSpike:1:FinalSpike)';
y = Vector (InitialSpike: FinalSpike);

if length (x)<10000
    PolDegree = 3;                              % polynomial degree
else
    PolDegree = 5;                              % polynomial degree
end             

p = polyfit(x,y,PolDegree);                 % polynomial fucntion (https://au.mathworks.com/help/matlab/ref/polyfit.html#bue6sxq-1-y)

y1 = polyval(p,x);
y = Vector2 (InitialSpike:FinalSpike);

PolynomialData (InitialSpike:FinalSpike, col) = y1;


% figure
Figure.Polyn(col) = figure('WindowStyle', 'docked', ...
      'Name', sprintf('Channel number %d', col), 'NumberTitle', 'off');   
    plot(x,y,'o')
    % plot(xNoZeros,yNoZeros,'o')
    hold on
plot(x,y1)
hold off

% plot parameters
    xlim([0 length(Vector)]);                                               % limits of the x axis

    Nsamples = length (Vector);                                              % number of samples
    time = round(Nsamples/fs,2); 
%     xticks(0:Nsamples/5:Nsamples);                                         % devide the length of X axis in 5 equal parts (https://au.mathworks.com/help/matlab/creating_plots/change-tick-marks-and-tick-labels-of-graph-1.html)
%     xticklabels(0:time/5:time);                                            % rename the X labels with the time in sec 
    
    xlabel ('Samples');
    ylabel ('Frequency Hz)');
    title (sprintf('Channel number %d', col))
end

%% save data
filename = inputdlg...
        ('Type the name for the excel file or type nothing if you do not want to save' );
    if isempty (filename{1})~=1
        currentFolder = cd;
        newFolder = sprintf('%s\\%s',currentFolder,filename{1});
        mkdir (newFolder);
        cd (newFolder);
        save (filename{1});                                              % save data with the name given
        
        filenameTxt = sprintf ('%s.txt', filename{1});                     % save .txt
        dlmwrite(filenameTxt,PolynomialData);
        
        filenameXls = sprintf ('%s.xls', filename{1});                     % save .xls
        xlswrite(filenameXls,PolynomialData);
    end
    

    

   