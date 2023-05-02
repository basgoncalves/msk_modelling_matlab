
function actiavtionCompare(savedir)

fp = filesep;
mainDir = fileparts(fileparts([mfilename('fullpath') '.m']));
tesdataDir = [mainDir '\TestData'] ; % Base Directory to base results directory.
cd(tesdataDir)

if nargin < 1; savedir = [tesdataDir fp 'figures']; end

if ~isfolder(savedir); mkdir(savedir); end

AVA = '_AVA_p0';

figure; hold on
for i = [0,1,10,100,500,1000]
    [data1,labels] = LoadResults_BG([tesdataDir '\results_SO_left_1_Pen' num2str(i) AVA '\results_states.sto']);

    col = contains(labels,'/forceset/recfem_l/activation');


    plot(data1(:,col))
end

lg = legend({'0','1','10','100','500','1000'});
title('effect of RF penalty weight on RF activation')
ylabel('activation')
xlabel('gait cycle')
mmfn_inspect

saveas(gcf,[savedir fp 'activations_RF' AVA '.tiff'])