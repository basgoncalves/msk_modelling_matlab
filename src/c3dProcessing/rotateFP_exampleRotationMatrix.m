
syms u v
x = cos(u)*sin(v);
y = sin(u)*sin(v);
z = cos(v)*sin(v);
fsurf(x,y,z)
axis equal

figure
hold on
syms t

Rx = [1 0 0; 0 cos(t) -sin(t); 0 sin(t) cos(t)];
Ry = [cos(t) 0 sin(t); 0 1 0; -sin(t) 0 cos(t)];
Rz = [cos(t) -sin(t) 0; sin(t) cos(t) 0; 0 0 1];

Xrot_rad = 0;
Yrot_rad = 0;
Zrot_rad = pi;


xyzRx = Rx*[x;y;z];
Out_Rx = subs(xyzR, t, Xrot_rad);

xyzRy = Ry*Out_Rx;
Out_Rxy = subs(xyzRy, t, Yrot_rad);

xyzRz = Rz*Out_Rxy;
Out_Rxy = subs(xyzRz, t, Zrot_rad);


fsurf(Out_Rxy(1), Out_Rxy(2), Out_Rxy(3))
xlabel('x axis')
ylabel('y axis')
zlabel('z axis')
title(['Rotating X:' num2str(Xrot_rad) '; Y:' num2str(Yrot_rad) ';Z:' num2str(Zrot_rad) ])
axis equal