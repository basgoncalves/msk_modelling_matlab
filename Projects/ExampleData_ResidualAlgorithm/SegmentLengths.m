function L = SegmentLengths(x,y)
xT = x';
yT = y';
diffx = diff(xT);
diffy = diff(yT);
L = sqrt(diffx.^2+diffy.^2);
L = mean(L,2);
L = L';
