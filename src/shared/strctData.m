

function A = strctData (Stru,Fld)

names = fields(Stru);
idx = contains(names,Fld);
A = Stru.(names{idx});