
function BatchPlotresults
%%
bops = load_setup_bops;

if contains(bops.analysis_type.plot,'manual')
    bops.analysis_type.plot = 'batch';
    xml_write(bops.directories.setupbopsXML,bops,'bops',bops.xmlPref);
end

analyses = fields(bops.plot_analysis);
for a = 1:length(analyses)
    
    iAnalysis = analyses{a};
    if bops.plot_analysis.(iAnalysis) == 0
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
