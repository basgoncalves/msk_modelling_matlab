% osim_model_path = 'C:\Users\Biomech\Documents\1-UVienna\Tibial_Tosion2022\BasSimulations\ElaboratedData\GenericModel\Ref_scaled_opt_N10_2times2392Fmax.osim'


function osim2markerset(osim_model_path)

disp('loading model ...')
model = xml_read(osim_model_path);      % load model 

model2 = xml_read('C:\Code\Git\MSKmodelling\src\TorsionTool-Veerkamp2021\MarkerSet.xml')

disp('model loaded!')

makerset_path = fileparts(osim_model_path);
makerset_filename = [makerset_path '.' fp 'MarkerSet.xml'];

MarkerSet = model.Model.MarkerSet;
Pref.StructItem = 0;
Pref.CellItem   = 0;

for i = 1:length(MarkerSet.objects.Marker)
    MarkerSet.objects.Marker(i).COMMENT = [];
end

markerset_tree = struct;
markerset_tree.ATTRIBUTE.name = model.Model.ATTRIBUTE.name;
markerset_tree.MarkerSet        = MarkerSet;

disp('saving MarkerSet...')
xml_write(makerset_filename,markerset_tree,'OpenSimDocument',Pref);
disp('MarkerSet saved!')