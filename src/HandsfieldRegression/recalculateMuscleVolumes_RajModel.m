function [mInfo] = recalculateMuscleVolumes_RajModel(nM, mInfo, tV)

% Recalculate volume for specific muscles
for ii = 1:nM
    if mInfo(ii).b1 ~= 0 && mInfo(ii).b2 ~=0
    else;  mInfo(ii).updatedVolume = mInfo(ii).presentVolume; continue
    end
    
    mInfo(ii).updatedVolume = ((mInfo(ii).b1) * tV) + mInfo(ii).b2;
    
    mInfo=PreserveVolumesRatios(mInfo,ii,[3:6]); % adductor magnus right
    mInfo=PreserveVolumesRatios(mInfo,ii,[15:17]); % gmax right
    mInfo=PreserveVolumesRatios(mInfo,ii,[18:20]); % gmed right
    mInfo=PreserveVolumesRatios(mInfo,ii,[21:23]); % gmin right
    mInfo=PreserveVolumesRatios(mInfo,ii,[26:27]); % peroneus right
   
    mInfo=PreserveVolumesRatios(mInfo,ii,[43:46]); % adductor magnus left
    mInfo=PreserveVolumesRatios(mInfo,ii,[55:57]); % gmax left
    mInfo=PreserveVolumesRatios(mInfo,ii,[18:20]); % gmed left
    mInfo=PreserveVolumesRatios(mInfo,ii,[21:23]); % gmin left
    mInfo=PreserveVolumesRatios(mInfo,ii,[26:27]); % peroneus left
end

    function mInfo=PreserveVolumesRatios(mInfo,ii,MuscleRows)  % distributing right gluteal medius volumes proportionately
        if any(ii == MuscleRows)
            ratio = mInfo(ii).presentVolume/sum([mInfo(MuscleRows).presentVolume]);
            mInfo(ii).updatedVolume = mInfo(ii).updatedVolume * ratio;
        end
    end
end
