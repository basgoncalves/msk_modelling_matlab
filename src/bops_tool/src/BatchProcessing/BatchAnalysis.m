function BatchAnalysis

bops = load_setup_bops;

analyses = fields(bops.analyses);
for a = 1:length(analyses)

    iAnalysis = analyses{a};
    if bops.analyses.(iAnalysis) == 0
        continue;
    else
        fprintf('running %s ... \n',iAnalysis)
    end

    for b = 1:length(bops.subjects)
        for c = 1:length(bops.sessions)

            iSubject = bops.subjects{b};
            iSession = bops.sessions{c};
            fprintf('%s - %s \n',iSubject,iSession)

            settings = load_subject_settings(iSubject,iSession,iAnalysis);                                          % updates bops settings with current subject and session
            
            if isempty(settings); continue; end

            write_bops_log(iAnalysis,'start')

           
            switch iAnalysis
                case 'subjectSetup'; setupSubject;
                case 'c3d2mat';      C3D2MAT_BOPS                                                                   % convert files from .c3d to .mat files (see ..ElaboratedData\dynamicElaboration)
                case 'acquisition';  AcquisitionInterface_BOPS
                case 'elaboration';  runElaboration_BOPS
                case 'c3dExport';    c3dExport_BOPS
                case 'scale';        runScale                                                                       % Linear scale model based on marker data
                case 'torsionTool';  runTorsionTool                                                                    
                case 'ik';           runBOPS_IK
                case 'id';           runBOPS_ID
                case 'rra';          runBOPS_RRA
                case 'id_postrra';   runBOPS_ID_postrra
                case 'lucaoptimizer';runBOPS_LucaOptimizer
                case 'handsfield';   runBOPS_Handsfield
                case 'ma';           runBOPS_MA
                case 'cmc';          runBOPS_CMC
                case 'ceinms';       runBOPS_CEINMS
                case 'so';           runBOPS_SO
                case 'jra';          runBOPS_JRA
                otherwise
            end
            write_bops_log;
        end
    end
end