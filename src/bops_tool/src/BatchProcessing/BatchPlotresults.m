
function BatchPlotresults
%%
bops = load_setup_bops;

analyses = fields(bops.plotresults);
for a = 1:length(analyses)
    
    iAnalysis = analyses{a};
    if bops.plotresults.(iAnalysis) == 0
        continue;
    else
        fprintf('running %s ... \n',iAnalysis)
    end
    
    for b = 1:length(bops.subjects)
        for c = 1:length(bops.sessions)
            
            iSubject = bops.subjects{b};
            iSession = bops.sessions{c};
            load_subject_settings(iSubject,iSession);                                                               % updates bops settings with current subject and session
            
            write_bops_log(['plot' iAnalysis],'start')
            
            fprintf('%s - %s \n',iSubject,iSession)
            plotBOPS(iAnalysis)
            write_bops_log;
        end
    end
end
