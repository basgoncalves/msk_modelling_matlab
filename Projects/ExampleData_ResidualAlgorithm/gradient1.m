function result = gradient1(x,h)
result = (x(3:end,1)-x(1:end-2))/(2*h);
