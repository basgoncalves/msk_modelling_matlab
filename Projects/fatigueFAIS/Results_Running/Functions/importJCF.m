
function [ContactForces,NormContactForces,NormContactForceRate,PosImpulse,NegImpulse,Labels] =importJCF(DirJRAresults,TimeWindow,LabelsCF,TestedLeg)

[time,~] = LoadResults_BG (DirJRAresults,TimeWindow,{'time'},1,0);
MatchWholeWord = 1;
NormaliseData = 0;
[ContactForces,Labels] = LoadResults_BG (DirJRAresults,TimeWindow,LabelsCF,MatchWholeWord,NormaliseData);
Ncols = size(ContactForces,2);
for i = 1:3:Ncols
    x = ContactForces(:,i);y = ContactForces(:,i+1); z = ContactForces(:,i+2);
    ContactForces(:,end+1) = sqrt(x.^2+y.^2+z.^2);
    Labels(end+1) = strrep(Labels(i),'_fx','Resultant');
end

fs = 1/(time(2)-time(1));
NormContactForceRate = TimeNorm(calcVelocity(ContactForces,fs),fs);

for k = 1:size(ContactForces,2)
    CF = ContactForces(:,k);
    idxPos = CF>0;idxNeg = CF<0;
    if length(find(idxPos))>2
        PosImpulse(1,k) = trapz(time(idxPos),CF(idxPos));
    else
        PosImpulse(1,k) = NaN;
    end
    
     if length(find(idxNeg))>2
       NegImpulse(1,k) = trapz(time(idxNeg),CF(idxNeg));
    else
        NegImpulse(1,k) = NaN;
    end
end

%% normalised CF
NormaliseData = 1;
[NormContactForces,~] = LoadResults_BG (DirJRAresults,TimeWindow,LabelsCF,MatchWholeWord,NormaliseData);

if contains(TestedLeg,'L')
    idx = find(contains(LabelsCF,'_fz'));
    NormContactForces(:,idx) =  -NormContactForces(:,idx);
end

Ncols = size(NormContactForces,2);
for i = 1:3:Ncols
    x = NormContactForces(:,i);y = NormContactForces(:,i+1); z = NormContactForces(:,i+2);
    NormContactForces(:,end+1) = sqrt(x.^2+y.^2+z.^2);
end