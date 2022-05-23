function list = listadd 

cond = {'sit_abd';'sup_abd';'sit_add';'sup_add'}; 
varNames = {'Fmax';'RFD_max';'RFD_50';'RFD_100';'RFD_150';'RFD_200'};
list ={};
count=1;
for c = 1: length (cond)
   
    for v = 1: length (varNames)
       text= sprintf ('%s_%s', cond{c}, varNames {v});
       list{count,1}=text;
       count=count+1;
    end
    
end
