%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
% plot single trial JRA 
%% plotJRA_BG
function plotJRA_BG(Dir,CEINMSSettings,SubjectInfo,fileDir)

fp = filesep;
% Plotting settings
PlotSet = struct;
PlotSet.figSize = [60 60 1700 900];
PlotSet.FontSize = 12;
PlotSet.FontName = 'Times New Roman';
PlotSet.Xlab = 'GaitCycle (%)';
MatchWord = 1; % 1= match names / 0 = don't match full name

%% save dir
[~,trialName] = DirUp(fileDir,2);
savedir = [Dir.Results_JRA fp trialName];
if exist(savedir)
    n = num2str(sum(contains(cellstr(ls(Dir.Results_JRA)),trialName))+1);
    savedir = [Dir.Results_JRA fp trialName '_' n];
end
mkdir(savedir);

%% copy CEINMS results 

if exist([Dir.Results_CEINMS fp trialName])
    n = num2str(sum(contains(cellstr(ls(Dir.Results_CEINMS)),trialName)));
    if str2num(n) > 1
        copyfile([Dir.Results_CEINMS fp trialName '_' n fp 'ContactForces.jpeg'],[savedir fp 'ContactForces_CEINMS.jpeg'])
    else
        copyfile([Dir.Results_CEINMS fp trialName fp 'ContactForces.jpeg'],[savedir fp 'ContactForces_CEINMS.jpeg'])
    end
end

%% Dof and names of the variables to plot
dofList = split(CEINMSSettings.dofList ,' ')';
S = getOSIMVariablesFAI(SubjectInfo.TestedLeg,CEINMSSettings.osimModelFilename,dofList);
osimFiles = getosimfilesFAI(Dir,trialName); % also creates the directories

JCFStruct = importdata(fileDir);
JointNames = S.Joints;
[JCF,SL] = findData(JCFStruct.data,JCFStruct.colheaders,JointNames,0);
deleteCols = contains(SL,{'mz' 'my' 'mx' 'pz' 'py' 'px'});
JCF(:,deleteCols)=[];SL(:,deleteCols)=[];

TimeWindow = [JCFStruct.data(1,1) JCFStruct.data(end,1)];

[ID,~] = LoadResults_BG (osimFiles.IDresults,TimeWindow,[S.moments],MatchWord);
ID = ID./(SubjectInfo.Weight);   
    
OptimalSettings = OptimalGammaCEINMS_BG(Dir,[Dir.CEINMSsimulations fp trialName],SubjectInfo);
CEINMS_trialDir = OptimalSettings.Dir; 

[ID_CEINMS,~] = LoadResults_BG ([CEINMS_trialDir fp 'Torques.sto'],TimeWindow,S.coordinates,MatchWord);
ID_CEINMS = ID_CEINMS./(SubjectInfo.Weight);
[IK,~] = LoadResults_BG (osimFiles.IKresults,TimeWindow,[ S.coordinates],MatchWord);
        
%% plot JRA data
N = 2;
M = length(dofList);
[ha, ~,FirstCol, LastRow] = tight_subplotBG(N,M,0.1,0.15,0.1, [212,164,1553,719]);
for d = 1:length(dofList)
  
    axes(ha(d));hold on; plot(ID(:,d));
    plot(ID_CEINMS(:,d))
    
    RMSE = round(rms(ID_CEINMS(:,d)-ID(:,d)),1);
    [r, ~] = corrcoef(ID_CEINMS(:,d),ID(:,d)); 
    R2= round(r(1,2)^2,2);
    
    yticklabels(yticks)
    title(sprintf('%s (RMSE = %.1f, r^2 = %.2f)\n %s',...
        dofList{d},RMSE,R2,S.DOFdirections.(dofList{d}){1}),...
        'Interpreter','none')

    if any(d == FirstCol); ylabel('Moment (Nm/Kg)');
        lg = legend({'inverse dynamics' 'CEINMS'});
        lg.Position = [0.2314    0.82    0.1365    0.02];
    end
    
    % joint contact forces
    currentDofJCF = JCF(:,contains(SL,JointNames(d)));
    currentDofJCF = currentDofJCF./(SubjectInfo.Weight*9.81);
    
    axes(ha(d+M));hold on; plot(currentDofJCF);
    
    x=currentDofJCF(:,1);y=currentDofJCF(:,2);z=currentDofJCF(:,3);
    ResultantJCF = sqrt(x.^2+z.^2+y.^2);
    plot(ResultantJCF); yticklabels(yticks)
    
    if any(d+M == FirstCol)
        ylabel('Contact Force (N/BW)');
        lg = legend({'x[(-) posterior  | anteriro(+)]' 'y[(-) inferior | superior(+)]' ...
            'z[(-) lateral | medial(+)]' 'resultant force'});
        lg.Position = [0.2314    0.45    0.1365    0.0689];
    end   
    xlabel(PlotSet.Xlab)
end
MaxVelocity = CalcVelocity_OpenSimPelvis(Dir,trialName,TimeWindow,2);
suptitle ([trialName ' (speed = ' num2str(MaxVelocity) ' m/s)'])
F = gcf;
for i = 1:length(F.Children);F.Children(i).FontSize = PlotSet.FontSize;end
mmfn_inspect

saveas(gcf,[savedir fp 'JRA.jpeg'])

% cmdmsg(['JRA plots saved in  ' savedir])

