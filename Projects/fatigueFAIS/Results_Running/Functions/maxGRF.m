% get max GRF 
%
%   DirC3D = directory of the c3d files 
%   Trials = names of the trials to extract GRF from 
%   
function [output, Labels] = maxGRF (DirC3D,Trials)

cd(DirC3D);

if ~exist('Trials')
    
    folderC3D = sprintf('%s\\%s',DirC3D,'*.c3d');
    Variables = dir(folderC3D);
    Variables = {Variables.name};

    % select only one Joint
    [idx,~] = listdlg('PromptString',{'Choose the joint to plot'},'ListString',Variables);
    Trials = Variables (idx);

end

output = [];
Labels = {};
% 
for ii = 1:length(Trials)
    data = btk_loadc3d([DirC3D filesep Trials{ii}]);
    GRF = combineForcePlates_multiple(data);
    GRF = GRF.GRF.FP.F;
    
    if ~isempty(fields(data.Events.Events))
      FirstFrame = size(GRF,1);
      LastFrame = 1;
      fn = fieldnames(data.Events.Events);
      
      for ff = 1:numel(fn)
            FirstFrame = min([FirstFrame data.Events.Events.(fn{ff})]);
            LastFrame = max([LastFrame data.Events.Events.(fn{ff})]);
      end
      Ratio = (data.fp_data.Info(1).frequency / data.marker_data.Info(1).frequency);
      offset = data.marker_data.First_Frame*Ratio;
      FirstFrame = FirstFrame * data.fp_data.Info(1).frequency - offset+Ratio;
      LastFrame = LastFrame * data.fp_data.Info(1).frequency - offset+Ratio;
    else
         FirstFrame = 1;
         LastFrame = size(GRF,1);
    end
    
    output(end+1,1:3) = max(GRF(FirstFrame:LastFrame,:));
    Labels{end+1,1} = erase(Trials{ii},'.c3d')
    
end