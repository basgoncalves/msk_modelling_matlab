

function [G,ST,W] = createResulsStruct_RSFAI(motionsG,EMGmuscles,workVariables,grfVariables,stVariables,TrialList,Ncols,Nrows)


%% create structs
G = struct;% group data
ST = struct; % spatio temppral data
for k = 1:length(motionsG)
    G.angles.(motionsG{k})= struct;
    G.moments.(motionsG{k})= struct;
    for kk = 1: length(TrialList)
        G.angles.(motionsG{k}).(TrialList{kk})= NaN(Nrows,Ncols);
        G.moments.(motionsG{k}).(TrialList{kk})= NaN(Nrows,Ncols);
        for k3 = 1:length(stVariables) 
          ST.(stVariables{k3}).(TrialList{kk})=NaN(1,Ncols);
        end       
    end
end

for k = 1:length(EMGmuscles)
    G.emg.(strtrim(EMGmuscles{k}))= struct;
       for kk = 1: length(TrialList)
        G.emg.(strtrim(EMGmuscles{k})).(TrialList{kk})= NaN(Nrows,Ncols);
    end
end


for k = 1:length(grfVariables)
    G.grf.(strtrim(grfVariables{k}))= struct;
    for kk = 1: length(TrialList)
        G.grf.(strtrim(grfVariables{k})).(TrialList{kk})= NaN(Nrows,Ncols);
    end
end

G.participants = {};

%% Set up group strunct for work 

W = struct;% work data
for k = 1:length(motionsG)
    W.(motionsG{k})= struct;
    for kk = 1:length(workVariables)
        W.(motionsG{k}).(workVariables{kk})= struct;
        for k3 = 1: length(TrialList)
        W.(motionsG{k}).(workVariables{kk}).(TrialList{k3})= NaN(1,Ncols);
        end
    end
end
