function dataOutput = calculateMomentsOnFP(data, FP, force_data_filtered)
%Function to combine two force plate data for the right foot stance based
%on events detected using a FP threshold

% INPUT -   data - structure containing fields from from previously loaded
%               C3D file using btk_loadc3d.m as well as a filename string
%           FP - Structure containing the on and off events for both
%           plates. You can use these to specify the feet/data you want to
%           analyse. Events are created based on a force threshold in
%           the assign_forces_Gerber_method function
%
% OUTPUT -  data - structure containing the combined force plate data

% Define the periods of interest
% Front plate
rightStanceOn1 = FP(1).On(1); rightStanceOn2 = FP(2).On(2);
% Rear plate
rightStanceOff1 = FP(1).Off(1); rightStanceOff2 = FP(2).Off(2);

% Initialise the matrices
Fx1 = zeros(length(data.analog_data.Time), 1); Fy1 = zeros(length(data.analog_data.Time), 1); Fz1 = zeros(length(data.analog_data.Time), 1);
Fx2 = zeros(length(data.analog_data.Time), 1); Fy2 = zeros(length(data.analog_data.Time), 1); Fz2 = zeros(length(data.analog_data.Time), 1);
x1 = zeros(length(data.analog_data.Time), 1); 	x2 = zeros(length(data.analog_data.Time), 1);
y1 = zeros(length(data.analog_data.Time), 1); 	y2 = zeros(length(data.analog_data.Time), 1);
% Mz1 = zeros(length(data.analog_data.Time), 1); 	Mz2 = zeros(length(data.analog_data.Time), 1);

%% FORCE
% Assign the force data to the variables
Fz(rightStanceOn1:rightStanceOff1,1) = force_data_filtered(:,3);
Fx(rightStanceOn1:rightStanceOff1,1) = force_data_filtered(:,1);
Fy(rightStanceOn1:rightStanceOff1,1) = force_data_filtered(:,2);

%% COP
%ML
x = force_data_filtered(:,4);
x2(rightStanceOn2:rightStanceOff2,1) = data.fp_data.GRF_data(2).P(rightStanceOn2:rightStanceOff2,1);
%AP
y1(rightStanceOn1:rightStanceOff1,1) = data.fp_data.GRF_data(1).P(rightStanceOn1:rightStanceOff1,2);
y2(rightStanceOn2:rightStanceOff2,1) = data.fp_data.GRF_data(2).P(rightStanceOn2:rightStanceOff2,2);

% Formula to combine the COP values and convert NaNs to zero
x = (Fz1 .* x1 + Fz2 .* x2)./Fz; x(isnan(x)) = 0;
y = (Fz1 .* y1 + Fz2 .* y2)./Fz; y(isnan(y)) = 0;

%% MOMENT - might not use this due to noise
% Mz1(rightStanceOn1:rightStanceOff1,1) = data.fp_data.GRF_data(1).M(rightStanceOn1:rightStanceOff1,3);
% Mz2(rightStanceOn2:rightStanceOff2,1) = data.fp_data.GRF_data(2).M(rightStanceOn2:rightStanceOff2,3);

% % Formula to combine z-moments from each plate
% Mz = Mz1 + Mz2 + (x1-x) .* Fy1 - (y1-y) .* Fx1 + (x2-x) .* Fy2 - (y2-y) .* Fx2;
% 
% % Or just assign from each plate
% Mz = Mz1 + Mz2;

%% ASSIGN TO STRUCTURE

% FP 1 I have assiged to the right foot whereas FP 2 is left foot.
data.GRF.FP(1).F(:,1) = Fx; data.GRF.FP(1).F(:,2) = Fy; data.GRF.FP(1).F(:,3) = Fz;
data.GRF.FP(1).P(:,1) = x; data.GRF.FP(1).P(:,2) = y;
% data.GRF.FP(1).M(3) = Mz;

dataOutput = data;
end



