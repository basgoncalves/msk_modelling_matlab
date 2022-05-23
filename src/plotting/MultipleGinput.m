function Area =  MultipleGinput (N)

f = msgbox('Select multiple areas. Double-click on the left side of the plot once done.');
uiwait(f)
SelectArea = 1;
Area={};
count =1;
while SelectArea == 1
        [x,y] = ginput(N);
        if x(1)<0
            SelectArea=0;
        else
        Area{count} = [x y];
        count = count +1;
        end
end

disp('Column 1 = x; Column 2 = y')