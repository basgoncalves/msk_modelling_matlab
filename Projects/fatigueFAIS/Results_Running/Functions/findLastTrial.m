
% GroupData = group data after running "importExternalBiomech.m"


function [G,W,ST,LastRun] = findLastTrial (G,W,ST,SubjectFoldersElaborated, sessionName,suffix)

fp = filesep;

N = length(G.participants);
Pram = fields(G);           % get paramters
coordinates = fields(G.(Pram{1})); % get coordinates
trials = fields(G.(Pram{1}).(coordinates{1})); % get trials

for k = 1:N
    
    [Dir,Temp,SubjectInfo,Trials] = getdirFAI(SubjectFoldersElaborated{k},sessionName,suffix);   

    % get trial names all with same format 
    Strials = getstrials(Trials.Dynamic); 
    LT = trials(find(contains(trials,Strials)));
    idx = find(contains(trials,LT{end}));
       
    G = updateGroup (G,k,idx);
    W = updateWork (W,k,idx);
    ST = updateST (ST,k,idx);
    
    LastRun{1,k} = G.participants{k};
    LastRun{2,k} = idx;
end


% organise group data
    function G = updateGroup (G,k,idx)
        Pram = fields(G);           % get paramters
        for p = 1:length(Pram)-1        % -1 = do not go for field called participants
            coordinates = fields(G.(Pram{p})); % get coordinates
            for c = 1:length(coordinates)
                trials = fields(G.(Pram{p}).(coordinates{c})); % get trials
                if ~isfield(G.(Pram{p}).(coordinates{c}),'Run_final')
                    G.(Pram{p}).(coordinates{c}).Run_final = [];
                end
                Nrows = length(G.(Pram{p}).(coordinates{c}).(trials{idx})(:,k));
                G.(Pram{p}).(coordinates{c}).Run_final(1:Nrows,k) = G.(Pram{p}).(coordinates{c}).(trials{idx})(:,k);
            end
        end
        
    end

    % organise work data
    function W = updateWork (W,k,idx)
        coordinates = fields(W); % get coordinates
        for c = 1:length(coordinates)
            WorkBursts = fields(W.(coordinates{c})); % get work bursts
            
            for b = 1:length(WorkBursts)
                trials = fields(W.(coordinates{c}).(WorkBursts{b})); % get trials
                
                if ~isfield(W.(coordinates{c}).(WorkBursts{b}),'Run_final')
                    W.(coordinates{c}).(WorkBursts{b}).Run_final = [];
                end
                Nrows = length(W.(coordinates{c}).(WorkBursts{b}).(trials{idx})(:,k));
                W.(coordinates{c}).(WorkBursts{b}).Run_final(1:Nrows,k) =...
                    W.(coordinates{c}).(WorkBursts{b}).(trials{idx})(:,k);
            end
        end
    end

% organise ST data
    function ST = updateST (ST,k,idx)
        coordinates = fields(ST); % get spatiotemporal variables
        for c = 1:length(coordinates)
            trials = fields(ST.(coordinates{c})); % get trials
            
            if ~isfield(ST.(coordinates{c}),'Run_final')
                ST.(coordinates{c}).Run_final = [];
            end
            Nrows = length(ST.(coordinates{c}).(trials{idx})(:,k));
            ST.(coordinates{c}).Run_final(1:Nrows,k) =...
                ST.(coordinates{c}).(trials{idx})(:,k);
        end
    end


end
