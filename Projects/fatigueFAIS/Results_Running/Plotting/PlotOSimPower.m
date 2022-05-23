% power plots

OrganiseFAI
RunNames = {'Run_baselineA1';'Run_baselineB1';'RunA1';'RunB1';'RunC1';'RunD1';'RunE1';'RunF1';...
    'RunG1';'RunH1';'RunI1';'RunJ1';'RunK1';'RunL1'};
DirFigRunBiomech =  ([DirFigure filesep 'RunningBiomechanics' filesep Subject]);
mkdir(DirFigRunBiomech);
cd(DirIDResults)
load ([DirIDResults filesep 'IDresults.mat']);
load ([DirIKResults filesep 'IKresults.mat']);
Joints= {'hip','knee','ankle'};
Njoints = length(Joints);

startColor = [jet]; colorSpace = length(startColor)/14;
colors = round(1:colorSpace:length(startColor));
startColor = [jet; hot];
colors = [colors round(colors(end)+colorSpace:colorSpace:length(startColor))];

LegendNames = {};
cd(DirResults)
if exist('JointPowers.mat')
    load('JointPowers.mat')
else
    JointPowers = struct;
end

if exist('JointWorks.mat')
    load('JointWorks.mat')
else
    JointWorks = struct;
end

MainPowerFig = figure;

for ii = 1: Njoints             %loop through joints
    CurrentJointIDData = IDresults.(Joints{ii});
    CurrentJointIKData = IKresults.(Joints{ii});
    TrialsJoint = fields(CurrentJointIDData);
    Ntrials = length(TrialsJoint);
    
    Nmoments = size(CurrentJointIDData.(TrialsJoint{1}),2);
    for mm = 1:Nmoments         % loop through moments
        
        MomentName = erase(sprintf('%s',Labels.(Joints{ii}){mm}),' angle r');
        MomentName = erase(MomentName,' angle l');
        MomentName = strrep(MomentName,'on l','on');
        MomentName = strrep(MomentName,'on r','on');
        PowerFig(mm) = figure;
        hold on
        title (sprintf('%s power (W/Kg) ',MomentName))
        
        AngularVelFig(mm) = figure;
        title (sprintf('%s angular veloctity (Rad/sec) ',MomentName))
        hold on
        
        
        MomentPlot(mm) = figure;
        title (sprintf('%s Joint Moment (Nm/Kg) ',MomentName))
        hold on
       
        TotalPower=[];
        PositivePower=[];
        NegativePower=[];
        NetWork = [];
        PosWork = [];
        NegWork = [];
        PeakPosPower = [];
        PeakNegPower = [];
        APPosImpulse = [];
        APNegImpulse = [];
        LegendNames ={};
        AngVel = [];
        GC =[];
        FootContact=[];
        AngularVelocity = struct;
        Qst = sprintf('would you like to split data for %s?',MomentName);
