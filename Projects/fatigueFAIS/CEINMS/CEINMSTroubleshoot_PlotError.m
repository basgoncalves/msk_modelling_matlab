function CEINMSTroubleshoot_PlotError(MainStruct,Param,trial,Vars,A,B,PP)

N = length(Vars);
Gammas = MainStruct.(Param).(trial).(Vars{1}).(A).(B).Properties.VariableNames;
[ax,~,FirstCol,LastRow]=tight_subplotBG(N,0,PP.Gap,PP.Nh,PP.Nw,PP.Size);
suptitle(['R2 ' (Param) ' (EMG vs Adjusted EMG)-' trial])
for i = 1:N
   axes(ax(i)); hold on;
   T = MainStruct.(Param).(trial).(Vars{i}).(A).(B);
   sortedNames = natsortfiles(T.Properties.VariableNames(2:end)); % sort alpha numerically (by  Stephen Cobeldick)
   Double = table2array([T(:,1) T(:,sortedNames)]);
   Double(Double==0)=NaN;
   y = nanmean(Double);
   if max(Double)<1.1;ylim([0 1]);end
   x =[1:length(Gammas)];
   Nsubj=[];
   for ii = x; Nsubj(ii)=length(find(~isnan(Double(:,ii)))); end
   t = tinv(1-0.05/2,Nsubj);
   CI = nanstd(Double,0,1)/sqrt(Nsubj)*t; 
   plot(x,y,'o','MarkerFaceColor',[.5 .5 .5])
   er = errorbar(x,y,CI,CI, '.', 'color','k');   
   yticklabels(yticks)
   if any(i==LastRow); xticks(x); xticklabels(Gammas);end
   title(Vars{i})
end
mmfn_inspect