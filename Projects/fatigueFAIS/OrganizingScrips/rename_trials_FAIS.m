function rename_trials_FAIS


project_settings = load_setup_bops;
subjects = split(project_settings.subjects,' ');
sessions = split(project_settings.sessions,' ');
List = {};
for iSub = 1:length(subjects)
    for iSess = 1:length(sessions)
        
        iSubject = subjects{iSub};
        iSession = sessions{iSess};
        fprintf('%s - %s \n',iSubject,iSession)

        settings = load_subject_settings(iSubject,iSession);
        trialList = settings.trials.dynamic;
        TestedLeg = settings.subjectInfo.InstrumentedSide;

        row = size(List,1)+1;

        List(row,:) = repmat({''}, 1, size(List, 2));
        List{row,1} = iSubject;
        List{row,2} = iSession;
        for iTrial = 1:length(trialList)
            trialName = trialList{iTrial};

            if contains(trialName,'baselineB','IgnoreCase',1) && contains(trialName,'1','IgnoreCase',1)
                newTrialName = 'RunStraight2';

            elseif contains(trialName,'baselineB','IgnoreCase',1) && contains(trialName,'2','IgnoreCase',1)   % 2nd cut with the right
                if contains(TestedLeg,'R'); newTrialName = 'CutTested2';
                else; newTrialName = 'CutOposite2'; end

            elseif contains(trialName,'baselineB','IgnoreCase',1) && contains(trialName,'3','IgnoreCase',1)   % 2nd cut with the left
                if contains(TestedLeg,'R'); newTrialName = 'CutOposite2';
                else; newTrialName = 'CutTested2'; end

            elseif contains(trialName,'baseline','IgnoreCase',1) && contains(trialName,'1','IgnoreCase',1)
                newTrialName = 'RunStraight1';

            elseif contains(trialName,'baseline','IgnoreCase',1) && contains(trialName,'2','IgnoreCase',1)    % 1st cut with the right
                if contains(TestedLeg,'R'); newTrialName = 'CutTested1';
                else; newTrialName = 'CutOposite1'; end

            elseif contains(trialName,'baseline','IgnoreCase',1) && contains(trialName,'3','IgnoreCase',1)    % 1st cut with the left
                if contains(TestedLeg,'R'); newTrialName = 'CutOposite1';
                else; newTrialName = 'CutTested1'; end

            else
                newTrialName = trialName;
            end

            List{row,2+iTrial} = newTrialName;

            if ~isequal(trialName,newTrialName)
                [osimFiles] = getdirosimfiles_BOPS(trialName);
                filesNames = fields(osimFiles);
                
                % dynamic elaborations
                old_folder = fileparts(osimFiles.emg);
                new_folder = strrep(old_folder,trialName,newTrialName);
                try movefile(old_folder,new_folder); end 
                try movefile([new_folder fp trialName '.mot'],[new_folder fp 'grf.mot']); end
                try movefile([new_folder fp trialName '.trc'],[new_folder fp 'markers.trc']); end


                % IK
                old_folder = fileparts(osimFiles.IKresults);
                new_folder = strrep(old_folder,trialName,newTrialName);
                try movefile(old_folder,new_folder); end 
                try movefile([new_folder fp trialName '.mot'],[new_folder fp 'grf.mot']); end
                try movefile([new_folder fp trialName '.trc'],[new_folder fp 'markers.trc']); end

                % ID
                old_folder = fileparts(osimFiles.IDresults);
                new_folder = strrep(old_folder,trialName,newTrialName);
                try movefile(old_folder,new_folder); end 
                try movefile([new_folder fp trialName '.mot'],[new_folder fp 'grf.mot']); end
                try movefile([new_folder fp trialName '.trc'],[new_folder fp 'markers.trc']); end

                % JRA
                old_folder = fileparts(osimFiles.JRAresults);
                new_folder = strrep(old_folder,trialName,newTrialName);
                try movefile(old_folder,new_folder); end 

                % CEINMS simulations
                old_folder = [settings.directories.CEINMSsimulations  fp trialName];
                new_folder = strrep(old_folder,trialName,newTrialName);
                try movefile(old_folder,new_folder); end 
                
                % CEINMS first execution simulations
                old_folder = [settings.directories.CEINMSsimulations fp 'FirstExecution' fp trialName];
                new_folder = strrep(old_folder,trialName,newTrialName);
                try movefile(old_folder,new_folder); end 
                
                % CEINMS setup files 
                old_folder = [settings.directories.CEINMSsetup fp trialName '.xml'];
                new_folder = strrep(old_folder,trialName,newTrialName);
                try movefile(old_folder,new_folder); end 

                % CEINMS trials xml
                old_folder = [settings.directories.CEINMStrials fp trialName '.xml'];
                new_folder = strrep(old_folder,trialName,newTrialName);
                try movefile(old_folder,new_folder); end 

            end
        end
    end
end