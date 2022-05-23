function [dataFinal, force_data2] = assignForceOutputTrcMot(data, fileName, progDir, legName)
%Assign forces to a each foot and use this data to create .trc and .mot
%files for OpenSim
%   % Assign force to the feet and generate the .trc and .mot files. Data
%   must be a file generated from the function btk_loadc3d

% Combine force measures from both plates
dataForcesAssigned3 = assign_forces_Gerber_method(data,[20, 0.2], progDir);

% Create the .trc and .mot files

if dataForcesAssigned3.GRF.FP(1).F(200,3) ~= 0
	[dataFinal, force_data2] = btk_c3d2trc_treadmill_LS_new(dataForcesAssigned3,'off', progDir, legName);
	
else
	fprintf('Trial %s has dodgy FP data, not writing it for further processing', fileName);
	dataFinal = dataForcesAssigned3;
	force_data2 = [];
end

end

