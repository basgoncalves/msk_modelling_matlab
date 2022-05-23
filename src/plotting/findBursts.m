%

function [SplitData,IdxBursts] = findBursts (input,threshold,PlotTitle)






a=find(input > 0); % greter than 0
b=find(input < 0); %smaller than 0
BinaryData = input;
BinaryData(a)=1;
BinaryData(b)=0;
BinaryData = [0; BinaryData; 0];


%% find burst above threshold
Bursts = [];
for ii = 1: size (BinaryData,1)-1
    if BinaryData(ii)>BinaryData(ii+1) %end of the burst
        Bursts (end+1)=ii;
        
    elseif  BinaryData(ii)<BinaryData(ii+1) %beginning of the burst
        Bursts (end+1)=ii+1;
    end
    
end
Bursts = Bursts-1;
%% delete bursts which mean is below threshold
for bb = 1:2:length(Bursts)
    if max(input(Bursts(bb):Bursts(bb+1)))<= threshold
        Bursts(bb:bb+1)=0;
    end
end

Bursts(Bursts==0)=[];
%% plot data to assess it
% BurFig = figure('NumberTitle', 'off', 'Name', 'Select range. Click left from the plot to finish');
% plot(input)
% if exist('PlotTitle')
%     title(PlotTitle,'Interpret','None')
% end
% hold on
% % horizontal line for threshold
% plot([0 max(xlim)],[0 0],':k')
% 
% % vertical bars for each peak
% Ymax = max(ylim);
% n = 1;
% Txt={};
% 
% for bb = 1:2:length(Bursts)
%     Xpos = Bursts(bb);
%     plot ([Xpos Xpos],[0 Ymax],'k')
%     Xpos2 = Bursts(bb+1);
%     plot ([Xpos2 Xpos2],[0 Ymax],'k')
%     
%     Xpos = (Xpos + Xpos2)/2;
%     Txt{n} = sprintf('Peak %d',n);
%     text (Xpos,Ymax,Txt{n},'HorizontalAlignment','center')
%     
%     n = n+1;
%     
% end

%% if the peaks are not good clear the bad ones
% answer = questdlg('are the peaks good?');
% 
% if contains(answer,'Cancel')
%     error ('findBursts stopped by the user')
%     
% elseif contains(answer,'No')
%     
%     Variables = [Txt {'add peaks'}];
%     [idx,~] = listdlg('PromptString',{'Choose the correct peaks'}...
%         ,'ListString',Variables);
%     
%     n = 1;
%     for bb = 1:2:length(Bursts)
%         if idx~=n
%             Bursts(bb:bb+1)=0;
%         end
%         n = n+1;
%     end
%     Bursts(Bursts==0)=[];
%     if contains(Variables{end},'add peaks')
%         Area =  MultipleGinput (2);
%         
%         
%         for aa= 1:length(Area)
%             section = round(Area{aa}(:,1))';     % select the x (horizontal) values for each section
%             Bursts= [Bursts section];
%         end
%         
%     end
%     
%     clf
%     %%
%     plot(input)
%     hold on
%     if exist('PlotTitle')
%         title(PlotTitle,'Interpret','None')
%     end
%     % horizontal line for threshold
%     plot([0 max(xlim)],[0 0],':k')
%     
%     % vertical bars for each force plate
%     Ymax = max(ylim);
%     n = 1;
%     Txt={};
%     
%     for bb = 1:2:length(Bursts)
%         Xpos = Bursts(bb);
%         plot ([Xpos Xpos],[0 Ymax],'k')
%         Xpos2 = Bursts(bb+1);
%         plot ([Xpos2 Xpos2],[0 Ymax],'k')
%         
%         Xpos = (Xpos + Xpos2)/2;
%         Txt{n} = sprintf('Peak %d',n);
%         text (Xpos,Ymax,Txt{n},'HorizontalAlignment','center')
%         
%         n = n+1;
%         
%     end
%     
% end
% 
% 
% if isempty(Bursts)
%     Bursts = [1 length(input)];
% end

%% split input into the "good" bursts

input (input ==0)=NaN;


n =1 ;
SplitData= struct;
IdxBursts={};
for bb = 1:2:length(Bursts)
    Burst_Number = sprintf('Burst_%d',n);
    
    data = input (Bursts(bb):Bursts(bb+1));
    data(end) = threshold+0.001;
    
    IdxBursts{n} = Bursts(bb):Bursts(bb+1);
    SplitData.(Burst_Number) = data;
    n = n+1;
    
end



