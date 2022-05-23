% work loops



DirFigRunBiomech =  ([DirFigure filesep 'RunningBiomechanics' filesep Subject]);
mkdir(DirFigRunBiomech);
AcqXml = xml_read([strrep(DirElaborated,'ElaboratedData' ,'InputData') filesep 'acquisition.xml']);

cd(DirIDResults)
load ([DirIDResults filesep 'IDresults.mat']);
load ([DirIKResults filesep 'IKresults.mat']);
Joints= {'hip','knee','ankle'};
Njoints = length(Joints);
startColor = jet;
LegendNames = {};
MainFig = figure;
count =0;


for ii = 1: Njoints             %loop through joints
    CurrentJointIDData = IDresultsNormalized.(Joints{ii});
    CurrentJointIKData = IKresultsNormalized.(Joints{ii});
    TrialsJoint = fields(CurrentJointIDData);
    Ntrials = length(TrialsJoint);
    
    Nmoments = size(CurrentJointIDData.(TrialsJoint{1}),2);
    for mm = 1:Nmoments         % loop through moments
        count = count +1;
        WorkPlot(count)= figure;          
        MomentName = erase(sprintf('%s',Labels.(Joints{ii}){mm}),' angle r');
        MomentName = erase(MomentName,' angle l');
        MomentName = strrep(MomentName,'on l','on');
        MomentName = strrep(MomentName,'on r','on');
        title (sprintf('%s work loop',erase(MomentName,'angle ')))
        hold on
        HeelStrike=[];
        
        for ss = 1:Ntrials          % loop through trials
            CurrentTrial = TrialsJoint{ss};
            Moment = CurrentJointIDData.(CurrentTrial)(:,mm);
            Angle = CurrentJointIKData.(CurrentTrial)(:,mm);
            FootStrike = GaitCycle.(CurrentTrial);
            NormalizedGC = GaitCycle.(CurrentTrial)-GaitCycle.(CurrentTrial)(1)+1;
            HeelStrike(end+1) = round(GaitCycle.(CurrentTrial)(3)*100/GaitCycle.(CurrentTrial)(2));

            if ss==1 || ss==2
                p1 = plot (Angle,Moment,':','Color',...
                    (startColor(round(ss*length (startColor)/Ntrials),:)),'LineWidth',2);
            elseif ss==Ntrials || ss==Ntrials-1
                p1 = plot (Angle,Moment,':','Color', (startColor(round(ss*length (startColor)/Ntrials),:)),...
                'LineWidth',2);
            else 
                p1 = plot (Angle,Moment,'-','Color', (startColor(round(ss*length (startColor)/Ntrials),:)),...
                'LineWidth',1);
            
            end

            LegendNames{end+1}= CurrentTrial;
            
            
        end
        
         %% make plot nice
        fullscreenFig (0.8,0.8)% callback function
        % place legend at 80% of the length and centered in height
        FS= 30;
        lhd = legend (LegendNames,'Interpreter','none','Location','bestoutside');
        pos = get(lhd,'Position'); pos(1)= 0.85; pos(2)=(1-pos(4))/4;
        set(lhd,'FontSize',FS*0.6)
        xlb = xlabel('');
        xlbPos = xlb.Position;
        
        %axis titles
        ax = gca;
        ax.XAxisLocation = 'origin';
        ax.YAxisLocation = 'origin';
        ax.Position = [0.1, 0.1, 0.7, 0.7];            %[Xpos,Ypos, Xlength,Ylength]
        
        
        set(gca,'box', 'off', 'FontSize', FS);
        set(gcf,'Color',[1 1 1]);
        xLab = xlabel(''); p = xLab.Position; s =xLab.FontSize; c= xLab.Color;
        xlim([-90 120]);  xRange = xlim;
        ylim([min(Moment)-3 max(Moment)+3]);yRange= ylim;
        xlabel('Joint angle (\circ)','FontSize', FS)
        ylabel(sprintf('Joint moment (Nm/Kg)'),'FontSize', FS)
%         text(mean(xRange),yRange(1),'Joint angle(\circ)','FontSize', FS, 'Color', c);
%         text(mean(xRange),yRange(2),sprintf('Joint moment (Nm/Kg)'),'FontSize', FS, 'Color', c);
        
        cd(DirFigRunBiomech)
        
        saveas(gca, sprintf('%s_work.jpeg',MomentName));
      

    end
     
end

Nplot = length(WorkPlot);
nRows = round(Nplot/2);
for ii = 1:Nplot
    mergeFigures (WorkPlot(ii), MainFig,[nRows,2],ii)
end
cd(DirFigRunBiomech)
saveas(gca, sprintf('all_work.jpeg'));
close all

