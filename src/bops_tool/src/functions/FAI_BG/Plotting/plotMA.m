%% plot results from muscle analysis

function plotMA(Subjects)
fp= filesep;

for ff = 1:length(Subjects)
    
    [Dir,Temp,SubjectInfo,Trials] = getdirFAI(Subjects{ff});
    leg =  lower(SubjectInfo.TestedLeg);
    coordinateList = {'hip_flexion' 'hip_adduction' 'hip_rotation' 'knee_angle' 'ankle_angle'};
    
    % walking
    trialList = Trials.MA(contains(Trials.MA,Trials.Walking));
    for coordinate = coordinateList
        plotResults(Dir,trialList,coordinate{1},leg,[Dir.Results fp 'MA' fp 'Walking' fp coordinate{1}],Subjects{ff})
    end
    
    % running
    trialList = Trials.MA(contains(Trials.MA,Trials.RunStraight));
    for coordinate = coordinateList
        plotResults(Dir,trialList,coordinate{1},leg,[Dir.Results fp 'MA' fp 'RunStraight' fp coordinate{1}],Subjects{ff})
    end
end


function plotResults(Dir,trialList,coordinate,leg,saveDir,SubjectName)
fp = filesep;

MomentArms =struct;
for  t= 1:length(trialList)
    MomentArms.(trialList{t}) = load_sto_file([Dir.MA fp trialList{t} fp '_MuscleAnalysis_Moment_' coordinate '_' leg '.sto']);
end

fs = 1/diff(MomentArms.(trialList{t}).time(1:2));
muscles = fields(MomentArms.(trialList{t})); muscles = muscles(contains(muscles,['_' leg]));
[ha, ~,FirstCol, LastRow] = tight_subplotBG (length(muscles),0,[0.03],[0.1 0.05],[0.05 0.1],0);

for m = 1:length(muscles)
    muscleMomentArm =[];
    for t= 1:length(trialList)
        muscleMomentArm(:,t) = TimeNorm(MomentArms.(trialList{t}).(muscles{m}),fs);
    end
    axes(ha(m));hold on;
    plot(muscleMomentArm)
    title(muscles{m})
    yticklabels(yticks)
    if any(m==LastRow); xticklabels(xticks); end
end

annotation('textbox', [0, 0.6, 0, 0], 'string', 'moment arm (m)');
suptitle(coordinate)
lg = legend(trialList); lg.Position =[0.91 0.54 0.1 0.1];
mmfn_inspect

warning off; mkdir(saveDir)
saveas(gcf,[saveDir fp SubjectName '.jpeg']);
close all