

%% change EMG mot for participant 060, VL and RF were swapped diring data collection
[Dir,Temp,SubjectInfo,Trials] = getdirFAI(smfai({'060'}));
trialList = Trials.IK;
ax=tight_subplotBG(length(trialList),0);fullsizefig
for t = 1:length(trialList)
    trialDirs = getosimfilesFAI(Dir,trialList{t});
    emg = load_sto_file([trialDirs.emg]);
    % swap data from VL and RF
    RF = emg.VL; 
    VL = emg.RF;
    emg.VL = VL;
    emg.RF = RF;
    % plot data
    axes(ax(t)); hold on; plot(emg.VM); plot(emg.VL); plot(emg.RF);
    title(trialList{t}); 
    mmfn_inspect
    cd(fileparts(trialDirs.emg))
    saveData = struct2array(emg);
    Fields = fields(emg);
    printEMGmot(fileparts(trialDirs.emg),emg.time,saveData(:,2:end),Fields(2:end), '.mot')        
end
legend({'VM','VL','RF'})

cmdmsg('EMG singals from VL and RF were swapped for participant 060. This has been fixed now! You are welcome!')