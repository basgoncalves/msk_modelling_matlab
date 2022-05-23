% Correlations between hip isometric strength (flexion nd extension) 
% and max speed 


function CorrStrength_Speed(SubjectFoldersElaborated)
fp = filesep;
if ~exist ('Logic')|| isempty(Logic);Logic = 1;end

Dir = getdirFAI(SubjectFoldersElaborated{1});
DirResults = Dir.Results_JointWorkRS;

C = struct; % correlation data
Speed = load([DirResults fp 'PaperData&Figs' fp 'SpatioTemporal_Sept20.mat']);
[Vmax,~] = max(Speed.MaxSpeed(1:2,:));

for ff = 1:length(SubjectFoldersElaborated)
    
     [Dir,~,SubjectInfo,~]=getdirFAI(SubjectFoldersElaborated{ff});           % get directories and subject info
    
    %load strength and speed
    cd(Dir.StrengthData)
    if exist('strenghtData.mat')
        Strenght = load('strenghtData.mat');
    else
        IsometricTorqueEMG(Dir,SubjectInfo)
        Strenght = load('strenghtData.mat');
    end
    
    % hip extension
    idx = find(strcmp(Strenght.MaxStrength(:,1),'HE'));
    C.HE(1,ff) = Strenght.MaxStrength{idx,2};
    % hip flexion
    idx = find(strcmp(Strenght.MaxStrength(:,1),'HF'));
    C.HF(1,ff) = Strenght.MaxStrength{idx,2};
    % Knee flexion
    idx = find(strcmp(Strenght.MaxStrength(:,1),'KF'));
    C.KF(1,ff) = Strenght.MaxStrength{idx,2};
    % Knee extension
    idx = find(strcmp(Strenght.MaxStrength(:,1),'KE'));
    C.KE(1,ff) = Strenght.MaxStrength{idx,2};
    
end


% correlations
f = fields(C);
cMat = lines;
for k = 1:length(f)
    [r2,pvalue, p1] = plotCorr (C.(f{k})',Vmax',1,0.05,cMat(k,:)); % plot Vmax vs Torque
    lb{k} = [f{k} ' vs Vmax (r^2=' num2str(r2) ')'];    % new name for labels  
    Multi(:,k) = C.(f{k})';
end
ax = gca;
ax.Children = flip(ax.Children);
lg = legend (ax.Children(2:3:end),lb);
mmfn

% multiple regression 
[b,bint,r] = regress(Vmax',Multi(:,1:3));
Vmax_R = b(1)+b(2)*Multi(:,1)+b(3)*Multi(:,2)+b(4)*Multi(:,3);

figure
[r2,pvalue, p1] = plotCorr (Vmax_R,Vmax',1,0.05,cMat(1,:)); % plot Vmax vs Torque
ax = gca;
lg = legend (ax.Children(2),['M.Regression(HE,HF,KF) vs Vmax (r^2 =' num2str(r2) ')'] );
mmfn
