
% GroupData = group data after running "importExternalBiomech.m"


function [G,ST] = findMaxBaselineJCF (G,ST)

N = length(G.participants);
Pram = fields(G);           % get paramters
muscles = fields(G.(Pram{1})); % get coordinates
trials = fields(G.(Pram{1}).(muscles{1})); % get trials


for k = 1:N
    
    [~,idx] = max([ST.Vmax.Run_baselineA1(k) ST.Vmax.Run_baselineB1(k)]);
    G = updateGroup (G,k,idx);    
end


% organise group data
    function G = updateGroup (G,k,idx)
        Pram = fields(G);           % get paramters
        for p = 1:length(Pram)-1        % -1 = do not go for field called participants
            muscles = fields(G.(Pram{p})); % get coordinates
            for c = 1:length(muscles)
                trials = fields(G.(Pram{p}).(muscles{c})); % get trials
                if ~isfield(G.(Pram{p}).(muscles{c}),'Run_baseline')
                    G.(Pram{p}).(muscles{c}).Run_baseline = [];
                end
                Nrows = length(G.(Pram{p}).(muscles{c}).(trials{idx})(:,k));
                G.(Pram{p}).(muscles{c}).Run_baseline(1:Nrows,k) = G.(Pram{p}).(muscles{c}).(trials{idx})(:,k);
            end
        end
        
    end
end
