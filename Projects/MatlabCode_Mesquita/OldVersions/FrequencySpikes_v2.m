%% Description --  Goncalves, BAM (2019)
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
% --------------------------------------
%UPDATES
%   8/11/19 - Basilio Goncalves 
%             added Frequency_Whole,  Frequency_WholeLong, Frequency without first 3 spikes
%             Frequency without first 3 spikes, polynomial fit Without first 3 spikes
%   10/11/19 - Basilio Goncalves
%             remove part of the data that does not contain motor unit
%             rcruitment data 
%
%% Start Function
function PlynomialData = FrequencySpikes_v2

close all                                           % close all figures
%% select file
[Originalfilename, pathname] = uigetfile('*.mat');
cd (pathname);
load (Originalfilename);
tic 
%%  Get Data and assign basic parameters
idxNonEMG = [];
for i = 1:size (Description,1)                          % loop though all the description labels 
    if ~contains (Description{i},'Decomposition')
        idxNonEMG(end+1)= i;
    end
end
ForceChannel = Data(:,idxNonEMG);
Data(:,idxNonEMG)=[];                                   % delete those that are not  EMG channels 

[nRow, nCol] = size (Data);
fs = SamplingFrequency;
Spikes = zeros(1,nCol);                                 % Index of the spikes for each channel

for col = 1: nCol                                         % loop through all the channels
    Vector = find(Data(:,col));                           % find the "ones"
    [yVect, xVect] = size (Vector);
    Spikes (1:yVect,col) = Vector;                        % add each index to the "Spikes" double
end

Spikes (end+1,:) = 0;                                   % add a Zero row at the end of Spikes to Run the Imstataneous Frequency

%%  cut data 
NaNSpikes = Spikes;
NaNSpikes(NaNSpikes==0) =NaN;

MaxSpikes = max (max(NaNSpikes));                          % find the max index of the spikes = last spike of a motor unit
MinSpikes = min (min(NaNSpikes));
Data = Data (MinSpikes-5*fs:MaxSpikes+5*fs,:);
ForceChannel = ForceChannel (MinSpikes-5*fs:MaxSpikes+5*fs,:);

%% Create spikes again
[nRow, nCol] = size (Data);
fs = SamplingFrequency;
Spikes = zeros(1,nCol);                                 % Index of the spikes for each channel

for col = 1: nCol                                         % loop through all the channels
    Vector = find(Data(:,col));                           % find the "ones"
    [yVect, xVect] = size (Vector);
    Spikes (1:yVect,col) = Vector;                        % add each index to the "Spikes" double
end

Spikes (end+1,:) = 0;           

%% Frquency of spikes
FreqSpikes= Data;
FreqSpikesLong = Data;
for col = 1: nCol                                         % loop through all the channels
    Vector = Spikes (:,col);
    for row = 1: length (Vector)                         % loop through all the Spikes of each channel
        X1 = Vector (row,1);
        X2 = Vector (row+1,1);
        if X1 ==0 || X2 == 0                             % if X1 or X2 = zero
            %             if InstantFreq <= 4
            %                 InstantFreq = 0;
            %             end
            FreqSpikes(X1,col) = InstantFreq;               % use the same fquency as the last point
            FreqSpikesLong(X1,col) = InstantFreq;           % use the same fquency as the last point
            break                                           % end loop
        else                                             % if Spikes are different than Zero
            TimeBTWSamples = (X2-X1)/fs;                    % time between samples
            InstantFreq = 1 / TimeBTWSamples;               % "instantaneous" frequecy
            FreqSpikes(X1,col) = InstantFreq;
            FreqSpikesLong(X1:X2,col) = InstantFreq;
        end
    end
    
end

Frequency_Whole = FreqSpikes;
Frequency_WholeLong = FreqSpikesLong;
%% Remove all frequencies <1.7Hz

