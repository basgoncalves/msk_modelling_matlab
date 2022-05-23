
CV_table = table;
CV_cell = {};

for i=  1: length (CV_data)
CV_cell{1,i} = CV_data{i,1};
    for d = 1:  length (CV_data{i})-1
        cv = CV_data{i,2}.CV(d);
        lCI= CV_data{i,2}.lCV(d);
        uCI= CV_data{i,2}.uCV(d);
        CV_cell{d+1,i} = sprintf('%.1f (%.f-%.1f)',cv, lCI,uCI);      
    end
    
end
