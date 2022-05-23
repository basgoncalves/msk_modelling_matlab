

% CEINMS = data struct resulting from "importCEINMSResults.m"

function plotCEINMSResults (CEINMS,Subject)

SubjCol = find(contains(CEINMS.participants,Subject));
muscles = fields(CEINMS.mforces);
figure
hold on
N = ceil(sqrt(length(muscles)));
% muscle forces
for k = 1:length(muscles)
    subplot(N,N,k)
    hold on
    trials = fields(CEINMS.mforces.(muscles{k}));
    for kk = 1:length(trials)
        plot(CEINMS.mforces.(muscles{k}).(trials{kk})(:,SubjCol))
    end
    title(muscles{k},'Interpreter','none')
end

lg = legend(trials,'Interpreter','none');
lg.Position=[0.92 0.6 0.06 0.06];
fullscreenFig(0.8,0.8)
f = gcf;
f.Color = [1 1 1];

