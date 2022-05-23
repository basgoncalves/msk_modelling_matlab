

function   [OutData,OutLabels] = SumCEINMSmuscles(MParameter,LabelsMuscles,MusclesToSum)


TotalMuscles = sum(findData(MParameter,LabelsMuscles,MusclesToSum,0),2);
idx =find(contains(LabelsMuscles,MusclesToSum));

OutData = MParameter;
OutData(:,idx(1)) = TotalMuscles;
OutData(:,idx(2:end)) = [];

OutLabels = LabelsMuscles;
OutLabels(idx(2:end)) = [];