function printMuscleContributionSTOmusc1F(dirSO, musc_name,ActuatorsTime,ActuatorsDataNew,ActuatorsLabels, ext)

labels = ['time', ActuatorsLabels];
values_array = [ActuatorsTime, ActuatorsDataNew];
values_cell = {};
for i = 1:size(values_array,2)
    values_cell{i} = values_array(:,i);
end
data = cell2struct(values_cell,labels,2);
write_sto_file(data, [dirSO fp musc_name ext])