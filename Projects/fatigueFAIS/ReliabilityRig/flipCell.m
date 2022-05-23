%flip cell vertically
function  var2 = flipCell (var)
var2 = var;
[y,x] = size (var);
count = y; %number of the last row
Row=y;
for r = 1:y  %number of rows

    for c = 1:x
    var2 {count+1,c}= var{Row,c}
    end
    Row = Row -1;
    count = count+1;
    
end

var2(1:y)=[];