function tree = xml_delete_comments(xml_path)

tree = xml_read(xml_path);
tree = rmfield_all_levels(tree,'COMMENT');
Pref = struct;
Pref.StructItem = false;
Pref.CellItem = false;
xml_write(xml_path,tree,'OpenSimDocument',Pref);