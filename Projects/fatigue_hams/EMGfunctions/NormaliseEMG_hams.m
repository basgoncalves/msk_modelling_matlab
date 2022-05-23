

Conditions = fields(MeanEMG_perSubj)';
Muscles = {'BF', 'ST'};
%only 15 channels (16th is a sum)
MVC = MeanEMG_perSubj.MVC.(Muscle);



NormEMG_PerSubject= struct;
for MM = Muscles
    for CC = Conditions
        if contains(CC{1},{'25' '50' '75'})
            if ~isfield(NormEMG_PerSubject,(CC{1}))
                NormEMG_PerSubject.(CC{1})= struct;
            end
            NormEMG_PerSubject.(CC{1}).(MM{1}) = [];
            OG_EMG = MeanEMG_perSubj.(CC{1}).(MM{1});
            NormEMG = MeanEMG_perSubj.(CC{1}).(MM{1})./MVC*100;
            NormEMG_PerSubject.(CC{1}).(MM{1}) = NormEMG;
            
            % plot data
            
            cMat = lines;
            lg = {};
            for row = 1:size(NormEMG,1)% [1 4 6 9]%
                figure
                hold on
                % create a vector with number of channels (cols) - last one
                % (sum of all channels)
                x = 1:(size(NormEMG,2))-1; 
                y = NormEMG(row,1:end-1);
                p = plot(x,y,'-o','MarkerSize',10,'MarkerFaceColor',cMat(row,:),...
                    'MarkerEdgeColor',cMat(row,:),'Color',cMat(row,:));
                %                 lg{end+1} = ['s0' num2str(row)];
                tt = sprintf('%s (%.f%% MVC) - s%.f',CC{1},RelativeForce.(CC{1})(row),row);
                title(tt,'Interpreter','none')
                xticks([1 8 15])
                xticklabels({'Distal', 'Middle', 'Proximal'})
                xlabel('EMG channels')
                yl = ylabel(sprintf('EMG amplitude\n (%% of MVIC)   '));
                yl.Rotation = 0;
                yl.HorizontalAlignment = 'right';
                %             legend(lg)
                mmfn
                ax = gca;
                ax.Position =[0.18 0.11 0.75 0.81];
                yyaxis right
                plot(MVC(row,1:end-1))
                plot(OG_EMG(row,1:end-1))
                legend('% MVC','MVC (mV)')
            end
            
        else
            continue
        end
    end
end

