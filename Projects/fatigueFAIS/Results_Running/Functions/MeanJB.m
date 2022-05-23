% MeanJB
% mean joint biomechanics
% change The organise mode to automatic if don't want to select individual
% trials (~Line 41)

function MeanJB (SubjectFoldersElaborated,sessionName, Joints)

fp = filesep;
if ~exist('SubjectFoldersElaborated') || isempty(SubjectFoldersElaborated)
    SubjectFoldersElaborated  = uigetmultiple('','Select all the subject folders in the elaborated folder to run kinematics');
end

%generate the first subject 
folderParts = split(SubjectFoldersElaborated{1},filesep);
Subject = folderParts{end};
 
MeanAngle = [];
MeanMoment = [];
MeanAngVel = [];
MeanPowers = [];
MeanPosWork = [];
MeanNegWork = [];
MeanFootContact = [];
MeanBiomech = struct;
for jj = 1:length(Joints)
    
    JointMotion = Joints{jj};
    for ff = 1:length(SubjectFoldersElaborated)
        Run= struct;
        OldSubject = Subject;
        folderParts = split(SubjectFoldersElaborated{ff},filesep);
        Subject = folderParts{end};
        DirIDResults = [strrep(SubjectFoldersElaborated{ff},OldSubject,Subject) filesep sessionName filesep 'inverseDynamics' filesep 'results'];
        DirIKResults = [strrep(SubjectFoldersElaborated{ff},OldSubject,Subject) filesep sessionName filesep 'inverseKinematics' filesep 'Results'];
        DirC3D = [strrep(SubjectFoldersElaborated{ff},'ElaboratedData','InputData') filesep sessionName];
        
        fprintf('participant %s... \n',Subject)
        
        OrganiseFAI

        % organise
        %  rearrangeJointBiomechancis
        rearrangeJointBiomechancis_manual
        
        JointMotion = cleanOSName (JointMotion);
    end
    
N = x;

[MeanAngle,SDAngle] = MeanEveryNcol (MeanAngle,N);
[MeanAngVel,SDAngVel] = MeanEveryNcol (MeanAngVel,N);
[MeanMoment,SDMoment] = MeanEveryNcol (MeanMoment,N);
[MeanPowers,SDPower] = MeanEveryNcol (MeanPowers,N);

IndividualPosWork = MeanPosWork;
SDPosWork = std(MeanPosWork,1);
MeanPosWork = mean (MeanPosWork,1);

IndividualNegWork = MeanNegWork;
SDNegWork = std(MeanNegWork,1);
MeanNegWork = mean (MeanNegWork,1);

SDFootContact = std(MeanFootContact,1);
MaxFootContact = max(MeanFootContact);
MinFootContact = min(MeanFootContact);
MeanFootContact = mean(MeanFootContact,1);


end

%% save data 
Labels = TrialNames;
cd(DirResults)
filename = cleanOSName (JointMotion{1}); % remove "_" , "_l" ...
filename = sprintf('MeanBiomech_%s',filename);

save (filename, 'MeanAngle','SDAngle','MeanAngVel','SDAngVel','MeanMoment','SDMoment',...
    'MeanPowers','SDPower','MeanFootContact','SDFootContact','MaxFootContact','MinFootContact',...
    'IndividualPosWork','MeanPosWork','SDPosWork','IndividualNegWork','MeanNegWork','SDNegWork', 'Labels');
