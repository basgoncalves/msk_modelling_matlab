% to be used after running RRA 3 times
% 1) Kinematics Right TO - right TO
% 2) Kinematics Right TO - right TO with mass asjustments only during stance with GRF
% 3) Kinematic and mass asjustments only during stance with GRF
% Logic 1 = plot data (default); ~1 = plot don't plot;

function massAdj = getMassAdj(DirRRA,model_file,side,itr,Logic)

fp = filesep;
DirElaborated = fileparts(DirRRA);
DirC3D = strrep(DirElaborated,'ElaboratedData','InputData');
saveDir = [DirElaborated fp 'results' fp 'RRA' num2str(itr)];
mkdir(saveDir)
fnames = {'moments','pelvisMoments','pelvisRotations','pelvisTranslations','kinematics'};
[~,Subject] = fileparts(fileparts(DirElaborated));
% model_file = [DirElaborated fp Subject '_Rajagopal2015_FAI.osim'];

if ~exist('Logic')
    Logic = 1;
end

%% define data
files = dir(DirRRA);
files(1:2) = [];
xt = {};     % xticks
xtRMSE = {};
lg = {};
lbRMSE = {};
s = lower(side{1});
motions = {['hip_flexion_' s];['knee_angle_' s];['ankle_angle_' s]};
RRA = struct;
RRA_Log = struct;
resid = struct;
residPer =struct;
ogresid = struct;
ogresidPer = struct;
massAdj = [];
RMSE = [];
RMSEper =[];


%%
for ii = 1:length(files)
    if isdir([DirRRA fp files(ii).name fp ])
        
        trialName = files(ii).name;
        
        % max GRF for this trial
        dirGRF = [DirC3D fp trialName '.c3d' ];
        c3d_data = btk_loadc3d(dirGRF);
        c3d_data = combineForcePlates_multiple(c3d_data);
        MaxGRF = max(c3d_data.GRF.FP.F)'; % maximum GRF in the 3 directions
        
        xt{end+1} = trialName;
        r =[];   % legend
        m =[];
        lg = [];
        for r = itr
            n = num2str(r);
            fileID = [DirRRA fp trialName fp 'RRA' n fp 'out.log']; % RRA out log file
            NewIKDir = [DirRRA fp trialName fp 'RRA' n fp trialName '_Kinematics_q.sto'];
            if exist(NewIKDir)
                [m(end+1) , residuals , ogResiduals] = adjMass(fileID);
                resid.(['RRA' n])(:,ii) = residuals;
                residPer.(['RRA' n])(:,ii) = residuals(1:3)./MaxGRF*100;
                ogresid.(['RRA' n])(:,ii) = ogResiduals;
                ogresidPer.(['RRA' n])(:,ii) = ogResiduals(1:3)./MaxGRF*100;
                
                RRA_Log.(['RRA' n]){ii} = fileID;
                lg{end+1}= ['RRA' n];
            end
        end
        if ~isempty(m)
            massAdj(:,ii)= m';
            
        end
        
        % if RRA out log file exists
        if exist(NewIKDir)
            [F,R,Data] = RRArms (DirRRA,model_file,trialName,side,itr,Logic);
            fld = {'translationsPelvis','rotationsPelvis','HKAkinematics','TrunkKinematics'};
            
            %% organise and plot RMSE kinematics absolute and as a percentage
            [rows,cols] = size(R.(fld{1}).RMSE);
            
            RMSE = [];
            RMSEper =[];
            rsquared = [];
            c = 0; %count
            for k = 1:cols:cols*4
                c=c+1;
                ff = fld{c};
                RMSEper(rows,k:k+2) = R.(ff).RMSE./ range (Data.(ff).Original)*100; % RMSE normalised to the range of data
                RMSE(rows,k:k+2) = R.(ff).RMSE;
                rsquared(rows,k:k+2) = R.(ff).rsquared;
                xtRMSE (1,k:k+2)= R.(ff).Cols;
            end
            lbRMSE = R.(fld{1}).RowsRMSE(:);
            % delete rows not containing comparisons with original
            idx = find(~contains(lbRMSE,'Original')); % Row to delete
            RMSE (idx,:)=[];
            lbRMSE (idx,:)=[];
            RMSEper (idx,:)=[];
            rsquared (idx,:)=[];
            
            % add a zero row (compare original with original)
