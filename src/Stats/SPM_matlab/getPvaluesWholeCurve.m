% spmi = results from spm.inference

function getPvaluesWholeCurve(spmi)

% attempt to calculate p values not working
Zscores = [spmi.z];
coefficient = spmi.zstar / 1.96;
p_values = (coefficient * (1 - normcdf(abs(Zscores))));
p_values = 1 - spm_Tcdf(Zscores, spmi.df(2));

figure; hold on; plot(p_values,'o')