for col = 1: nCol                                       % loop through all the channels
    close all
    Vector = find(FreqSpikes(:,col));                   % find the index of frequencies diffrerent than 0
    
    LowFreq = find(FreqSpikes(Vector(:),col)<1.7);           % find frequencies lower that 1.7Hz
    %   figure ('Position', [300 300 500 500])
    %   plot (FreqSpikes(:,col))
    
    FreqSpikes(Vector(LowFreq(:)),col)=0;
    %   figure ('Position', [900 300 500 500])
    %   plot (FreqSpikes(:,col))
    %   line([0,length(FreqSpikes)],[1.7,1.7]);
    %
    FreqSpikesLong(:,col) = FreqSpikes(:,col);
    Vector = find(FreqSpikes(:,col));                       % find the "ones"
    Vector (end+1,:) = 0;                                   % add a Zero row at the end of Spikes to Run the Imstataneous Frequency
    for row = 1: length (Vector)                         % loop through all the Spikes of each channel
        X1 = Vector (row,1);
        X2 = Vector (row+1,1);
        if X1 ==0 || X2 == 0                             % if Spikes are different than Zero
            FreqSpikesLong(X1,col) = InstantFreq;           % use the same fquency as the last point
            break                                           % end loop
        else                                             % if X1 or X2 = zero
            InstantFreq = FreqSpikes(X1,col);               % "instantaneous" frequecy
            FreqSpikesLong(X1:X2,col) = InstantFreq;
        end
    end
    
end

Frequency_Lower_17 = FreqSpikes;
Frequency_Lower_17(:,end+1) = ForceChannel;                           % add the force 
clear LowFreq InstantFreq
%% Remove all frequencies >67Hz - 17/04/2019

for col = 1: nCol                                       % loop through all the channels
    close all
    Vector = find(FreqSpikes(:,col));                   % find the index of frequencies diffrerent than 0
    
    HighFreq = find(FreqSpikes(Vector(:),col)>67);           % find frequencies greater than 67 Hz
%     figure ('Position', [100 300 500 500])
%     plot (FreqSpikes(:,col))
%     line([0,length(FreqSpikes)],[67,67]);


    FreqSpikes(Vector(HighFreq(:)),col)=0;
%     figure ('Position', [600 300 500 500])
%     plot (FreqSpikes(:,col))
%     line([0,length(FreqSpikes)],[67,67]);
    
    FreqSpikesLong(:,col) = FreqSpikes(:,col);
    Vector = find(FreqSpikes(:,col));                       % find the "ones"
    Vector (end+1,:) = 0;                                   % add a Zero row at the end of Spikes to Run the Imstataneous Frequency
    for row = 1: length (Vector)                         % loop through all the Spikes of each channel
        X1 = Vector (row,1);
        X2 = Vector (row+1,1);
        if X1 ==0 || X2 == 0                             % if Spikes are different than Zero
            FreqSpikesLong(X1,col) = InstantFreq;           % use the same fquency as the last point
            break                                           % end loop
        else                                             % if X1 or X2 = zero
            InstantFreq = FreqSpikes(X1,col);               % "instantaneous" frequecy
            FreqSpikesLong(X1:X2,col) = InstantFreq;
        end
    end
%     figure ('Position', [1100 300 500 500])
%     plot (FreqSpikesLong(:,col))
%     line([0,length(FreqSpikes)],[67,67]);
end

clear LowFreq InstantFreq
%% Frequency without first 3 spikes

for col = 1: nCol                                       % loop through all the channels
    close all
    Vector = find(FreqSpikes(:,col));                   % find the index of frequencies diffrerent than 0
    Frequency_Minus3 = FreqSpikes;
    
    FirstThreeSpikes = find(FreqSpikes(Vector(1:3),col));           % remove first 3 spikes frequencies   
    Frequency_Minus3(Vector(FirstThreeSpikes(:)),col)=0;
   
    Frequency_Minus3Long(:,col) = Frequency_Minus3(:,col);
    Vector = find(Frequency_Minus3(:,col));                       % find the "ones"
    Vector (end+1,:) = 0;                                   % add a Zero row at the end of Spikes to Run the Imstataneous Frequency
    for row = 1: length (Vector)                         % loop through all the Spikes of each channel
        X1 = Vector (row,1);
        X2 = Vector (row+1,1);
        if X1 ==0 || X2 == 0                             % if Spikes are different than Zero
            Frequency_Minus3Long(X1,col) = InstantFreq;           % use the same fquency as the last point
            break                                           % end loop
        else                                             % if X1 or X2 = zero
            InstantFreq = Frequency_Minus3(X1,col);               % "instantaneous" frequecy
            Frequency_Minus3Long(X1:X2,col) = InstantFreq;
        end
    end
    
end

Frequency_Minus3(:,end+1) = ForceChannel;                           % add the force 
clear FirstThreeSpikes InstantFreq
%% polynomial fit _ between 1.7Hz and 67Hz
PolynomialData_cropped = FreqSpikes;
   PolDegree = inputdlg({'Choose ploynomial degree (eg. 5)'},'Input',[1 45],{'5'});  % polynomial degree with user input
    PolDegree = str2double(PolDegree{1});


