
function [EMGsignalName,EMGverified] = FindMeasuredEMGforOsimMuscle_FAI(Dir,trialName,MuscleName)

fp = filesep;

if exist([Dir.Input fp 'BadTrials.mat'])
    EMGverified = 1;
else
    EMGverified = 0;
    disp(' ')
    disp(' ')
    cmdmsg(['BadTrials.mat does not exist, plese check EMG signals'])
end

if contains(MuscleName,{'addbrev_','addlong_','addmagDist_','addmagIsch_','addmagMid_','addmagProx_'})
    EMGsignalName = 'ADDLONG';
elseif contains(MuscleName,{'bflh_','bfsh_' })
    EMGsignalName = 'BFLH';
elseif contains(MuscleName,{'semimem_','semiten_'})
    EMGsignalName = 'SEMIMEM';
elseif contains(MuscleName,{'vasmed_'})
    EMGsignalName = 'VM';
elseif contains(MuscleName,{'vaslat_'})
    EMGsignalName = 'VL';
elseif contains(MuscleName,{'recfem_'})
    EMGsignalName = 'RF';
elseif contains(MuscleName,{'grac_'})
    EMGsignalName = 'GRA';
elseif contains(MuscleName,{'gasmed_'})
    EMGsignalName = 'GM';
elseif contains(MuscleName,{'gaslat_'})
    EMGsignalName = 'GL';
elseif contains(MuscleName,{'tfl_'})
    EMGsignalName = 'TFL';
elseif contains(MuscleName,{'glmax1_r','glmax2_r','glmax3_r'})
    EMGsignalName = 'GLUMAX';
else
    EMGsignalName = [];
    return
end

if EMGverified == 1
    EMGcheck = load([Dir.Input fp 'BadTrials.mat']);
    col = find(contains(EMGcheck.trialNames,trialName));
    row =  find(strcmp(strtrim(EMGcheck.allMuscles),EMGsignalName));
    
    if EMGcheck.BadTrials{row,col}>0
        disp([EMGsignalName ' not used'])
        EMGsignalName = [];
    end
end
