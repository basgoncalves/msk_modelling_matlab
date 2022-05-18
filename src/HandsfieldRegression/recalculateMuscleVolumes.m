function [mInfo] = recalculateMuscleVolumes(nM, mInfo, tV)

% Recalculate volume for specific muscles
for ii = 0:nM-1
    if mInfo(ii+1).b1 ~= 0 && mInfo(ii+1).b2 ~=0
        mInfo(ii+1).updatedVolume = ((mInfo(ii+1).b1) * tV) + mInfo(ii+1).b2;
        
        % distributing right gluteal medius volumes proportionately
        % Please see muscleInfo structure for indexing info
        % all of this goes inside a function
        
        if (ii == 0)
            mInfo(ii+1).updatedVolume = mInfo(ii+1).updatedVolume * (mInfo(ii+1).presentVolume/(mInfo(ii+1).presentVolume ...
                + mInfo(ii+2).presentVolume + mInfo(ii+3).presentVolume));
        elseif (ii == 1)
            mInfo(ii+1).updatedVolume = mInfo(ii+1).updatedVolume * (mInfo(ii+1).presentVolume/(mInfo(ii).presentVolume ...
                + mInfo(ii+1).presentVolume + mInfo(ii+2).presentVolume));
        elseif (ii == 2)
            mInfo(ii+1).updatedVolume = mInfo(ii+1).updatedVolume * (mInfo(ii+1).presentVolume/(mInfo(ii-1).presentVolume ...
                + mInfo(ii).presentVolume + mInfo(ii+1).presentVolume));
        end
        
        % distributing left gluteal medius volumes proportionately
        % Please see muscleInfo structure for indexing info
        % all of this goes inside a function
        
        if (ii == 43)
            mInfo(ii+1).updatedVolume = mInfo(ii+1).updatedVolume * (mInfo(ii+1).presentVolume/(mInfo(ii+1).presentVolume ...
                + mInfo(ii+2).presentVolume + mInfo(ii+3).presentVolume));
        elseif (ii == 44)
            mInfo(ii+1).updatedVolume = mInfo(ii+1).updatedVolume * (mInfo(ii+1).presentVolume/(mInfo(ii).presentVolume ...
                + mInfo(ii+1).presentVolume + mInfo(ii+2).presentVolume));
        elseif (ii == 45)
            mInfo(ii+1).updatedVolume = mInfo(ii+1).updatedVolume * (mInfo(ii+1).presentVolume/(mInfo(ii-1).presentVolume ...
                + mInfo(ii).presentVolume + mInfo(ii+1).presentVolume));
        end
        
        % distributing right gluteus minimus volumes proportionately
        % Please see muscleInfo structure for indexing info
        % all of this goes inside a function
        
        if (ii == 3)
            mInfo(ii+1).updatedVolume = mInfo(ii+1).updatedVolume * (mInfo(ii+1).presentVolume/(mInfo(ii+1).presentVolume ...
                + mInfo(ii+2).presentVolume + mInfo(ii+3).presentVolume));
        elseif (ii == 4)
            mInfo(ii+1).updatedVolume = mInfo(ii+1).updatedVolume * (mInfo(ii+1).presentVolume/(mInfo(ii).presentVolume ...
                + mInfo(ii+1).presentVolume + mInfo(ii+2).presentVolume));
        elseif (ii == 5)
            mInfo(ii+1).updatedVolume = mInfo(ii+1).updatedVolume * (mInfo(ii+1).presentVolume/(mInfo(ii-1).presentVolume ...
                + mInfo(ii).presentVolume + mInfo(ii+1).presentVolume));
        end
        
        % distributing right gluteus minimus volumes proportionately
        % Please see muscleInfo structure for indexing info
        % all of this goes inside a function
        
        if (ii == 46)
            mInfo(ii+1).updatedVolume = mInfo(ii+1).updatedVolume * (mInfo(ii+1).presentVolume/(mInfo(ii+1).presentVolume ...
                + mInfo(ii+2).presentVolume + mInfo(ii+3).presentVolume));
        elseif (ii == 47)
            mInfo(ii+1).updatedVolume = mInfo(ii+1).updatedVolume * (mInfo(ii+1).presentVolume/(mInfo(ii).presentVolume ...
                + mInfo(ii+1).presentVolume + mInfo(ii+2).presentVolume));
        elseif (ii == 48)
            mInfo(ii+1).updatedVolume = mInfo(ii+1).updatedVolume * (mInfo(ii+1).presentVolume/(mInfo(ii-1).presentVolume ...
                + mInfo(ii).presentVolume + mInfo(ii+1).presentVolume));
        end
        
        % distributing right adductor magnus volumes proportionately
        % Please see muscleInfo structure for indexing info
        % all of this goes inside a function
        
        if (ii == 13)
            mInfo(ii+1).updatedVolume = mInfo(ii+1).updatedVolume * (mInfo(ii+1).presentVolume/(mInfo(ii+1).presentVolume ...
                + mInfo(ii+2).presentVolume + mInfo(ii+3).presentVolume));
        elseif (ii == 14)
            mInfo(ii+1).updatedVolume = mInfo(ii+1).updatedVolume * (mInfo(ii+1).presentVolume/(mInfo(ii).presentVolume ...
                + mInfo(ii+1).presentVolume + mInfo(ii+2).presentVolume));
        elseif (ii == 15)
            mInfo(ii+1).updatedVolume = mInfo(ii+1).updatedVolume * (mInfo(ii+1).presentVolume/(mInfo(ii-1).presentVolume ...
                + mInfo(ii).presentVolume + mInfo(ii+1).presentVolume));
        end
        
        % distributing left adductor magnus volumes proportionately
        % Please see muscleInfo structure for indexing info
        % all of this goes inside a function
        
        if (ii == 56)
            mInfo(ii+1).updatedVolume = mInfo(ii+1).updatedVolume * (mInfo(ii+1).presentVolume/(mInfo(ii+1).presentVolume ...
                + mInfo(ii+2).presentVolume + mInfo(ii+3).presentVolume));
        elseif (ii == 57)
            mInfo(ii+1).updatedVolume = mInfo(ii+1).updatedVolume * (mInfo(ii+1).presentVolume/(mInfo(ii).presentVolume ...
                + mInfo(ii+1).presentVolume + mInfo(ii+2).presentVolume));
        elseif (ii == 58)
            mInfo(ii+1).updatedVolume = mInfo(ii+1).updatedVolume * (mInfo(ii+1).presentVolume/(mInfo(ii-1).presentVolume ...
                + mInfo(ii).presentVolume + mInfo(ii+1).presentVolume));
        end
        
        % distributing right gluteus maximus volumes proportionately
        % Please see muscleInfo structure for indexing info
        % all of this goes inside a function
        
        if (ii == 19)
            mInfo(ii+1).updatedVolume = mInfo(ii+1).updatedVolume * (mInfo(ii+1).presentVolume/(mInfo(ii+1).presentVolume ...
                + mInfo(ii+2).presentVolume + mInfo(ii+3).presentVolume));
        elseif (ii == 20)
            mInfo(ii+1).updatedVolume = mInfo(ii+1).updatedVolume * (mInfo(ii+1).presentVolume/(mInfo(ii).presentVolume ...
                + mInfo(ii+1).presentVolume + mInfo(ii+2).presentVolume));
        elseif (ii == 21)
            mInfo(ii+1).updatedVolume = mInfo(ii+1).updatedVolume * (mInfo(ii+1).presentVolume/(mInfo(ii-1).presentVolume ...
                + mInfo(ii).presentVolume + mInfo(ii+1).presentVolume));
        end
        
        % distributing left gluteus maximus volumes proportionately
        % Please see muscleInfo structure for indexing info
        % all of this goes inside a function
        
        if (ii == 62)
            mInfo(ii+1).updatedVolume = mInfo(ii+1).updatedVolume * (mInfo(ii+1).presentVolume/(mInfo(ii+1).presentVolume ...
                + mInfo(ii+2).presentVolume + mInfo(ii+3).presentVolume));
        elseif (ii == 63)
            mInfo(ii+1).updatedVolume = mInfo(ii+1).updatedVolume * (mInfo(ii+1).presentVolume/(mInfo(ii).presentVolume ...
                + mInfo(ii+1).presentVolume + mInfo(ii+2).presentVolume));
        elseif (ii == 64)
            mInfo(ii+1).updatedVolume = mInfo(ii+1).updatedVolume * (mInfo(ii+1).presentVolume/(mInfo(ii-1).presentVolume ...
                + mInfo(ii).presentVolume + mInfo(ii+1).presentVolume));
        end
        
        % distributing right peroneal muscle volumes proportionately
        % Please see muscleInfo structure for indexing info
        % all of this goes inside a function
        
        if (ii == 39)
            mInfo(ii+1).updatedVolume = mInfo(ii+1).updatedVolume * (mInfo(ii+1).presentVolume/(mInfo(ii+1).presentVolume ...
                + mInfo(ii+2).presentVolume));
        elseif (ii == 40)
            mInfo(ii+1).updatedVolume = mInfo(ii+1).updatedVolume * (mInfo(ii+1).presentVolume/(mInfo(ii).presentVolume ...
                + mInfo(ii+1).presentVolume));
        end
        
        % distributing left peroneal muscle volumes proportionately
        % Please see muscleInfo structure for indexing info
        % all of this goes inside a function
        
        if (ii == 81)
            mInfo(ii+1).updatedVolume = mInfo(ii+1).updatedVolume * (mInfo(ii+1).presentVolume/(mInfo(ii+1).presentVolume ...
                + mInfo(ii+2).presentVolume));
        elseif (ii == 82)
            mInfo(ii+1).updatedVolume = mInfo(ii+1).updatedVolume * (mInfo(ii+1).presentVolume/(mInfo(ii).presentVolume ...
                + mInfo(ii+1).presentVolume));
        end
        
        % distributing right extensor hallucis and digitorum muscle volumes proportionately
        % Please see muscleInfo structure for indexing info
        % all of this goes inside a function
        
        if (ii == 41)
            mInfo(ii+1).updatedVolume = mInfo(ii+1).updatedVolume * (mInfo(ii+1).presentVolume/(mInfo(ii+1).presentVolume ...
                + mInfo(ii+2).presentVolume));
        elseif (ii == 42)
            mInfo(ii+1).updatedVolume = mInfo(ii+1).updatedVolume * (mInfo(ii+1).presentVolume/(mInfo(ii).presentVolume ...
                + mInfo(ii+1).presentVolume));
        end
        
        % distributing left extensor hallucis and digitorum muscle volumes proportionately
        % Please see muscleInfo structure for indexing info
        % all of this goes inside a function
        
        if (ii == 84)
            mInfo(ii+1).updatedVolume = mInfo(ii+1).updatedVolume * (mInfo(ii+1).presentVolume/(mInfo(ii+1).presentVolume ...
                + mInfo(ii+2).presentVolume));
        elseif (ii == 85)
            mInfo(ii+1).updatedVolume = mInfo(ii+1).updatedVolume * (mInfo(ii+1).presentVolume/(mInfo(ii).presentVolume ...
                + mInfo(ii+1).presentVolume));
        end
        
    else
        mInfo(ii+1).updatedVolume = mInfo(ii+1).presentVolume;
    end
end


end