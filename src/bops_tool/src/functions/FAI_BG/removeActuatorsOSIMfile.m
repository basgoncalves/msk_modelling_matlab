
function  removeActuatorsOSIMfile(model_file)

fp = filesep;

%load file 

M = importdata(model_file);

 prefXmlWrite.StructItem = false;  % allow arrays of structs to use 'item' notation
 prefXmlWrite.CellItem   = false;
 xml_write(model_file, M, 'OpenSimDocument', prefXmlWrite);