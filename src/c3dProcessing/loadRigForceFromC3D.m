
function  forceData = loadRigForceFromC3D(DirInput,trialNames)
fp = filesep;
forceData =[];
for i = 1:length(trialNames)
    trialName = trialNames{i};
    data = btk_loadc3d([DirInput fp trialName '.c3d']);
    fs = data.analog_data.Info.frequency;
    forceData(:,i) = TimeNorm(GetMaxForce(data.analog_data.Channels.Force_Rig,fs),fs);
end