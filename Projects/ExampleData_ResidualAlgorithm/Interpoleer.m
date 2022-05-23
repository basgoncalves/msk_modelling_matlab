function VqOut = Interpoleer(Vd)
% Vq: interpolated values
% Vd: possibly dirty values
VqOut = zeros(size(Vd));
for i = 1:size(Vd,2)
% collumn of dirty values:
  Vc = Vd(:,i);
% find indexes of dirty values  
  ind = find(~isnan(Vc));
% check if there are dirty values, if so interpolate  
  if (size(ind,1) ~= size(Vc,1))
% clean values:
    V = Vc(ind);
% time series at all values:
    Xq = 1:1:size(Vc,1);
    Xq = Xq';
% time series, instants with dirty values removed:    
    X = Xq(ind);
% values at all instants:
    Vq = interp1(X,V,Xq,'pchip','extrap');
    VqOut(:,i) = Vq;
% no interpolation performed for this one:  
  else
    VqOut(:,i) = Vd(:,i);
  end 
end