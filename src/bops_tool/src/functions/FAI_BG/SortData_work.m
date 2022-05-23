%BG 2020

% sort data in a struct based on the labels and the subject code

% Labels = cell vector with the names of each data column
function G = SortData_work(G,Data,trialName,motionsG,col)

f = fields(Data);

for k = 1:2 % loop through the work bursts
    for kk = 1:length(motionsG)
        if ~isfield(G.(motionsG{kk}).(f{k}),trialName)
            G.(motionsG{kk}).(f{k}).([trialName])=[];
        end
        G.(motionsG{kk}).(f{k}).([trialName])(:,col)= Data.(f{k})(:,1);
    end
end


for k = 3:length(f) % loop through the work bursts
    for kk = 1:length(motionsG)
        if ~isfield(G.(motionsG{kk}).(f{k}),trialName)
            G.(motionsG{kk}).(f{k}).([trialName])=[];
        end
        G.(motionsG{kk}).(f{k}).([trialName])(:,col)= Data.(f{k})(:,kk);
    end
end

