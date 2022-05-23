%% Description --  Goncalves, BM (2019)
%
% https://www.researchgate.net/profile/Basilio_Goncalves
%

function FrequencySpikes 

%% select file
[filename, pathname] = uigetfile('*.mat');
cd (pathname);
load (filename);

%%
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
FreqSpikes= [];
for col = 1: nCol                                         % loop through all the channels
    Vector = Spikes (:,col);
    for row = 1: length (Vector)                         % loop through all the Spikes of each channel
        X1 = Vector (row,1);
        X2 = Vector (row+1,1);
        if X1 ==0 || X2 == 0                             % if Spikes are different than Zero
            if InstantFreq <= 4
                InstantFreq = 0; 
            end
            FreqSpikes(row,col) = InstantFreq;               % use the same fquency as the last point
            break                                            % end loop
        else                                             % if X1 or X2 = zero
            TimeBTWSamples = (X2-X1)/fs;                     % time between samples
            InstantFreq = 1 / TimeBTWSamples;                % "instantaneous" frequecy
            FreqSpikes(row,col) = InstantFreq;
        end
    end
    
    if FreqSpikes(1,col) <= 4
       FreqSpikes(1,col) = 0;  
    end

end


%% polynomial fit

for  col = 1: nCol                                  % loop through all the channels
Vector = FreqSpikes (:,col);
Vector (Vector ==0) = [];                           % delete zeros

SpikesCol = Spikes (:,col);
SpikesCol(SpikesCol==0) = [];

x = linspace(0,length (Vector),length (Vector))';
y = Vector;


n = 5;                              % polynomial degree             
p = polyfit(x,y,n);          % polynomial fucntion (https://au.mathworks.com/help/matlab/ref/polyfit.html#bue6sxq-1-y)

x1 = linspace(0,length (Vector));
y1 = polyval(p,x1);

% figure
Figure.Polyn(col) = figure('WindowStyle', 'docked', ...
      'Name', sprintf('Channel number %d', col), 'NumberTitle', 'off');   
plot(x,y,'o')
hold on
plot(x1,y1)
hold off

% plot parameters
%     Nsamples = length (Vector);                                              % number of samples
%     time = round(Nsamples/fs,2); 
    xlabel ('Samples');
    ylabel ('Frequency Hz)');
    title (sprintf('Channel number %d', col))
end

filename = inputdlg...
        ('Type the name for the excel file or type nothing if you do not want to save' );
    if isempty (filename{1})~=1
        save (filename{1});                                              % save data with the name given
    end
    