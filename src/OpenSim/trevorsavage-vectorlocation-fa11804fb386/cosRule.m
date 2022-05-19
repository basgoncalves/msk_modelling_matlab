function angle = cosRule(a, b, c, out)
% returns the angle C
% out determines if output is in degrees or radians

d = (a^2 + b^2 - c^2)/ (2 * a * b);
angle = acos(d);
if out == 1
    angle = rad2deg(angle);
end
end