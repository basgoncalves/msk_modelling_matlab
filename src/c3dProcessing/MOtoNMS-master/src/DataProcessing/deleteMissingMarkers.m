

function MarkersList = deleteMissingMarkers(DirC3D,trialName,MarkersList) 

fp = filesep;

TrialData = btk_loadc3d([DirC3D fp trialName '.c3d']);

% get marker info from trials
MarkersLabels={};
MarkersLabels{1}= fields(TrialData.marker_data.Markers);
if isempty(MarkersLabels{1})
    disp(' ')
    disp(['Trial ' trialName ' does not contain any markers'])
    return
end
missingMarkers=0;
% MarkerPerTrial.(trialName)= TrialData.marker_data.Markers;

for m = flip(1: length(MarkersList))            % delete unused markers loop through marker list TRC
    marker = MarkersList{m};
    for t = 1 : length (MarkersLabels)          % loop through trials
        if isempty(find(strcmp(marker, MarkersLabels{t}), 1))
            MarkersList(m)=[];
            missingMarkers = missingMarkers+1;
            break
        end
    end
end
