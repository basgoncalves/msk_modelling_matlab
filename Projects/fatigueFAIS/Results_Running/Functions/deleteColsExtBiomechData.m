

function NewData = deleteColsExtBiomechData(GroupData,colsToDelete)


NewData = GroupData;
f1 = fields(NewData);

for k1 = 1:length(f1)
    f2 = fields(NewData.(f1{k1}));
    for k2 = 1: length(f2)
        f3 = fields(NewData.(f1{k1}).(f2{k2}));
         for k3 = 1: length(f3)
            TrialData = NewData.(f1{k1}).(f2{k2}).(f3{k3});
            TrialData(:,colsToDelete) =[];
            NewData.(f1{k1}).(f2{k2}).(f3{k3})= TrialData;
         end
    end
end