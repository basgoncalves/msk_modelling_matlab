

function   [OutData,OutLabels] = MeanCEINMSmuscles(MParameter,LabelsMuscles,MusclesToSum)


TotalGlut = mean(findData(MParameter,LabelsMuscles,MusclesToSum,0),2);
idx =find(contains(LabelsMuscles,MusclesToSum));

OutData = MParameter;
OutData(:,idx(1)) = TotalGlut;
OutData(:,idx(2:end)) = [];

OutLabels = LabelsMuscles;
OutLabels(idx(2:end)) = [];