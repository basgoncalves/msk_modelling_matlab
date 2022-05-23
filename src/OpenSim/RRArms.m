%% RRArms
%
%   Logic 1 = plot data (default); ~1 = plot don't plot;
%
%   itr = number of RRA iteration to plot (RRA_1, RRA_2...)
%   F = figures;
%   R = residulas;
function [F,R,Data] = RRArms (DirRRA,model_file,trialName,side,itr,Logic)

fp = filesep;
warning off

if ~exist('Logic')
    Logic = 1;
end

%% Default settiong and directories
DirC3D = strrep(fileparts(DirRRA),'ElaboratedData','InputData');
DirIK = strrep(DirRRA,'residualReductionAnalysis','inverseKinematics');
DirID = strrep(DirRRA,'residualReductionAnalysis','inverseDynamics');
saveDir = [fileparts(DirRRA) fp 'results' fp 'RRA' num2str(itr)];
mkdir(saveDir)

if contains(trialName,'run','IgnoreCase',1) && contains(trialName,'2')
     s = 'r';  
elseif contains(trialName,'run','IgnoreCase',1) && contains(trialName,'3')
     s = 'l';  
else
     s = lower(side{1});  

end


motions = {['hip_flexion_' s];['knee_angle_' s];['ankle_angle_' s]};
LW = 2; %line width for the plots
R = struct;
F = struct; % figures

