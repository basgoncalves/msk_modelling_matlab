% Example :
%   states_sto_file = 'C:\Users\Bas\Downloads\Luis_Cunha\IAA\_states.sto';
%   controls_xml_file = 'C:\Users\Bas\Downloads\Luis_Cunha\IAA\_controls.xml';
%   downsample_states_cmc(states_sto_file,controls_xml_file)

function downsample_states_cmc(states_sto_file,controls_xml_file)


states = importdata(states_sto_file);
controls_xml = xml_read(controls_xml_file);

fs = 1/(states.data(2,1) - states.data(1,1));
fs_xml = 1/(controls_xml.ControlSet.objects.ControlLinear(1).x_nodes.ControlLinearNode(2).t-controls_xml.ControlSet.objects.ControlLinear(1).x_nodes.ControlLinearNode(1).t);

down_rate = int16(fs/fs_xml);

states_ds = struct;
states_ds.data = downsample(states.data,down_rate);
states_ds.textdata = states.textdata;
states_ds.colheaders = states.colheaders;
states_ds.colheaders = strrep(states_ds.colheaders ,'/','_');

states_ds_cell = states_ds.textdata;
[nrows,ncols] = size(states_ds.data);
states_ds_cell(end+1:end+nrows,1:ncols) = num2cell(states_ds.data);

new_sto_file = strrep(states_sto_file,'.sto','_ds.sto');
xlswrite(new_sto_file,states_ds_cell);
