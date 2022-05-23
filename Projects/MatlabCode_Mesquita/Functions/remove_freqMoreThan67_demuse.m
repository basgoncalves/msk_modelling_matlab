
% remove_freqMoreThan67_demuse

for MU = 1: length (MUPulses)               % loop through the motor units
    close all
    Vector = find(InstantFreqVect(:,MU));                   % find the index of frequencies diffrerent than 0
    
    CutFreq = find(InstantFreqVect(Vector(:),MU)>67);           % find frequencies greater than 67 Hz
    %     figure ('Position', [100 300 500 500])
    %     plot (FreqSpikes(:,col))
    %     line([0,length(FreqSpikes)],[67,67]);
    
    
    InstantFreqVect(Vector(CutFreq(:)),MU)=0;
    %     figure ('Position', [600 300 500 500])
    %     plot (FreqSpikes(:,col))
    %     line([0,length(FreqSpikes)],[67,67]);
    
    InstantFreqVect_Long(:,MU) = InstantFreqVect(:,MU);
    Vector = find(InstantFreqVect(:,MU));                       % find the "ones"
    Vector (end+1,:) = 0;                                   % add a Zero row at the end of Spikes to Run the Imstataneous Frequency
    for row = 1: length (Vector)                         % loop through all the Spikes of each channel
        X1 = Vector (row,1);
        X2 = Vector (row+1,1);
        if X1 ==0 || X2 == 0                             % if Spikes are different than Zero
            InstantFreqVect_Long(X1,MU) = InstantFreq;           % use the same fquency as the last point
            break                                           % end loop
        else                                             % if X1 or X2 = zero
            InstantFreq = InstantFreqVect(X2,MU);               % "instantaneous" frequecy
            InstantFreqVect_Long(X1:X2,MU) = InstantFreq;
        end
    end
    %     figure ('Position', [1100 300 500 500])
    %     plot (FreqSpikesLong(:,col))
    %     line([0,length(FreqSpikes)],[67,67]);
end

clear HighFreq InstantFreq