% S = getOSIMVariablesFAI(testedLeg)
% Creates a structure with the names of the variables to be used in the FAI
% project
% 
% OUTPUT
%   S = struct with all the varibale names and coordinates for the assigned dofs 

function dofList = bops_get_dofs

settings = load_subject_settings;
s = lower(settings.subjectInfo.InstrumentedSide); 

 [osimFiles] = getdirosimfiles_BOPS(trialName);    
settings.trials.dynamic

S.coordinates = dofList;
S.moments = strcat(dofList,'_moment');
% replace 'moment' by 'force' in pelvis_t
S.moments(find(contains(S.moments,'pelvis_tx'))) = strrep(S.moments(find(contains(S.moments,'pelvis_tx'))),'moment','force');
S.moments(find(contains(S.moments,'pelvis_ty'))) = strrep(S.moments(find(contains(S.moments,'pelvis_ty'))),'moment','force');
S.moments(find(contains(S.moments,'pelvis_tz'))) = strrep(S.moments(find(contains(S.moments,'pelvis_tz'))),'moment','force');