%         answer = questdlg(Qst);
        answer = 'No';        
        SplitPosPower = struct;
        SplitPosWork = struct;
       
        for ss = 1:length(RunNames)          % loop through trials
            
            if ~isempty(find(contains(TrialsJoint, RunNames{ss})))
                
            TrialName = RunNames{ss};
            StructName = strrep(MomentName,' ','_');
            data = btk_loadc3d([DirC3D filesep TrialName '.c3d']);
            fs = data.marker_data.Info.frequency;
            load([DirIK filesep 'GaitCycle-' TrialName]);
            GC(ss,:) = GaitCycle.ToeOff - GaitCycle.FirstFrameOpenSim - GaitCycle.FirstFrameC3D;
            FootContact(ss) = GaitCycle.foot_contacts - GaitCycle.FirstFrameOpenSim - GaitCycle.FirstFrameC3D-GC(ss,1);
            Moment = CurrentJointIDData.(TrialName)(:,mm)/MassKG;
            Angle = CurrentJointIKData.(TrialName)(:,mm)*(pi/180);   % in radians 
            AngVel = calcVelocity (Angle,fs);
            AngularVelocity.(StructName)(1:length(Angle),ss) =  AngVel;
            Power = Moment.*AngVel;
            PosPower = Power(Power>0); NegPower = Power(Power<0);
            
            
            %% plot angular velocity
            figure(AngularVelFig(mm))
             if ss==1 || ss==2
                p1 = plot (AngVel,':','Color', (startColor(colors(ss),:)),...
                    'LineWidth',3);
            elseif ss==13 || ss==14
                p1 = plot (AngVel,':','Color', (startColor(colors(ss),:)),...
                    'LineWidth',3);
            else
                p1 = plot (AngVel,'-','Color', (startColor(colors(ss),:)),...
                    'LineWidth',1);    
             end
            
             %% plot moment
            figure(MomentPlot(mm))
            if ss==1 || ss==2
                p1 = plot (Moment,':','Color', (startColor(colors(ss),:)),...
                    'LineWidth',3);
            elseif ss==13 || ss==14
                p1 = plot (Moment,':','Color', (startColor(colors(ss),:)),...
                    'LineWidth',3);
            else
                p1 = plot (Moment,'-','Color', (startColor(colors(ss),:)),...
                    'LineWidth',1);    
            end
            
            %% plot power
            figure(PowerFig(mm))
            if ss==1 || ss==2
                p1 = plot (Power,':','Color', (startColor(colors(ss),:)),...
                    'LineWidth',3);
            elseif ss==13 || ss==14
                p1 = plot (Power,':','Color', (startColor(colors(ss),:)),...
                    'LineWidth',3);
            else
                p1 = plot (Power,'-','Color', (startColor(colors(ss),:)),...
                    'LineWidth',1);    
            end
            
            
            %% power calculations
            TotalPower(1:length(Power),ss) =Power;
            PositivePower(1:length(PosPower),ss) = PosPower;
            NegativePower(1:length(NegPower),ss) = NegPower;
            PeakPosPower(ss) = max(PosPower);
            PeakNegPower(ss) = min(NegPower);
                      
            % work calculations
            time = 1/fs:1/fs:length(Power)/fs;
            NetWork(ss) = trapz(time,Power);
            
            time = 1/fs:1/fs:length(PosPower)/fs;
            PosWork(ss) = trapz(time,PosPower);
            
            time = 1/fs:1/fs:length(NegPower)/fs;
            NegWork(ss) = trapz(time,NegPower);
            
            LegendNames{end+1}= TrialName; 

            %% split data if needed
            if contains(answer,'Yes')
                
                threshold = 0.5*max(Power);
                Title = sprintf('%s - subject %s',TrialName,Subject);
                [SplitData,IdxBursts] = findBursts (Power,threshold,Title);             %calback function to find POSITIVE bursts based on a threshold
                
                % assign bursts
                for fn = fieldnames(SplitData)'                                                % split name (e.g. hip_flexion_1)
                    
                    SplitPosPower.(fn{1})(1:length(SplitData.(fn{1})),ss) = SplitData.(fn{1}); % split data
                    % work calculations
                    time = 1/fs:1/fs:length(SplitData.(fn{1}))/fs;
                    SplitPosWork.(fn{1})(ss) = trapz(time,SplitData.(fn{1}));
                end
                
            end
            
            else
                TotalPower(:,ss) = NaN;
                PositivePower(:,ss) = NaN;
                NegativePower(:,ss) = NaN;
                PeakPosPower(ss) = NaN;
                PeakNegPower(ss) = NaN;
                
                % work calculations
                NetWork(ss) = NaN;
                PosWork(ss) = NaN;
                NegWork(ss) = NaN;                
            end          
        end
        %% arrange plot joint powers
        fullscreenFig(0.6,0.6) % callback function
        % place legend at 80% of the length and centered in height
        FS = 25;
        lhd = legend (LegendNames,'Interpreter','none','Location','best');
        pos = get(lhd,'Position'); pos(1)= 0.8; pos(2)=(1-pos(4))/4;
        set(lhd,'Position',pos);
        xlb = xlabel('');
        xlbPos = xlb.Position;
                
        %axis titles
        ax = gca;
        ax.XAxisLocation = 'origin';
        ax.YAxisLocation = 'origin';
        xLab = xlabel(''); p = xLab.Position; s =xLab.FontSize; c= xLab.Color;
        set(gca,'box', 'off', 'FontSize', FS);
        set(gcf,'Color',[1 1 1]);
        xRange = xlim;
 
        xlb = xlabel ('Gait Cycle (sec)');
        xlb.Position= xlbPos;
        set (xlb,'FontSize',FS*0.85,'VerticalAlignment','top','HorizontalAlignment','center')
        ylabel(sprintf('Joint Power (W/Kg)'))
        % xtick labels with only 2 decimal points
        xtic  = length(xticks)/xRange(2):length(xticks)/xRange(2):xRange(2)/fs;
        for xt = 1:length(xtic)
           tickLabels{xt} = sprintf('%.2f',xtic(xt));
        end
        xticklabels (tickLabels);
        
        % foot contact = vertical bars  
        Ymax = max(ylim);
        Ymin = min(ylim);
        Xpos = mean(FootContact);
        plot ([Xpos Xpos],[Ymin Ymax],'k')
        
        cd(DirFigRunBiomech)
        
        saveas(gca, sprintf('%s_power.jpeg',MomentName));

        %% arrange plot angular velocity
        figure (AngularVelFig(mm))
        fullscreenFig % callback function
        % place legend at 80% of the length and centered in height
        FS = 25;
        lhd = legend (LegendNames,'Interpreter','none','Location','best');
        pos = get(lhd,'Position'); pos(1)= 0.8; pos(2)=(1-pos(4))/4;
        set(lhd,'Position',pos);
        xlb = xlabel('');
        xlbPos = xlb.Position;
                
        %axis titles
        ax = gca;
        ax.XAxisLocation = 'origin';
        ax.YAxisLocation = 'origin';
        xLab = xlabel(''); p = xLab.Position; s =xLab.FontSize; c= xLab.Color;
        set(gca,'box', 'off', 'FontSize', FS);
        set(gcf,'Color',[1 1 1]);
        xRange = xlim;
        yRange= ylim;
        xlb = xlabel ('Gait Cycle (sec)');
        xlb.Position= xlbPos;
        set (xlb,'FontSize',FS*0.85,'VerticalAlignment','top','HorizontalAlignment','center')
        ylabel(sprintf('Angular veloctity (Rad/sec)'))
        
        
        % xtick labels with only 2 decimal points
        xtic  = (length(xticks)/xRange(2):length(xticks)/xRange(2):xRange(2)/fs);
        for xt = 1:length(xtic)
           tickLabels{xt} = sprintf('%.2f',xtic(xt));
        end
        xticklabels (tickLabels);
  
        
        % foot contact = vertical bars  
        Ymax = max(ylim);
        Ymin = min(ylim);
        Xpos = mean(FootContact);
        plot ([Xpos Xpos],[Ymin Ymax],'k')
        
        cd(DirFigRunBiomech)
        
        saveas(gca, sprintf('%s_angularVelocity.jpeg',MomentName));
            
        %% arrange plot Moment
        figure (MomentPlot(mm))
        fullscreenFig % callback function
        % place legend at 80% of the length and centered in height
        FS = 25;
        lhd = legend (LegendNames,'Interpreter','none','Location','best');
        pos = get(lhd,'Position'); pos(1)= 0.8; pos(2)=(1-pos(4))/4;
        set(lhd,'Position',pos);
        xlb = xlabel('');
        xlbPos = xlb.Position;
                
        %axis titles
        ax = gca;
        ax.XAxisLocation = 'origin';
        ax.YAxisLocation = 'origin';
        xLab = xlabel(''); p = xLab.Position; s =xLab.FontSize; c= xLab.Color;
        set(gca,'box', 'off', 'FontSize', FS);
        set(gcf,'Color',[1 1 1]);
        xRange = xlim;
        yRange= ylim;
        xlb = xlabel ('Gait Cycle (sec)');
        xlb.Position= xlbPos;
        set (xlb,'FontSize',FS*0.85,'VerticalAlignment','top','HorizontalAlignment','center')
        ylabel(sprintf('Joint Moment (Nm/Kg)'))
        
        
        % xtick labels with only 2 decimal points
        xtic  = (length(xticks)/xRange(2):length(xticks)/xRange(2):xRange(2)/fs);
        for xt = 1:length(xtic)
           tickLabels{xt} = sprintf('%.2f',xtic(xt));
        end
        xticklabels (tickLabels);
  
        
        % foot contact = vertical bars  
        Ymax = max(ylim);
        Ymin = min(ylim);
        Xpos = mean(FootContact);
        plot ([Xpos Xpos],[Ymin Ymax],'k')
        
        cd(DirFigRunBiomech)
        
        saveas(gca, sprintf('%s_moment.jpeg',MomentName));
        close all
        
        %% Create main figure
        MainFig = figure;
        %% plot positive power
        x = PeakPosPower;
        PPfig  = figure;
        PPplot = plot(x,'.','MarkerSize',20,'Color','k');
        hold on
        PPplot(2) = plot([0 14],[0 0],'-','Color','k');
        title('Positive Power')
        ylim([min(x)-(0.5*range(x)) max(x)+(0.5*range(x))])
        hold on
        set(gca,'box', 'off', 'FontSize', 15);
        xticks(1:length(RunNames));
        xticklabels (strrep(RunNames,'_',' '))
        xtickangle(45)
        ylabel('Max positive power (W/kg)')
        set(gcf,'Color',[1 1 1]);
        
        
         cd(DirFigRunBiomech)
        
        saveas(gca, sprintf('%s_PeakPosPower.jpeg',MomentName));
        
        mergeFigures (PPfig, MainFig,[2,2],1)    
        close (PPfig)
        %% plot negative power
        x = PeakNegPower;
        NPfig = figure;
        NPplot = plot(x,'.','MarkerSize',20,'Color','k');
        hold on
        NPplot(2) = plot([0 14],[0 0],'-','Color','k');
        
        title('Negative Power')
        ylim([min(x)-(0.5*range(x)) max(x)+(0.5*range(x))])
        hold on
        set(gca,'box', 'off', 'FontSize', 15);
        xticks(1:length(RunNames));
        xticklabels (strrep(RunNames,'_',' '))
        xtickangle(45)
        ylabel('Max positive power (W/kg)')
        set(gcf,'Color',[1 1 1]);
        
         cd(DirFigRunBiomech)
        
        saveas(gca, sprintf('%s_PeakNegPower.jpeg',MomentName));
        
        mergeFigures (NPfig, MainFig,[2,2],3)
        close (NPfig)
        %% plot net work
        x = NetWork;
        NetWorkFig = figure;
        plot(x,'.','MarkerSize',20,'Color','k')
         hold on
        plot([0 14],[0 0],'-','Color','k');
        
        title('Net Work')
        ylim([min(x)-(0.5*range(x)) max(x)+(0.5*range(x))])
        hold on
        set(gca,'box', 'off', 'FontSize', 15);
        xticks(1:length(RunNames));
        xticklabels (strrep(RunNames,'_',' '))
        xtickangle(45)
        ylabel('Net total work (J/kg)')
        set(gcf,'Color',[1 1 1]);
        
         cd(DirFigRunBiomech)
        
        saveas(gca, sprintf('%s_NetTotalWork.jpeg',MomentName)); 
        close (NetWorkFig)
        %% plot positive work
        x = PosWork;
        PWfig = figure;
        PWplot = plot(x,'.','MarkerSize',20,'Color','k');
         hold on
        PWplot(2) = plot([0 14],[0 0],'-','Color','k');
        
        title('Positive Work') 
        ylim([min(x)-(0.5*min(x)) max(x)+0.5*max(x)])
        hold on
        set(gca,'box', 'off', 'FontSize', 15);
        xticks(1:length(RunNames));
        xticklabels (strrep(RunNames,'_',' '))
        xtickangle(45)
        ylabel('Positive work (J/kg)')
        set(gcf,'Color',[1 1 1]);
        
         cd(DirFigRunBiomech)
        
        saveas(gca, sprintf('%s_NetPosWork.jpeg',MomentName));
         mergeFigures (PWfig, MainFig,[2,2],2)
         close(PWfig)
        %% plot negative work
        x = NegWork;
        NWfig = figure;
        NWplot = plot(x,'.','MarkerSize',20,'Color','k');
        hold on
        NWplot(2) = plot([0 14],[0 0],'-','Color','k');
        
        title('Negative Work')      
        ylim([min(x)-(0.5*range(x)) max(x)+(0.5*range(x))])
        hold on
        set(gca,'box', 'off', 'FontSize', 15);
        xticks(1:length(RunNames));
        xticklabels (strrep(RunNames,'_',' '))
        xtickangle(45)
        ylabel('Negative work (J/kg)')
        set(gcf,'Color',[1 1 1]);
        
         cd(DirFigRunBiomech)
        
        saveas(gca, sprintf('%s_NetNegWork.jpeg',MomentName));
        mergeFigures (NWfig, MainFig,[2,2],4)   % bottom right conor
        ST = suptitle(sprintf('Work and Power %s-%s',MomentName,Subject));
        ST.FontWeight = 'bold';
        
       
        saveas(MainFig, sprintf('%s_Work&PowerPlots.jpeg',MomentName));
        close (NWfig)
        close (MainFig)       
        %% Save data 
        idxSubject = str2double(Subject);
        StructName = strrep(MomentName,' ','_');


        JointPowers.(StructName).TotalPower{1,idxSubject} = TotalPower;
        JointPowers.(StructName).PositivePower{1,idxSubject} = PositivePower;
        JointPowers.(StructName).NegativePower{1,idxSubject}  = NegativePower;
        
        
        JointWorks.(StructName).NetWork(1:length(NetWork),idxSubject) = NetWork';
        JointWorks.(StructName).PosWork(1:length(PosWork),idxSubject) = PosWork';
        JointWorks.(StructName).NegWork(1:length(NegWork),idxSubject) = NegWork';
        
        % Split Data
        if contains(answer,'Yes')
            count = 1;
            for fn = fieldnames(SplitData)'
                SplitStructName = sprintf('%s_%d',StructName,count);
                p = SplitPosPower.(fn{1});
                p (p==0) = NaN;
                JointPowers.(SplitStructName).PositivePower{1,idxSubject} = p;
                
                w = SplitPosWork.(fn{1});
                w (w==0) = NaN;
                JointWorks.(SplitStructName).PosWork(1:length(SplitPosWork.(fn{1})),idxSubject) = w;
                count =  count + 1;
            end
        end
    end 
end
  mkdir(DirResults)
  cd(DirResults)
 
  save JointPowers JointPowers 
    save JointWorks JointWorks 
cd(DirElaborated)
     save AngularVelocity AngularVelocity
  close all
