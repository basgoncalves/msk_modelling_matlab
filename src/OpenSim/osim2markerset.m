% osim_model_path = 'C:\Users\Biomech\Documents\1-UVienna\Tibial_Tosion2022\BasSimulations\ElaboratedData\GenericModel\Ref_scaled_opt_N10_2times2392Fmax.osim'


function osim2markerset(osim_model_path)

disp('loading model ...')
model2 = xml_read(osim_model_path);
disp('model loaded!')


makerset_filename = [fileparts(osim_model_path) fp 'MarkerSet.xml'];
markerset = model2.Model.MarkerSet;
Pref.StructItem = 0;
Pref.CellItem   = 0;

for i = 1:length(markerset.objects.Marker)
    markerset.objects.Marker(i).COMMENT = [];
end

disp('saving MarkerSet...')
xml_write(makerset_filename,markerset,'OpenSimDocument',Pref);
disp('MarkerSet saved!')