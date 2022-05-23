
function plotTrialRRA(Dir,SubjectInfo,trialName)

fp = filesep;
[osimFiles] = getosimfilesFAI(Dir,trialName); % also creates the directories

[m,NR,OR,residuallabels] = LoadResultsRRALog([osimFiles.RRA fp 'out.log']);
Control = load_sto_file(osimFiles.RRAcontrols);
TimeWindow = [Control.time(1) Control.time(end)];

Control = LoadResults_BG (osimFiles.RRAcontrols,TimeWindow,[],0,1,1);
ActuationForce = LoadResults_BG (osimFiles.RRAactuation_force,TimeWindow,[],0,1,1);

IK = LoadResults_BG (osimFiles.IKresults,TimeWindow,[],0,1,1);
ID = LoadResults_BG (osimFiles.IDresults,TimeWindow,[],0,1,1);
IKrra = LoadResults_BG (osimFiles.RRAkinematics,TimeWindow,[],0,1,1);
IDrra = LoadResults_BG (osimFiles.RRAinverse_dynamics,TimeWindow,[],0,1,1);

s = lower(SubjectInfo.TestedLeg);

fprintf('FX = %.2f, FY = %.2f, FZ = %.2f \n' ,mean(ActuationForce.FX),mean(ActuationForce.FY),mean(ActuationForce.FZ))
fprintf('MX = %.2f, MY = %.2f, MZ = %.2f \n' ,mean(ActuationForce.MX),mean(ActuationForce.MY),mean(ActuationForce.MZ))

Nrows = 8; Ncols = 6;
[ha, pos,FirstCol,LastRow,LastCol] = tight_subplotBG(Nrows,Ncols,0.02,[0.1]);
mmfn_inspect
suptitle([SubjectInfo.ID '-' trialName])

coordinates = {['pelvis_tx'],['pelvis_ty'],['pelvis_tz'],['pelvis_tilt'],['pelvis_list'],['pelvis_rotation'],['hip_flexion_' s],['ankle_angle_' s]};
moments = {['pelvis_tx_force'],['pelvis_ty_force'],['pelvis_tz_force'],['pelvis_tilt_moment'],['pelvis_list_moment'],['pelvis_rotation_moment'],['hip_flexion_' s '_moment'],['ankle_angle_' s '_moment']};
controls = {['FX'],['FY'],['FZ'],['MX'],['MY'],['MZ'],['hip_flexion_' s],['ankle_angle_' s]};

for i = 1:length(coordinates)
    col = FirstCol(i);
    axes(ha(col)); hold on; ylabel([coordinates{i}],'Interpreter','none'); plot(ID.([moments{i}]));
    axes(ha(col+1)); hold on; plot(IDrra.([moments{i}]));
    axes(ha(col+2)); hold on; plot(Control.([controls{i}]));
    axes(ha(col+3)); hold on; plot(ActuationForce.([controls{i}]));
    axes(ha(col+4)); hold on; plot(IK.([coordinates{i}])); plot(IKrra.([coordinates{i}]));
end
axes(ha(1)); title('Inverse dynamics')
axes(ha(2)); title('Inverse dynamics after RRA')
axes(ha(3)); title('RRA controls')
axes(ha(4)); title('RRA actuation force/torque (N/Nm)')
axes(ha(5)); title('Inverse kinematics')
axes(ha(6)); title('Mean residuals')

col = 6;
for i = 1:6
    axes(ha(i*col)); hold on; 
    y = round([OR(i),NR(i),mean(ActuationForce.(residuallabels{i}))],1); 
    bar(y);
    text(1:length(y),y,num2str(y'),'vert','bottom','horiz','center'); 
end
axes(ha(7*col)); hold on; bar([1 2 3],[0 0 0]);
axes(ha(8*col)); hold on; bar([1 2 3],[0 0 0]);

tight_subplot_ticks(ha,LastRow,0)
mmfn(8)
axes(ha(8*col)); xticks([1 2 3]); xticklabels({'Original residuals' 'Post RRA residuals' 'mean actuation force'})

saveas(gcf,[Dir.Results_RRA fp 'Residuals_' trialName '.jpeg'])

[adjusted_mass,bodyNames,original_mass] = read_rra_mass(osimFiles.RRAlog);

[ha, pos,FirstCol,LastRow,LastCol] = tight_subplotBG(1,2,0.02,[0.1 0.05],0.1,[400 50 800 700]);
axes(ha(1)); hold on; 
nbodies = length(bodyNames);
bar([original_mass,adjusted_mass]); xticks([1:nbodies]); xticklabels(bodyNames); ylabel('mass (kg)'); legend({'original' 'after RRA'})

axes(ha(2)); hold on; 
original_mass(nbodies+1)=sum(original_mass(1:nbodies));
adjusted_mass(nbodies+1)=sum(adjusted_mass(1:nbodies));
bodyNames(nbodies+1) = {'total'};
T=array2table([original_mass,adjusted_mass]); T.Properties.VariableNames={'original' 'after RRA'}; T.Properties.RowNames = bodyNames;
t = uitable('Data',T{:,:},'ColumnName',T.Properties.VariableNames,...
'RowName',T.Properties.RowNames);
t.Units = 'Normalized';
t.Position = ha(2).Position;
set(gcf,'Color',[1 1 1]);
saveas(gcf,[Dir.Results_RRA fp 'MassAdjustments_' trialName '.jpeg'])

