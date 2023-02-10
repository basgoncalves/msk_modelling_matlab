function results = bops_get_external_biomech

project_settings = load_setup_bops;
subjects = split(project_settings.subjects,' ');
sessions = split(project_settings.sessions,' ');
time_window_trial = project_settings.plot_variables.time_window;
dofList = {'pelvis_tilt' 'pelvis_list' 'pelvis_rotation' 'pelvis_tx' 'pelvis_ty' 'pelvis_tz' ...
    'lumbar_extension' 'lumbar_bending' 'hip_flexion','hip_adduction','hip_rotation','knee_angle','ankle_angle'};

results = struct;
results.ik = struct;
results.id = struct;

for b = 1:length(subjects)
    for c = 1:length(sessions)

        iSubject = subjects{b};
        iSession = sessions{c};
        fprintf('%s - %s \n',iSubject,iSession)

        settings = load_subject_settings(iSubject,iSession);                                          % updates bops settings with current subject and session
        TestedLeg = settings.subjectInfo.InstrumentedSide;
        if isempty(settings); continue; end
        trialList = settings.trials.dynamic;
        for iTrial = 1:length(trialList)
            trialName = trialList{iTrial} ;
            [osimFiles] = getdirosimfiles_BOPS(trialName);    
            try 
                results_JRA = load_sto_file(osimFiles.(time_window_trial));
            catch
                continue
            end

            TimeWindow = [results_JRA.time(1) results_JRA.time(end)];
            dofList_ik = dofList;
            idx=~contains(dofList,{'pelvis' 'lumbar'});
            dofList_ik(idx) = strcat(dofList_ik(idx),['_' lower(TestedLeg)]);

            dofList_id = strcat(dofList,'_moment');
            dofList_id(contains(dofList_id,'pelvis_tx')) = strrep(dofList_id(contains(dofList_id,'pelvis_tx')),'moment','force'); % replace 'moment' by 'force' in pelvis_t
            dofList_id(contains(dofList_id,'pelvis_ty')) = strrep(dofList_id(contains(dofList_id,'pelvis_ty')),'moment','force');
            dofList_id(contains(dofList_id,'pelvis_tz')) = strrep(dofList_id(contains(dofList_id,'pelvis_tz')),'moment','force');

            [ik,coordinates] = bops_load_results (osimFiles.IKresults,TimeWindow,dofList_ik,[],1,0);
            [id,coordinates_id] = bops_load_results(osimFiles.IDresults,TimeWindow,dofList_id,[],1,0);

            for iCoor = 1: length(coordinates)
                results.ik.(trialName).(coordinates{iCoor})(:,b) = ik(:,iCoor);
                results.id.(trialName).(coordinates{iCoor})(:,b) = id(:,iCoor);
            end       
        end
    end
end

