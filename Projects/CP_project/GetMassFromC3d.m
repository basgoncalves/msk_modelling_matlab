
function Mass = GetMassFromC3d


fp = filesep;
[dirc3d,path] = uigetfile ('*.c3d','select c3d file');                                                                                          % directory elaborated data
cd(path)

data = btk_loadc3d([path fp dirc3d]);

Fz      = [];
Nplates = length(data.fp_data.GRF_data);

for i = 1:Nplates
    Fz(:,i) = data.fp_data.GRF_data(i).F(:,3);
end

Fz_sum = sum(Fz,2); % sum all the platform forces

Weight = mean(Fz_sum,1);  % mean of the forces over time (over rows)

Mass = Weight/9.81;

