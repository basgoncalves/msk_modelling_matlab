
function [FreqSpikes,FreqSpikesLong] = CalculateFrequency(Data,fs)


%% Create spikes again
[nRow, nCol] = size (Data);
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
            FreqSpikes(X2,col) = InstantFreq;
            FreqSpikesLong(X1:X2,col) = InstantFreq;
        end
    end
    
end