for  col = 1: nCol                                  % loop through all the channels
    Vector = FreqSpikesLong (:,col);                    % plateus to use on the polynomial function
    Vector2 = FreqSpikes (:,col);                       % individual spikes for the graph
    
    
    SpikesCol = find(FreqSpikes(:,col));
    InitialSpike = SpikesCol (1);
    FinalSpike = SpikesCol (end);
    
    x = (InitialSpike:1:FinalSpike)';
    y = Vector (InitialSpike: FinalSpike);
    
    p = polyfit(x,y,PolDegree);                 % polynomial fucntion (https://au.mathworks.com/help/matlab/ref/polyfit.html#bue6sxq-1-y)
    
    y1 = polyval(p,x);
    y = Vector2 (InitialSpike:FinalSpike);
    
    PolynomialData_cropped (InitialSpike:FinalSpike, col) = y1;
   
    
end

PolynomialData_cropped(:,end) = ForceChannel;                                       % add the force vector at the end of PolynomialData

clear time y1 y p x SpikesCol InitialSpike FinalSpike Nsamples Vector Vector2

%% polynomial fit Without first 3 spikes
PolynomialData_WithoutFirst3 = Frequency_Minus3;


for  col = 1: nCol                                  % loop through all the channels
    Vector = Frequency_Minus3Long (:,col);                    % plateus to use on the polynomial function
    Vector2 = Frequency_Minus3 (:,col);                       % individual spikes for the graph
    
    
    SpikesCol = find(Frequency_Minus3(:,col));
    InitialSpike = SpikesCol (1);
    FinalSpike = SpikesCol (end);
    
    x = (InitialSpike:1:FinalSpike)';
    y = Vector (InitialSpike: FinalSpike);
    
    
    p = polyfit(x,y,PolDegree);                 % polynomial fucntion (https://au.mathworks.com/help/matlab/ref/polyfit.html#bue6sxq-1-y)
    
    y1 = polyval(p,x);
    y = Vector2 (InitialSpike:FinalSpike);
    
    PolynomialData_WithoutFirst3 (InitialSpike:FinalSpike, col) = y1;
        
end

PolynomialData_WithoutFirst3(:,end) = ForceChannel;                                       % add the force vector at the end of PolynomialData

clear time y1 y p x SpikesCol InitialSpike FinalSpike Nsamples Vector Vector2

%% save data
prompt = {'Type the name for the excel file or type nothing if you do not want to save' };
dlgtitle = 'Input';
dims = [1 90];
Originalfilename = erase(Originalfilename,'.mat');
definput = {sprintf('%s-results',Originalfilename)};


filename = inputdlg(prompt,dlgtitle,dims,[definput '.mat']);
if isempty (filename{1})~=1
    currentFolder = cd;
    newFolder = sprintf('%s\\%s',currentFolder,'results');
    mkdir (newFolder);
    cd (newFolder);
    save (filename{1}, 'PolynomialData_cropped' , 'PolynomialData_WithoutFirst3', 'Frequency_Lower_17');                                              % save data with the name given
    
    %create output in a mat format
    PlynomialData = struct;
    PlynomialData.PolynomialData_cropped=PolynomialData_cropped;
    PlynomialData.PolynomialData_WithoutFirst3=PolynomialData_WithoutFirst3;
    PlynomialData.Frequency_Lower_17=Frequency_Lower_17;
      
    % save data in excel
    f = waitbar(0,'Please wait...');
     
    filenameXls = sprintf ('%s_InstantFrequency_bellow17.xlsx', filename{1});                    % save .xls =  intasnt frequency without those below 1.7Hz
    xlswrite(filenameXls,Frequency_Lower_17);
    waitbar(.33,f,'Loading your data');
    
    filenameXls = sprintf ('%s_cropped.xlsx', filename{1});                     % save .xls = Nth degree plynomial without frequeencies below 1.7Hz and above 67Hz
    xlswrite(filenameXls,PolynomialData_cropped);
    waitbar(.67,f,'Processing your data');
    
    filenameXls = sprintf ('%s_NoFirstThree.xlsx', filename{1});                % save .xls = Nth degree plynomial without frequeencies below 1.7Hz and above 67Hz AND without first 3 firings
    xlswrite(filenameXls,  PolynomialData_WithoutFirst3);
    waitbar(1,f,'Excel data saved');
%     
    
end




