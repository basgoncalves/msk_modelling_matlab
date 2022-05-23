%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves

function MissingTrials = GatherRRAresults(Subjects,SkipSubjects)

fp = filesep;
warning off
Dir = getdirFAI;
savedir = [Dir.Results fp 'RRA'];

RRAresults = struct;
if exist([savedir fp 'RRAresults.mat'])
    load([savedir fp 'RRAresults.mat'])
else
    RRAresults.ID = struct;
    RRAresults.IDrra = struct;
    RRAresults.IDceinms = struct;
    RRAresults.IK = struct;
    RRAresults.IKrra = struct;
    RRAresults.OriginalResiduals=struct;
    RRAresults.PostRRAResiduals=struct;
    RRAresults.PostRRAResiduals_COMOnly=struct;
    RRAresults.MassAdjustments=struct; % results
    RRAresults.Participants = {};
    
    
end
MissingTrials={};

[~,~,SubjectInfo,~] = getdirFAI(Subjects{1});
Demographics = fields(SubjectInfo)';

for Subj = 1:length(Subjects)
    
    if any(Subj==SkipSubjects); continue; end
    
    [Dir,~,SubjectInfo,Trials] = getdirFAI(Subjects{Subj});
    if isempty(Trials.CEINMS) || isempty(fields(SubjectInfo)) || length(dir(Dir.CEINMS))<3
        continue
    end
    
    Demographics(Subj+1,:)=struct2cell(SubjectInfo)';
    disp([Subjects{Subj} '...'])
    
    s = lower(SubjectInfo.TestedLeg);
    moments = {'pelvis_tx_force';'pelvis_ty_force';'pelvis_tz_force';'pelvis_tilt_moment';'pelvis_list_moment';'pelvis_rotation_moment';['hip_flexion_' s '_moment']; ['hip_adduction_' s '_moment']; ['hip_rotation_' s '_moment']; ['knee_angle_' s '_moment'];['ankle_angle_' s '_moment']};
    coordinates = {'pelvis_tx';'pelvis_ty';'pelvis_tz';'pelvis_tilt';'pelvis_list';'pelvis_rotation';['hip_flexion_' s]; ['hip_adduction_' s]; ['hip_rotation_' s]; ['knee_angle_' s];['ankle_angle_' s]};
    coordinates_simple = {'pelvis_tx';'pelvis_ty';'pelvis_tz';'pelvis_tilt';'pelvis_list';'pelvis_rotation';'hip_flexion';'hip_adduction';'hip_rotation';'knee_angle';'ankle_angle'};

    lablesToInvert = {'pelvis_tz_force' 'pelvis_list' 'pelvis_rotation'};          
    
    TrialList = Trials.CEINMS;
    TrialList_General = getstrials(Trials.CEINMS,SubjectInfo.TestedLeg);
    for t = 1:length(TrialList_General)
        % use to check if subject are missing
        %          trialName = TrialList{t};
        %         [osimFiles] = getosimfilesFAI(Dir,trialName);
        %         if ~exist(osimFiles.RRAinverse_dynamics)
        %         MissingTrials{end+1,1}={SubjectInfo.ID};
        %         MissingTrials{end,2}={trialName};
        %         end
        %     end
        % end
        
        trialName = TrialList{t}; disp(trialName)
        [osimFiles] = getosimfilesFAI(Dir,trialName);
        
        RRAxml = xml_read([osimFiles.RRAsetup]);
        TimeWindow = [RRAxml.RRATool.initial_time RRAxml.RRATool.final_time];
        MatchWholeWord = 1;  Normalise = 1;
        
        [IDData,Labels] = LoadResults_BG (osimFiles.IDresults,TimeWindow,moments,MatchWholeWord,Normalise);              % load ID data (original, post rra, and post mass adjustments only)
        [IDrraData,~] = LoadResults_BG (osimFiles.RRAinverse_dynamics,TimeWindow,moments,MatchWholeWord,Normalise);
        [IDCeinmsData,~] = LoadResults_BG (osimFiles.IDRRAresults,TimeWindow,moments,MatchWholeWord,Normalise);
        
        [IK,~] = LoadResults_BG (osimFiles.IKresults,TimeWindow,coordinates,MatchWholeWord,Normalise);                   % load IK data
        [IKrra,~] = LoadResults_BG (osimFiles.RRAkinematics,TimeWindow,coordinates,MatchWholeWord,Normalise);
        
        if contains(SubjectInfo.TestedLeg,'L')                                    % INVERT pelvis data from left leg                         
            for l = 1:length(lablesToInvert)
            idx = find(contains(Labels,lablesToInvert{l}));
            if ~contains(lablesToInvert{l},'pelvis_tz_force')
                IK(:,idx)=-IK(:,idx);  
                IKrra(:,idx)=-IKrra(:,idx);    
            end
            IDData(:,idx)=-IDData(:,idx);
            IDrraData(:,idx)=-IDrraData(:,idx);
            IDCeinmsData(:,idx)=-IDCeinmsData(:,idx);
            end
        end
        
        [m,NR,OR,labels,CR] = adjMass([osimFiles.RRA fp 'out.log']);         % load residuals from log file
        
        RRAresults.MassAdjustments.Total.(TrialList_General{t})(:,Subj) = m;
        for ii = 1:length(labels)
            RRAresults.PostRRAResiduals.(labels{ii}).(TrialList_General{t})(:,Subj) = NR(ii);
            RRAresults.PostRRAResiduals_COMOnly.(labels{ii}).(TrialList_General{t})(:,Subj) = CR(ii);
            RRAresults.OriginalResiduals.(labels{ii}).(TrialList_General{t})(:,Subj)= OR(ii);
        end
        
        for ii = 1:size(IDData,2)
            RRAresults.ID.(coordinates_simple{ii}).(TrialList_General{t})(:,Subj)=IDData(:,ii);
            RRAresults.IDrra.(coordinates_simple{ii}).(TrialList_General{t})(:,Subj)=IDrraData(:,ii);
            RRAresults.IDceinms.(coordinates_simple{ii}).(TrialList_General{t})(:,Subj)=IDCeinmsData(:,ii);
            RRAresults.IK.(coordinates_simple{ii}).(TrialList_General{t})(:,Subj)=IK(:,ii);
            RRAresults.IKrra.(coordinates_simple{ii}).(TrialList_General{t})(:,Subj)=IKrra(:,ii);
        end
        RRAresults.IKceinms  = RRAresults.IK;
    end
    
    %% mean per trial Group (walking/running)
    TrilaGroups = getTrialType_multiple(TrialList_General);
    TrilaGroups = unique(TrilaGroups,'stable');
    Flds = fields(RRAresults);
    Flds(contains(Flds,{'Participants'}))=[];
    
    for f = 1:length(Flds)
        Vars  = fields(RRAresults.(Flds{f}));
        for v = 1:length(Vars)
            D = RRAresults.(Flds{f}).(Vars{v});                       % current data for each var and field
            for g = TrilaGroups
                idxTrials = find(contains(TrialList_General,g{1}));
                if isfield(D,['mean' g{1}]); D = rmfield(D,(['mean' g{1}])); end
                MeanTrialName = ['Mean' g{1}];
                m = zeros(size(D.(TrialList_General{idxTrials(1)})(:,Subj)));
                for i = idxTrials
                    m = m + D.(TrialList_General{i})(:,Subj);             % sum all the columns for current subject
                end
                D.(MeanTrialName)(:,Subj) = m./length(idxTrials);          % devide by the number of trials in this "group"
            end
            RRAresults.(Flds{f}).(Vars{v})=D;                               % update main sruct
        end
    end
    cd(savedir)
    save('RRAresults.mat','RRAresults')
