function result = gradient2(x,h)
x1 = x(1:end-2);
x2 = x(2:end-1);
x3 = x(3:end);
result = (x1-2*x2+x3)/h^2;
