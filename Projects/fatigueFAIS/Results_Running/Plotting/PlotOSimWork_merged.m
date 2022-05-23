% PlotOSimWork_merged
% work loops



DirFigRunBiomech =  ([DirFigure filesep 'RunningBiomechanics' filesep Subject]);
mkdir(DirFigRunBiomech);
AcqXml = xml_read([strrep(DirElaborated,'ElaboratedData' ,'InputData') filesep 'acquisition.xml']);

cd(DirIDResults)
load ([DirIDResults filesep 'IDresults.mat']);
load ([DirIKResults filesep 'IKresults.mat']);
Joints= fields(IDresultsNormalized);
Njoints = length(Joints);
startColor = jet;
LegendNames = {};
hh = figure;



for ii = 1: Njoints             %loop through joints
    CurrentJointIDData = IDresultsNormalized.(Joints{ii});
    CurrentJointIKData = IKresultsNormalized.(Joints{ii});
    TrialsJoint = fields(CurrentJointIDData);
    Ntrials = length(TrialsJoint);
    
    Nmoments = 1;
    for mm = 1:Nmoments         % loop through moments
        figure
        MomentName = erase(sprintf('%s',Labels.(Joints{ii}){mm}),' angle r');
        MomentName = erase(MomentName,' angle l');
        MomentName = strrep(MomentName,'on l','on');
        MomentName = strrep(MomentName,'on r','on');
        hold on
        
        
        for ss = 1:Ntrials          % loop through trials
            TrialName = TrialsJoint{ss};
            Moment = CurrentJointIDData.(TrialName)(:,mm);
            Angle = CurrentJointIKData.(TrialName)(:,mm);
            FootStrike = GaitCycle.(TrialName);
                                     
            if ss==1 || ss==2
                p1 = plot (Angle,Moment,':','Color', (startColor(round(ss*length (startColor)/Ntrials),:)),...
                'LineWidth',1);
            elseif ss==Ntrials || ss==Ntrials-1
                p1 = plot (Angle,Moment,':','Color', (startColor(round(ss*length (startColor)/Ntrials),:)),...
                'LineWidth',1);
            else 
                p1 = plot (Angle,Moment,'-','Color', (startColor(round(ss*length (startColor)/Ntrials),:)),...
                'LineWidth',1);
            
            end

            LegendNames{end+1}= TrialName;
            
            
        end
        
       
        
        %% copy to main figure
        axesVal = findobj(gcf,'Type','axes');
        handle = get(axesVal,'Children');
        figure(hh);
        s = subplot(Njoints,1,ii);  % You said 3 subplots in each figure and total 2 figures. Thus 6 section on the figure
        copyobj(handle,s);
        
        %% make plot nice
        fullscreenFig(0.3,0.75)
        
        
        %axis titles
        ax = gca;
        ax.XAxisLocation = 'origin';
        ax.YAxisLocation = 'origin';
        set(gca,'box', 'off', 'FontSize', 10);
        set(gcf,'Color',[1 1 1]);
        xLab = xlabel(''); p = xLab.Position; s =xLab.FontSize; c= xLab.Color;
        xlim([-90 120]);  xRange = xlim;
        ylim([min(Moment)-3 max(Moment)+3]);yRange= ylim;
        text(mean(xRange),yRange(1),'Joint angle(\circ)','FontSize', s, 'Color', c);
        text(mean(xRange),yRange(2),sprintf('Joint moment (Nm/Kg)'),'FontSize', s, 'Color', c);
        title (sprintf('%s work loop',erase(MomentName,'angle ')))
              

    end
     
end

% place legend at 80% of the length and centered in height
        
        
        lhd = legend (LegendNames,'Interpreter','none','Location','best');
        pos = get(lhd,'Position'); pos(1)= 0.85; pos(2)=(1-pos(4))/4;
        set(lhd,'Location','best');
        set(lhd,'FontSize',8)

        cd(DirFigRunBiomech)
        
        saveas(gca, sprintf('workLoops_all.jpeg'));
close all

