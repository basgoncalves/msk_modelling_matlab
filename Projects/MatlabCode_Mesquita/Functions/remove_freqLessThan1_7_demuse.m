
% remove_freqLessThan1_7_demuse

for MU = 1: length (MUPulses)               % loop through the motor units
    close all
    Vector = find(InstantFreqVect(:,MU));                   % find the index of frequencies diffrerent than 0
    
    LowFreq = find(InstantFreqVect(Vector(:),MU)<1.7);           % find frequencies lower that 1.7Hz
    %   figure ('Position', [300 300 500 500])
    %   plot (FreqSpikes(:,col))
    
    InstantFreqVect(Vector(LowFreq(:)),MU)=0;
    %   figure ('Position', [900 300 500 500])
    %   plot (FreqSpikes(:,col))
    %   line([0,length(FreqSpikes)],[1.7,1.7]);
    %
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
    
end

clear LowFreq InstantFreq