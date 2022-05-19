
function setupIKTool_BOPS(IK_setup_filepath,elaboration_filepath)

IK   = xml_read(IK_setup_filepath);
elab = xml_read(elaboration_filepath);

markerset       = split(elab.Markers,' ');
IKMarkerTask    = IK.InverseKinematicsTool.IKTaskSet.objects.IKMarkerTask;
markersIK       = {};

for i = 1:length(IKMarkerTask)
    markersIK{i} = IKMarkerTask(i).ATTRIBUTE.name;
end

unassignedMarkers = markersIK(~contains(markerset,markersIK));
if isempty(unassignedMarkers)
    m = questdlg('markers in setup file correc! Do you want to change the weighting?');
    createNewWeights = m;
else
    msg = ['these markers are not present in the current IK setup:'];
    for i = 1:length(unassignedMarkers)
        msg = [msg sprintf('\n %s',unassignedMarkers{i})];
    end
    m = msgbox(msg);
    uiwait(m)
    createNewWeights = 'Yes';
    
end

if isequal(createNewWeights,'Yes')
    n = 10;
    sections         = [1:n:length(markerset) length(markerset)];
    IKMarkerTask_new =  struct;
    defaultWeights   = {};
    % find if the names of current;y present markers already exist and
    % assign defaultmarker weights 
    
    for i = 1: length(markerset) 
        for ii = 1:length(IKMarkerTask)
            if contains(IKMarkerTask(ii).ATTRIBUTE.name,markerset{i})
                defaultWeights{i} = num2str(IKMarkerTask(ii).weight);
                break
            else
                defaultWeights{i} = '1';
            end
        end    
    end
    
    for i = 1:length(sections)-1
        
        idx = sections(i):sections(i+1);
        prompt = markerset(idx);
        dlgtitle = 'Define weightigs for each marker';
        dims = [1 50];
        opts.WindowStyle = 'normal';
        opts.Resize = 'on';
        weights = inputdlg(prompt,dlgtitle,dims,defaultWeights(idx)',opts);
        
        for k = 1:length(idx)
            xml_idx = idx(k);
            IKMarkerTask_new(xml_idx).ATTRIBUTE.name =  prompt{k};
            IKMarkerTask_new(xml_idx).weight = weights{k};
            IKMarkerTask_new(xml_idx).apply = 'true';
        end
        
    end
    IK.InverseKinematicsTool.IKTaskSet.objects.IKMarkerTask = IKMarkerTask_new;
    
    root = 'OpenSimDocument';
    Pref.StructItem = false;
    xml_write(IK_setup_filepath, IK, root,Pref);
end