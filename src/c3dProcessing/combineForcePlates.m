function dataOutput = combineForcePlates(data)
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

%% FORCE
% Assign the force data to the variables
Fx1 = data.fp_data.GRF_data(1).F(:,1);
Fx2 = data.fp_data.GRF_data(2).F(:,1);
Fy1 = data.fp_data.GRF_data(1).F(:,2);
Fy2 = data.fp_data.GRF_data(2).F(:,2);
Fz1 = data.fp_data.GRF_data(1).F(:,3);
Fz2 = data.fp_data.GRF_data(2).F(:,3);
% Combine the force data into one value by summing
Fx = Fx1 + Fx2;
Fy = Fy1 + Fy2;
Fz = Fz1 + Fz2;

%% MOMENTS
Mz1 = data.fp_data.GRF_data(1).M(:,3);
Mz2 = data.fp_data.GRF_data(2).M(:,3);
% Mx1 = data.fp_data.GRF_data(1).M(:,1);
% Mx2 = data.fp_data.GRF_data(2).M(:,1);
% My1 = data.fp_data.GRF_data(1).M(:,2);
% My2 = data.fp_data.GRF_data(2).M(:,2);

% % Formula to combine z-moments from each plate
Mz = Mz1 + Mz2 + (x1-x) .* Fy1 - (y1-y) .* Fx1 + (x2-x) .* Fy2 - (y2-y) .* Fx2;
% 
% % Or just assign from each plate
% Mz2 = Mz1 + Mz2;
       
%% COP
%Progression direction is y-axis
x1 = data.fp_data.GRF_data(1).P(:,1);
x2 = data.fp_data.GRF_data(2).P(:,1);
%AP
y1 = data.fp_data.GRF_data(1).P(:,2);
y2 = data.fp_data.GRF_data(2).P(:,2);


% Formula to combine the COP values and convert NaNs to zero
x = (Fz1 .* x1 + Fz2 .* x2)./Fz; x(isnan(x)) = 0;
y = (Fz1 .* y1 + Fz2 .* y2)./Fz; y(isnan(y)) = 0;

%% ASSIGN TO STRUCTURE

% FP 1 I have assiged to the right foot whereas FP 2 is left foot.
data.GRF.FP(1).F(:,1) = Fx; data.GRF.FP(1).F(:,2) = Fy; data.GRF.FP(1).F(:,3) = Fz;
data.GRF.FP(1).P(:,1) = x; data.GRF.FP(1).P(:,2) = y;
data.GRF.FP(1).M(:,3) = Mz;

dataOutput = data;
end

