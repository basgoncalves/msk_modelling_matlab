

function addIAAFootMarkers (ModelDir)

fp = filesep;

fprintf('loading model %s ... \n',ModelDir)
m = xml_read(ModelDir);

% right foot
nMarkers = length(m.Model.MarkerSet.objects.Marker);
locations = {[0.01,0,-0.05];...
    [0,0,0.03];...
    [0.135,0,0.07];...
    [0.205,0,-0.05];...
    [0.275,0,0.02]};
markerNames = {'r_fp_heel1' 'r_fp_heel2' 'r_fp_mt1' 'r_fp_mt2' 'r_fp_toe'};

COM =  m.Model.MarkerSet.objects.Marker(nMarkers).COMMENT;

for k = 1:5
    m.Model.MarkerSet.objects.Marker(nMarkers+k).COMMENT = COM;
    m.Model.MarkerSet.objects.Marker(nMarkers+k).body = 'calcn_r';
    m.Model.MarkerSet.objects.Marker(nMarkers+k).location = locations{k};
    m.Model.MarkerSet.objects.Marker(nMarkers+k).fixed = logical (1);
    m.Model.MarkerSet.objects.Marker(nMarkers+k).ATTRIBUTE = struct;
    m.Model.MarkerSet.objects.Marker(nMarkers+k).ATTRIBUTE.name = markerNames{k};
end

% left foot
nMarkers = length(m.Model.MarkerSet.objects.Marker);
locations = {[0.01,0,0.05];...
    [0,0,-0.03];...
    [0.135,0,-0.07];...
    [0.205,0,0.05];...
    [0.275,0,-0.02]};
markerNames = {'l_fp_heel1' 'l_fp_heel2' 'l_fp_mt1' 'l_fp_mt2' 'l_fp_toe'};

COM =  m.Model.MarkerSet.objects.Marker(nMarkers).COMMENT;

for k = 1:5
    m.Model.MarkerSet.objects.Marker(nMarkers+k).COMMENT = COM;
    m.Model.MarkerSet.objects.Marker(nMarkers+k).body = 'calcn_l';
    m.Model.MarkerSet.objects.Marker(nMarkers+k).location = locations{k};
    m.Model.MarkerSet.objects.Marker(nMarkers+k).fixed = logical (1);
    m.Model.MarkerSet.objects.Marker(nMarkers+k).ATTRIBUTE = struct;
    m.Model.MarkerSet.objects.Marker(nMarkers+k).ATTRIBUTE.name = markerNames{k};
end

% save osim model
Pref.StructItem = false;
root = 'OpenSimDocument'; % setting for saving XML files
xml_write(ModelDir, m, root,Pref);