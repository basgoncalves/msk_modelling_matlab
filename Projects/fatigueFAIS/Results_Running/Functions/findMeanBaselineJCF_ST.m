
% GroupData = group data after running "importExternalBiomech.m"


function [G] = findMeanBaselineJCF_ST (G)

N = length(G.participants);
Pram = fields(G);           % get paramters
trials = fields(G.(Pram{1})); % get coordinates

for k = 1:N
    
    %     [~,idx] = max([ST.Vmax.Run_baselineA1(k) ST.Vmax.Run_baselineB1(k)]);
    G = updateGroup (G,k);
end


% organise group data
    function G = updateGroup (G,k)
        Pram = fields(G);           % get paramters
        for p = 1:length(Pram)-1        % -1 = do not go for field called participants
            trials = fields(G.(Pram{p})); % get coordinates
            for c = 1:length(trials)
                
                if startsWith(trials{c},'RunStraight')
                    TrialsIdx=find(startsWith(trials,'RunStraight')); NewStruct='MeanRunStraight';
                elseif startsWith(trials{c},'CutTested')
                    TrialsIdx=find(startsWith(trials,'CutTested1')); NewStruct='MeanCutTested';
                elseif startsWith(trials{c},'CutOposite')
                    TrialsIdx=find(startsWith(trials,'CutOposite')); NewStruct='MeanCutOposite';
                elseif startsWith(trials{c},'walking')
                    TrialsIdx=find(startsWith(trials,'walking')); NewStruct='MeanWalking';
                end
                
                Nrows = length(G.(Pram{p}).(trials{c})(:,k));
                
                MeanTrials = nan(Nrows,1);
                for t = TrialsIdx'
                    currentTrial = G.(Pram{p}).(trials{t})(:,k);
                    MeanTrials = nanmean([MeanTrials currentTrial],2);
                end
                G.(Pram{p}).(NewStruct)(1:Nrows,k) = MeanTrials;
                
            end
        end
    end
end
