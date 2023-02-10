function bops_plot_results

project_settings = load_setup_bops;
subjects = split(project_settings.subjects,' ');
sessions = split(project_settings.sessions,' ');

analyses = fields(project_settings.plot_analysis);
logic_values = project_settings.plot_analysis;

for a = 1:length(analyses)

    iAnalysis = analyses{a};
    if logic_values.(iAnalysis) == 0
        continue;
    else
        fprintf('running %s ... \n',iAnalysis)
    end
   
    for b = 1:length(subjects)
        for c = 1:length(sessions)

            iSubject = subjects{b};
            iSession = sessions{c};
            fprintf('%s - %s \n',iSubject,iSession)

            settings = load_subject_settings(iSubject,iSession,iAnalysis);                                          % updates bops settings with current subject and session
            
            if isempty(settings); continue; end

            write_bops_log(iAnalysis,'start')

           
            switch iAnalysis
                case 'subjectSetup'; setupSubject;
                case 'ik'         
                        

                case 'acquisition';  AcquisitionInterface_BOPS
                case 'elaboration';  runElaboration_BOPS
                case 'c3dExport';    c3dExport_BOPS
                case 'scale';        runScale                                                                       % Linear scale model based on marker data
                otherwise
            end
            write_bops_log;
        end
    end
end


