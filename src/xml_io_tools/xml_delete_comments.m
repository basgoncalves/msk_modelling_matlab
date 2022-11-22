function tree = xml_delete_comments(xml_path,RootName)

Pref = struct;
Pref.Str2Num = 'never';
Pref.StructItem = false;
Pref.CellItem = false;
tree = xml_read(xml_path,Pref);
tree = rmfield_all_levels(tree,'COMMENT');
xml_write(xml_path,tree,RootName,Pref);