end
VariableNames = Demographics(1,:);VariableNames{2} = 'ExcelRow';
Demographics = cell2table(Demographics(2:end,:));
Demographics.Properties.VariableNames = VariableNames;
cd(savedir)
save('RRAresults.mat','RRAresults','Demographics')



% load('RRAresults.mat')
% Subjects = RRAresults.Participants;
% 
% for Subj = 1:length(Subjects)
%     [Dir,~,SubjectInfo,Trials] = getdirFAI(Subjects{Subj});
%     TrialList = Trials.CEINMS;
%     TrialList_General = getstrials(Trials.CEINMS,SubjectInfo.TestedLeg);
%     
%     TrilaGroups = getTrialType_multiple(TrialList_General);
%     TrilaGroups = unique(TrilaGroups,'stable');
%     Flds = fields(RRAresults);
%     Flds(contains(Flds,{'Participants'}))=[];
%     
%     for f = 1:length(Flds)
%         Vars  = fields(RRAresults.(Flds{f}));
%         for v = 1:length(Vars)
%             D = RRAresults.(Flds{f}).(Vars{v});                       % current data for each var and field
%             for g = TrilaGroups
%                 idxTrials = find(contains(TrialList_General,g{1}));
%                 if isfield(D,['mean' g{1}]); D = rmfield(D,(['mean' g{1}])); end
%                 MeanTrialName = ['Mean' g{1}];
%                 m = zeros(size(D.(TrialList_General{idxTrials(1)})(:,Subj)));
%                 for i = idxTrials
%                     m = m + D.(TrialList_General{i})(:,Subj);             % sum all the columns for current subject
%                 end
%                 D.(MeanTrialName)(:,Subj) = m./length(idxTrials);          % devide by the number of trials in this "group"
%             end
%             RRAresults.(Flds{f}).(Vars{v})=D;                               % update main sruct
%         end
%     end
% end