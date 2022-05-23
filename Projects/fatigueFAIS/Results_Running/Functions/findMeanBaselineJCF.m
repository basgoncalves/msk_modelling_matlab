
% GroupData = group data after running "importExternalBiomech.m"


function [G] = findMeanBaselineJCF (G)

N = length(G.participants);
Pram = fields(G);           % get paramters
muscles = fields(G.(Pram{1})); % get coordinates
trials = fields(G.(Pram{1}).(muscles{1})); % get trials


for k = 1:N
    
    %     [~,idx] = max([ST.Vmax.Run_baselineA1(k) ST.Vmax.Run_baselineB1(k)]);
    G = updateGroup (G,k);
end


% organise group data
    function G = updateGroup (G,k)
        Pram = fields(G);           % get paramters
        Pram (contains(Pram,'participants'))=[]; % delete the Parm = participants
        for p = 1:length(Pram)       
            muscles = fields(G.(Pram{p})); % get coordinates
            for c = 1:length(muscles)
                trials = fields(G.(Pram{p}).(muscles{c})); % get trials
                runTrials =find(startsWith(trials,'RunStraight'));
                LeftCut = find(startsWith(trials,'CutTested'));
                RightCut = find(startsWith(trials,'CutOposite'));
                walkTrials = find(startsWith(trials,'walking'));
                
                Nrows = length(G.(Pram{p}).(muscles{c}).(trials{1})(:,k));
                G.(Pram{p}).(muscles{c}).MeanRunStraight(1:Nrows,k) = MeanCalc(runTrials,c,p,k); % mean straight sprint
                G.(Pram{p}).(muscles{c}).MeanCutTested(1:Nrows,k) = MeanCalc(LeftCut,c,p,k);          % mean left cut
                G.(Pram{p}).(muscles{c}).MeanCutOposite(1:Nrows,k) = MeanCalc(RightCut,c,p,k);          % mean left cut
                G.(Pram{p}).(muscles{c}).MeanWalking(1:Nrows,k) = MeanCalc(walkTrials,c,p,k);          % mean left cut
            end
        end
        
    end

    function MeanValues = MeanCalc(TrialsIdx,c,p,k)
        Nrows = length(G.(Pram{p}).(muscles{c}).(trials{1})(:,k));
        MeanValues = nan(Nrows,1);
        for t = TrialsIdx'
            currentTrial = G.(Pram{p}).(muscles{c}).(trials{t})(:,k);
            MeanValues = nanmean([MeanValues currentTrial],2);
        end
    end
end
