function length = lineLength (A, B)
% gets the length of the line AB from two points
x = B(1) - A(1);
y = B(2) - A(2);
z = B(3) - A(3);
length = sqrt(x^2 + y^2 + z^2);