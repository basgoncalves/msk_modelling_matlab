% CI of LoA - https://journals.sagepub.com/doi/10.1177/0962280216665419?url_ver=Z39.88-2003&rfr_id=ori:rid:crossref.org&rfr_dat=cr_pub%20%200pubmed
% CI = ±t0.975,??12.92?sdiffn?
function [baAH,fig,x,y,deleted] = BlandAltmanPercentage_BG(data)

data(data==0) = NaN;
[data,deleted] = rmmissing(data);
x=data(:,1);
y= data(:,2);
Percdiff = (y-x)./x*100;
MeanDiff = mean(Percdiff);
SDDiff = std(Percdiff);
N = length(Percdiff);
t = tinv(0.975,N);

uLOA = MeanDiff+(1.96*SDDiff);
uLOACIu = uLOA + t*sqrt(2.92)*(SDDiff/sqrt(N));
uLOACIl = uLOA - t*sqrt(2.92)*SDDiff/sqrt(N);

lLOA = MeanDiff-(1.96*SDDiff);
lLOACIu = lLOA + t*sqrt(2.92)*SDDiff/sqrt(N);
lLOACIl = lLOA - t*sqrt(2.92)*SDDiff/sqrt(N);


x=mean(data,2);
y=Percdiff;
p = polyfit(x,y,1);
x2 = min(x):max(x)/100:max(x);
y2 = polyval(p,x2);
[R,~] = corrcoef (x,y);

fig = figure;
set(fig,'units','centimeters','position',[3 3 20 10],'color','w');
baAH = scatter(x,y,'SizeData',20,'MarkerFaceColor',[.7 .7 .7],...
        'MarkerEdgeColor','k');
% axis('square')    
hold on

xlabel('Mean')
ylabel('Difference (%)')
xlim([0 max(x)*1.1])
ylim([lLOACIl-5 uLOACIu+5])


%% plot mean baias
Limits =[MeanDiff uLOA lLOA uLOACIu uLOACIl lLOACIl lLOACIu];
Labels = {'Bias' 'uLoA' 'lLOA' 'CI' 'CI' 'CI' 'CI'};
LineType = {'--' '--' '--' ':' ':' ':' ':'};
FS = 13;
for i = 1:7
    plot([0 max(mean(data,2))],[Limits(i) Limits(i)],LineType{i},'color','k');
    BiasText = text(max(x)*1.05,Limits(i),sprintf('%s = %.0f',Labels{i},Limits(i)));
    BiasText.FontSize = FS;
    BiasText.FontName = 'Times New Roman';
end

%plot zero level
plot([0 max(mean(data,2))],[0 0],'-','color','k');
% get(gca,'Position')
set(gca,'FontSize', FS, 'Position', [0.18 0.22 0.7 0.65])

%plot heteroscedasticity correlation
% plot(x2,y2,'.','color','r');
% s = sprintf('y = %.2fx + %.2f \n R^2 = %.2f',p(1),p(2),R(2)^2);
% text(max(x),(uLOA+(MeanDiff))/2,s);