% gait cycle
fileDir = [DirC3D fp trialName '.c3d'];
GCtype = 2;     % from toe off to toe off (1 = foot contatc to foot contact
if contains(trialName,'run','IgnoreCase',1) && contains(trialName,'3')
    side = {'L'};
elseif contains(trialName,'run','IgnoreCase',1) && contains(trialName,'2')
     side = {'R'};
end

[FC, TO,GaitCycle] = FindGaitCycle_Running (fileDir,side,GCtype);

cd([DirRRA fp trialName])
files = dir(DirRRA);
files(1:2) = [];
cd([DirRRA fp trialName])

%% compare RRA vs inverse kinematics - hip, knee and ankle
motions = {['hip_flexion_' s];['knee_angle_' s];['ankle_angle_' s]};
RRAfilename = '_Kinematics_q.sto';
OGfile = [DirIK fp trialName fp 'IK.mot'];
[Residuals,LgIK,RRA] = createPlots (motions, RRAfilename, OGfile,itr);
R.HKAkinematics =  Residuals; % residuals
Data.HKAkinematics =  RRA; % residuals
if Logic == 1
    f = gcf;
    f.Children(1).YLabel.String = 'Angle (deg)';
    F.HKAkinematics = f;
    saveas(gcf,[saveDir fp trialName 'HKAkinematics.tif'])
end
%% translations of the pelvis
motions = {'pelvis_tx' 'pelvis_ty' 'pelvis_tz'};
RRAfilename = '_Kinematics_q.sto';
OGfile = [DirIK fp trialName fp 'IK.mot'];
[Residuals,LgIK,RRA] = createPlots (motions, RRAfilename,OGfile,itr);
R.translationsPelvis =  Residuals; % residuals
Data.translationsPelvis =  RRA; % data
if Logic == 1
    f = gcf;
    f.Children(1).YLabel.String = 'displacement (m)';
    F.translationsPelvis = f;
    saveas(gcf,[saveDir fp trialName 'translationsPelvis.tif'])
end

%% rotations of the pelvis
motions = {'pelvis_tilt' 'pelvis_list' 'pelvis_rotation'};
RRAfilename = '_Kinematics_q.sto';
OGfile = [DirIK fp trialName fp 'IK.mot'];
[Residuals,LgIK,RRA] = createPlots (motions, RRAfilename,OGfile,itr);
R.rotationsPelvis =  Residuals; % residuals
Data.rotationsPelvis =  RRA; % data
if Logic == 1
    f = gcf;
    f.Children(1).YLabel.String = 'Angle (deg)';
    F.rotationsPelvis= f;
    saveas(gcf,[saveDir fp trialName 'rotationsPelvis.tif'])
end

%% pelvis forces
motions = {'pelvis_tx'	'pelvis_ty'	'pelvis_tz'};
RRAfilename = '_Actuation_force.sto';
OGfile = [DirID fp trialName fp 'inverse_dynamics.sto'];
[Residuals,LgIK,RRA] = createPlots (motions, RRAfilename,OGfile,itr);
R.residualForces =  Residuals; % residuals
Data.residualForces =  RRA; % data
if Logic == 1
    f = gcf;
    axes(f.Children(1))
    yyaxis left
    f.Children(1).YLabel.String = 'Force (N)';
    yyaxis right
    ylabel('% GRF')
    f.Children(3).String = strrep(LgIK,'IK','ID');
    F.residualForces= f;
    saveas(gcf,[saveDir fp trialName 'residualForces.tif'])
end
%% pelvis moments
motions = {'pelvis_tilt' 'pelvis_list' 'pelvis_rotation'};
RRAfilename = '_Actuation_force.sto';
OGfile = [DirID fp trialName fp 'inverse_dynamics.sto'];
[Residuals,LgIK,RRA] = createPlots (motions, RRAfilename,OGfile,itr);
R.ResidualMoments =  Residuals; % residuals
Data.ResidualMoments =  RRA; % data
if Logic == 1
    f = gcf;
    f.Children(1).YLabel.String = 'Moment (Nm)';
    f.Children(3).String = strrep(LgIK,'IK','ID');
    F.ResidualMoments= f;
    saveas(gcf,[saveDir fp trialName 'ResidualMoments.tif'])
end
%% RMS moments
motions = {['hip_flexion_' s ];['knee_angle_' s ];['ankle_angle_' s]};
RRAfilename = '_Actuation_force.sto';
OGfile = [DirID fp trialName fp 'inverse_dynamics.sto'];
[Residuals,LgIK,RRA] = createPlots (motions, RRAfilename,OGfile,itr);
R.HKAMoments =  Residuals; % residuals
Data.HKAMoments =  RRA; % data
if Logic == 1
    f = gcf;
    f.Children(1).YLabel.String = 'Moment (Nm)';
    f.Children(3).String = strrep(LgIK,'IK','ID');
    f.Children(3).String = strrep(LgIK,'RRA_','RRA_');
    F.HKAMoments= f;
    saveas(gcf,[saveDir fp trialName 'HKAMoments.tif'])
end

%% Trunk kinematics
motions = {['lumbar_extension'];['lumbar_bending'];['lumbar_rotation']};
RRAfilename = '_Kinematics_q.sto';
OGfile = [DirIK fp trialName fp 'IK.mot'];
[Residuals,LgIK,RRA] = createPlots (motions, RRAfilename,OGfile,itr);
R.TrunkKinematics =  Residuals; % residuals
Data.TrunkKinematics =  RRA; % data
if Logic == 1
    f = gcf;
    f.Children(1).YLabel.String = 'Angle (deg)';
    F.TrunkKinematics= f;
    saveas(gcf,[saveDir fp trialName 'TrunkKinematics.tif'])
end

%% Nested fucntions

    function [Residuals,LgIK,RRA] = createPlots (motions, RRAfilename,OGfile,itr)
        
        LgIK = {};
        RRA = struct;
        window = struct;
        
        %import original data
        [RRA,window.Original] = NormData_OG (OGfile, 'Original',RRA,motions);
        LgIK{end+1} = 'Original';
        %import RRA kinematics from the defined iterations
        for n = itr
            n = num2str(n);
            
            fileID = strrep(OGfile,'.sto', ['_RRA' n '.sto']);
            if exist(fileID) && ~contains (OGfile,'.sto') % dellete this IF in case you to plot actuators too
                
                % Data as a result of the RRA algorith
%                 if ~contains(n,'3') || length(n) > 1
                    fldName =['RRA' n RRAfilename(1:end-4)];
                    fileID = [files(1).folder fp trialName fp ['RRA' n] fp trialName RRAfilename];
                    [RRA, fgc, window.(fldName)] = NormData_1 (fileID,fldName,RRA,motions,window.Original);
                    LgIK{end+1} = fldName;
%                 else
%                     %import RRA kinematics 3
%                     fldName =['RRA3'];
%                     fileID = [files(1).folder fp trialName fp fldName fp trialName RRAfilename];
%                     [RRA, window.(fldName)] = NormData_3 (fileID,[fldName RRAfilename],RRA,motions,fgc);
%                     LgIK{end+1} = fldName;
%                 end
                
            end
            % import inverse dyamics post body mass adjustments with RRA
            % inverse kinematics
            fileID = strrep(OGfile,'.sto', ['_RRA' n '.sto']);
            if ~exist(fileID) && contains (OGfile,'.sto')
                DirSetupID = [DirID fp trialName fp 'setup_ID.xml'];
                model_file_rra = [strrep(model_file,'.osim','_rra') n '.osim'];
                InverseDynamics_PostRRA (DirSetupID,model_file_rra,DirRRA,trialName,n)
            end
            
            if contains (OGfile,'.sto')
                fldName = ['ID_Post_RRA' n];
                [RRA,window.Original] = NormData_1 (fileID, fldName,RRA,motions,window.Original);
                LgIK{end+1} = fldName;
            else
                
            end
        end
        
        % RMS and Rsquared
        fld = fields(RRA);
        
        [RMSE,rsquared,RMSELabels,RMS,AVG] = getRMSE(RRA);
        Residuals = struct;
        Residuals.RMSE = RMSE;
        Residuals.rsquared = rsquared;
        Residuals.RMS = RMS;
        Residuals.AVG = AVG;
        Residuals.RowsRMSE = RMSELabels;
        Residuals.RowsRMS = fld;
        Residuals.Cols = motions;
        
        
        % joint plots
        if Logic == 1
            figure
            fullscreenFig(0.7,0.6)
            for ii = 1:length(motions)
                subplot(1,3,ii)
                % plot each RRA iterations (RMS columns, eg. RMS(1,2) = field 1, column 2)
                plotData (RRA,ii,RMSE(:,ii),rsquared(:,ii),RMS(:,ii),AVG(:,ii))
                if ii ~= 1 && sum(contains(motions,'pelvis_tx'))>0 &&...
                        contains(RRAfilename, '_Actuation_force.sto')
                    yyaxis left
                    ylabel('')
                    yyaxis right
                end
                ylabel('')
            end
            % arrange plot
            [ha, pos] = tight_subplot_BG(1,3,0.1,0.1,0.18);
            lg = legend(LgIK,'Interpreter','none');
            lg.Position = [0.82   0.4474    0.2065    0.1366];
            lg.FontSize = 10;
            lg.Box = 'off';
        end
        
    end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               Sub functions              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% find data for IK that contains one gait cycle 
    function [S,timewindow] = NormData_OG (fileID,fldName,S,names)
        IK  = importdata (fileID);
        % get RRA data to know which time window to compare. 
        [RRAID,~] = fileparts(strrep (fileID,'inverseKinematics','ResidualReductionAnalysis'));
        RRAID = strrep (RRAID,'inverseDynamics','ResidualReductionAnalysis');
        [~,TrialName] = fileparts(fileparts(strrep (fileID,'inverseKinematics','ResidualReductionAnalysis')));
        RRAID = [RRAID fp  'RRA' num2str(itr(1)) fp TrialName '_Kinematics_q.sto'];
        RRA = importdata (RRAID);
        
        fs = 1/(IK.data(2,1)-(IK.data(1,1)));
        time = IK.data(:,1);
        [IK,labels] = findData(IK.data,IK.colheaders, names,2);
        %delete beta knee angle
        if sum(contains(labels,'beta'))>0
            idx= find(contains(labels,'beta')); 
            IK(:,idx)=[];
            labels(idx) = [];
        end
        
        timewindow = [RRA.data(1,1) RRA.data(end,1)];
        
        fprintf('time window IK = %.2f to %.2f \n', timewindow(1), timewindow(2));
        
        % make the timewindow the closest 0.005 / 0.000 value
        for k = 1:length(timewindow)
            [~,idx] = min(abs(timewindow(k)-time));
            timewindow(k) = time(idx);
        end
        TO = find(time==timewindow(1));
        TO(2) = find(time==timewindow(2));
        
        IK = IK(TO(1):TO(2),:);
        S.(fldName) = TimeNorm(IK,fs);
    end

    function [S, fgc,timewindow] = NormData_1 (fileID,fldName,S,names,fgc)
        if sum(contains(names,'pelvis'))>0 && ...
                contains(fileID,'Actuation_force')
            if contains(names{1},'tilt')
                names = {'MX' 'MY' 'MZ'};
            else
                names = {'FX' 'FY' 'FZ'};
            end
        end
        
        IK  = importdata (fileID);
        timewindow = [IK.data(1,1) IK.data(end,1)];
       
        fprintf('time window %s = %.2f to %.2f \n', fldName, timewindow(1), timewindow(2));
        fs = 1/(IK.data(2,1)-(IK.data(1,1)));
        
        % transform data from structure to double with olny "name" as label
        [IK,labels] = findData(IK.data,IK.colheaders, names,2);
        fulltime = fgc(2)-fgc(1); % full gait cycle form the time window of the original IK
        NomrTime = round((timewindow - fgc(1))/fulltime *100)+1;
        if sum(contains(labels,'beta'))>0
            id = find(contains(labels,'beta'));
            IK(:,id)=[];
            labels(id) = [];
        end
        % normalise and align the RRA with the correct portion of the
        % original trial
        ds = TimeNorm(IK,fs); % down sample
        ds = downsample(ds,round(100/range(NomrTime)));
        rn = NomrTime(1):NomrTime(1)+length(ds)-1; % range
        S.(fldName)(1:101,1:size(ds,2)) = 0;
        S.(fldName)(rn,:)= ds;
        S.(fldName)(S.(fldName)(:,:) == 0)=NaN;
    end

    function [S,timewindow] = NormData_3 (fileID,fldName,S,names,fgc)
        IK  = importdata (fileID);
        timewindow = [IK.data(1,1) IK.data(end,1)];
        fprintf('time window %s = %.2f to %.2f \n', fldName, timewindow(1), timewindow(2));
        fs = 1/(IK.data(2,1)-(IK.data(1,1)));
        [IK,labels] = findData(IK.data,IK.colheaders, names,1);
        st = length(IK); % part gait cycle
        if st < fgc
            sw = fgc - st;      % rest
            IK_long = [];
            IK_long (fgc-st+1:fgc,:) = IK;
            S.(fldName) = TimeNorm(IK_long,fs);
            id = S.(fldName)==0;
            S.(fldName)(id) = NaN;
        else
            IK_long = IK;
            S.(fldName) = TimeNorm(IK_long,fs);
        end
        
    end

    function [S,timewindow] = NormData_postRRA (fileID,fldName,S,names,TO)
        IK  = importdata (fileID);
        timewindow = [IK.data(TO(1)+1,1) IK.data(TO(2)+1,1)];
        fprintf('time window IK = %.2f to %.2f \n', timewindow(1), timewindow(2));
        fs = 1/(IK.data(2,1)-(IK.data(1,1)));
        [IK,labels] = findData(IK.data,IK.colheaders, names,2);
        %delete beta knee angle
        if sum(contains(labels,'beta'))>0
            IK(:,3)=[];
            labels(3) = [];
        end
        IK = IK(TO(1):TO(2),:);
        S.(fldName) = TimeNorm(IK,fs);
    end


    function [RMSE,rsquared,RMSELabels,RMS,AVG] = getRMSE(S)
        
        fld = fields(S);
        % RMSE and Rsquared
        combos = combntns([1:length(fld)],2);
        for ii = 1: size(combos,1)
            x = S.(fld{combos(ii,1)});
            y = S.(fld{combos(ii,2)});
            
            % delete the NaN rows from both arrays
            id = isnan(x(:,1));
            x(id,:) =[]; y(id,:) =[];
            id = isnan(y(:,1));
            x(id,:) =[]; y(id,:) =[];
            
            RMSE (ii,:) = rms(x-y);
            RMSELabels{ii} = [fld{combos(ii,2)} ' - ' fld{combos(ii,1)}];
            
            % Rsquared
            for cc = 1: size(x,2)
                [c, pvalue] = corrcoef(x(:,cc),y(:,cc));
                rsquared(ii,cc) = c(1,2)^2;
                pvalue(ii,cc) = pvalue(1,2);
            end
        end
        
        RMSELabels = RMSELabels';
        AVG = [];
        % RMS( each row = 1 field)
        for ii = 1: length(fld)
            x = S.(fld{ii});
            id = isnan(x(:,1));
            x(id,:) =[];
            RMS(ii,:) = rms(x);
            AVG(ii,:) = mean(x);
        end
        
    end

    function plotData (S,col,RMSE,rsquared,RMS,AVG)
        
        hold on
        f = fields(S);
        for ii = 1:length(f)
            plot(S.(f{ii})(:,col),'LineWidth',LW)
        end
        title ([trialName '-' motions{col}],'Interpreter','none')
        ylabel ('Angle (deg)')
        xlabel('Right TO to Right TO')
        mmfn
        rn = range (ylim)*0.3;
        ylim([min(ylim)-rn max(ylim)+rn])
        
        if exist('RMSE')
            if length(RMSE)>1
                combos = combntns([1:length(f)],2);
            else
                combos =[1 2];
            end
            
            c = 1;% count
            for ii = 1: length(RMSE)
                if combos(ii,2) == 1 || combos(ii,1) == 1
                    t1 = sprintf('RMSE %.f-%.f = %.1f',combos(ii,2), combos(ii,1),RMSE(ii));
                    t2 = sprintf('(r2 = %.2f)', rsquared(ii));
                    t = text(0.5,0.5,[t1 t2]);
                    Posy = max(ylim)-range(ylim)*(c*0.03);
                    set(t, 'Position',[10  Posy  0.0000], 'FontSize', 11)
                    c = c+1;
                end
            end
        end
        
        if range (ylim) < 1
            n = 2;
        elseif  range (ylim) < 10
            n = 1;
        else
            n = 0;
        end
        
        yt = yticks;
        yt = round(min(yt):range(yt)/7:max(yt),n);
        yticks(unique(yt))
        for ii = 1: length(RMS)
            t = text(0.5,0.5,sprintf('RMS%.f = %.2f | AVG = %.2f', ii, RMS(ii),AVG(ii)));
            Posy = yt(2)-range(ylim)*(ii*0.03); % starts from the second y tick down
            set(t, 'Position',[10  Posy  0.0000], 'FontSize', 11)
        end
        
        xlim([0 140])
        
        if sum(contains(motions,'pelvis_tx'))>0 && contains(RRAfilename, '_Actuation_force.sto')
            dirc3d = strrep(fileparts(fileparts(fileparts(OGfile))), 'ElaboratedData','InputData');
            dirGRF = [dirc3d fp trialName '.c3d' ];
            data = btk_loadc3d(dirGRF);
            data = combineForcePlates_multiple(data);
            yyaxis right
            yt = round(yt/max(data.GRF.FP.F(:,col))*100);
            ylim([min(yt) max(yt)])
            ylabel('% of GRF')
            
        end
    end
end
