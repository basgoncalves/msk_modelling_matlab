
%% calibration weight 
WeightVoltageDir = uigetfile('E:\1-PhD\3-FatigueFAI',...
    'Select New calibration weight file','*.c3d');

[ZeroVoltageDir,VoltageDir]= uigetfile('E:\1-PhD\3-FatigueFAI',...
    'Select New calibration zero file','*.c3d');
cd(VoltageDir)

Weightdata = btk_loadc3d(WeightVoltageDir);
ForceData = Weightdata.analog_data.Channels.Force_Rig;
WeightVoltage = mean (ForceData);


Zerodata = btk_loadc3d(ZeroVoltageDir);
ForceData = Zerodata.analog_data.Channels.Force_Rig;
ZeroVoltage = mean (ForceData);


CalibrationFactor_New = 98.106 / (ZeroVoltage+WeightVoltage);

