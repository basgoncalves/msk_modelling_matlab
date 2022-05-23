function phi = Points2Angles(x,y)
xx = x';
yy = y';
dxx = diff(xx);
dyy = diff(yy);
phi = unwrap(atan2(dyy',dxx'));
for j = 1:size(phi,2)
  if mean(phi(:,j),1) < 0
    phi(:,j) = phi(:,j)+2*pi;
  end  
end  
