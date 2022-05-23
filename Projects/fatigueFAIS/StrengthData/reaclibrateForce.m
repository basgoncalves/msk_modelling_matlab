%% reaclibrateForce
% recalibrate data strength FAI

answer = questdlg('Recalibrate Force Data?');
RecalibratedData = cell2mat (StrengthTrials(:,2));
if strcmp(answer,'Yes')
    CalibrateRig
    CalibrationFactor_Old =  str2double(inputdlg('write old calibration Factor' ));
    ForceThreshold = str2double(inputdlg('Select a force threshold to recalibrate data' ));
    RecalibratedData(RecalibratedData>=ForceThreshold)=RecalibratedData(RecalibratedData>=ForceThreshold)./CalibrationFactor_Old.*CalibrationFactor_New;
end
StrengthTrials(:,end+1)=num2cell(RecalibratedData);