%             lbRMSE =  {'Original - Original'  lbRMSE{:}}';
%             RMSE =  [zeros(1,size(RMSE,2)); RMSE];
%             RMSEper =  [zeros(1,size(RMSEper,2)); RMSEper];
%             rsquared =  [zeros(1,size(rsquared,2)); rsquared];
            % get the info about the RRA paameters
            
%             for k = 1:length(itr)
%                 TaskXML = [DirRRA fp ' itr(k)')
%             end

            % plot RMSE
            BarBG (RMSE',[],'RMSE(cm/deg)', xtRMSE,'', lbRMSE,[],25)
            ax = gca;
            ax.Position = [0.25 0.25 0.7 0.5];
            ax.Legend.FontSize = 15;
            ax.Legend.Position = [0.5 0.8 0.4 0.12];
            saveas(gcf,[saveDir fp trialName '_RMSE.tif'])
            
            % plot RMSEper
            BarBG (RMSEper',[],'RMSE(% of range)', xtRMSE,'', lbRMSE,[],25)
            ax = gca;
            ax.Position = [0.25 0.25 0.7 0.5];
            ax.Legend.FontSize = 15;
            ax.Legend.Position = [0.5 0.8 0.4 0.12];
            saveas(gcf,[saveDir fp trialName '_RMSEper.tif'])
            
            % plot R squared
            BarBG (rsquared',[],'R^2', xtRMSE,'', lbRMSE,[],25)
            ax = gca;
            ax.Position = [0.25 0.25 0.7 0.5];
            ax.Legend.FontSize = 15;
            ax.Legend.Position = [0.5 0.8 0.4 0.12];
            saveas(gcf,[saveDir fp trialName '_rsquared.tif'])
            
            close all
        end
    end
end


%% bar plot with mass adjustments
BarBG (massAdj',[],'Mass adjustments (kg)',itr,'',xt,[],25)
xtickangle(45)
ax = gca;
ax.Position = [ 0.3   0.2    0.6    0.7];
saveas(gcf,[saveDir fp 'adjWeights.tif'])

%% plot residuals

f = fields(resid);
res =[];
ff={};
for ii = 1:length(f)
    res(:,ii) = mean(resid.(f{ii}),2); % mean of each row (Fx,Fy,Fz,Mx...)
    ff{ii} = [f{ii} 'after torsoCOM and Kin adjustments'];
end
res = [mean(ogResiduals,2) res];
xt = {'Fx' 'Fy' 'Fz' 'Mx' 'My' 'Mz'};
ff = {'residuals before adjusting torso COM'  ff{:}};
BarBG (res,[],'N / Nm',xt,'',ff,[],25);
ax = gca;
ax.Position = [0.25 0.15 0.7 0.6];
ax.Legend.FontSize = 15;
ax.Legend.Position =  [0.5 0.8 0.4 0.12];
% title('Data form the out.log file')
saveas(gcf,[saveDir fp 'meanResiduals_run.tif'])


%% plot residuals as a percentage of GRF

f = fields(residPer);
resPer =[];
ff = {}; % plot 
for ii = 1:length(f)
    resPer(:,ii) = mean(residPer.(f{ii}),2); % mean of each row (Fx,Fy,Fz,Mx...)
    ff{ii} = [f{ii} 'after torsoCOM and Kin adjustments'];
end
resPer = [mean(ogresidPer.(f{1}),2) resPer(1:3,:)];
xt = {'Fx' 'Fy' 'Fz'};
ff = {'residuals before adjusting torso COM'  ff{:}};
BarBG (resPer,[],'% of GRF ',xt,'',ff,[],25);
ax = gca;
ax.Position = [0.2 0.15 0.6 0.8];
ax.Legend.FontSize = 15;
ax.Legend.Position =  [0.65 0.5 0.4 0.12];
% title('Data form the out.log file')
saveas(gcf,[saveDir fp 'meanResidualsPercentage_run.tif'])



%% close figures and open windows explorer
close all
winopen(saveDir)

