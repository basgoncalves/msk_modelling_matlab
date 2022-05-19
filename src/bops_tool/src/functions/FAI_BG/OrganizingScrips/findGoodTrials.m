% delete bad trials from the vector 

% M = matrix with the name of the trials in the first column and the trial
%      quality vector in the next columns: First row is the participant
%      code. Eg.
%       []          001     005
%       Trial_1      x       2
%       Trial_2      2       5
%       Trial_3      1       x
%                   ...


function [GoodTrials,BadTrials] = findGoodTrials (M,Subject)

% good trial = any number except zero

GoodTrials = {};
BadTrials = {};
for k = 1:size(M,2)
    % check if the
    if contains(M{1,k},Subject)
        for kk = 2:size(M(:,k),1)
            if isempty(M{kk,k})
                continue
            elseif isnumeric(M{kk,k}) && M{kk,k} == 0 
                txt = sprintf('trial %s has not been checked',M{kk,1});
                warning(txt)
            elseif isnumeric(M{kk,k})
                GoodTrials = [GoodTrials; M{kk,1}];
            else 
                BadTrials = [BadTrials; M{kk,1}];
            end
        end
    end
end