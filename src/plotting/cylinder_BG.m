t = 0:0.01:2*pi;
x = sin(t);
figure
plot (t,x)

% angle to rotate(rads)
a = pi/4; 
% rotational matrix
z = [cos(a) -sin(a); sin(a) cos(a)];

% x and y coordinates to multiply with the rotation matrix 
m = [t;x];
% rotate the signal
k = z*m;
t2 = k(1,:);
x2 = k(2,:);
hold on
plot(t2,x2);


[X,Y,Z] = cylinder(5);
surf(X,Y,Z)
hold on
[X,Y,Z] = cylinder(900,100);
surf(X,Y,Z)
r = 2 + cos(Z);
[X,Y,Z] = cylinder(r,100);
surf(X,Y,Z)

figure
t = 0:pi/10:2*pi;
r = 2 + cos(t);
[X,Y,Z] = cylinder(r);
surf(X,Y,Z)
hold on
surf(X,Y,Z*2)
r = 2 + sin(t);
[X,Y,Z] = cylinder(r);
surf(X,Y,Z)
% angle to rotate(rads)
a = pi/2; 
% rotational matrix
z = [cos(a) sin(a) 0; -sin(a) cos(a) 0; 0 0 1];

% x and y coordinates to multiply with the rotation matrix 
m = [X;Y;Z];
% rotate the signal
k = z.*m;
X2 = k(1,:);
Y2 = k(2,:);

hold on
plot(t2,x2);

