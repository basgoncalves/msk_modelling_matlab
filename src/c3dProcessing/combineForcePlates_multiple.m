function dataOutput = combineForcePlates_multiple(data)
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
[NForcePlates,~]=size(data.fp_data.GRF_data);
for ii= 1: NForcePlates
Rows = length(data.fp_data.GRF_data(ii).F(:,1));
Fx(1:Rows,ii) = data.fp_data.GRF_data(ii).F(:,1);

Fy(1:Rows,ii) = data.fp_data.GRF_data(ii).F(:,2);

Fz(1:Rows,ii) = data.fp_data.GRF_data(ii).F(:,3);

end
% Combine the force data into one value by summing
FxSum = sum(Fx,2);
FySum = sum(Fy,2);
FzSum = sum(Fz,2);

%% MOMENTS
% loop through all forceplates
for ii= 1: NForcePlates
Rows = length(data.fp_data.GRF_data(ii).M(:,3));
Mz(1:Rows,ii) = data.fp_data.GRF_data(ii).M(:,3);
% Mx(1:Rows,ii) = data.fp_data.GRF_data(ii).M(:,1);
% My(1:Rows,ii) = data.fp_data.GRF_data(ii).M(:,2);
end

%% COP
%Progression direction is y-axis -> loop through all forceplates
for ii= 1: NForcePlates
Rows = length(data.fp_data.GRF_data(ii).P(:,1));

x(1:Rows,ii) = data.fp_data.GRF_data(ii).P(:,1);
%AP
y(1:Rows,ii) = data.fp_data.GRF_data(ii).P(:,2);
end

xSum = (Fz(1:Rows,1) .* x(1:Rows,1));
ySum = (Fz(1:Rows,1) .* y(1:Rows,1));
% Formula to combine the COP values and convert NaNs to zero
for ii= 2: NForcePlates
Rows = length(data.fp_data.GRF_data(ii).P(:,1));
xSum = xSum + Fz(1:Rows,ii) .* x(1:Rows,ii);

ySum = (Fz(1:Rows,ii) .* y(1:Rows,ii));
end
xSum = xSum./FzSum; xSum(isnan(xSum)) = 0;
ySum = ySum./FzSum; ySum(isnan(ySum)) = 0;

%% Formula to combine z-moments from each plate
MzSum = Mz(1:Rows,1);
for ii= 2: length (fields (data.fp_data.GRF_data))
MzSum = MzSum +Mz(1:Rows,ii)+(x(1:Rows,ii)-xSum).*Fy(1:Rows,ii)-(y(1:Rows,ii)-ySum).* Fx(1:Rows,ii);
end

% % Or just assign from each plate
% Mz2 = Mz1 + Mz2;
       
%% ASSIGN TO STRUCTURE

% FP 1 I have assiged to the right foot whereas FP 2 is left foot.
data.GRF.FP(1).F(:,1) = FxSum; data.GRF.FP(1).F(:,2) = FySum; data.GRF.FP(1).F(:,3) = FzSum;
data.GRF.FP(1).P(:,1) = xSum; data.GRF.FP(1).P(:,2) = ySum;
data.GRF.FP(1).M(:,3) = MzSum;
data.fp_data.GRF_data = data.GRF.FP;

dataOutput = data;
end

