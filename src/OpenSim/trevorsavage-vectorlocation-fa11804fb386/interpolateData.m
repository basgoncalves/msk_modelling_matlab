function yi = interpolateData(In,freqi,frames)

long = size(In,2);

X = 0:1/freqi:((long-1)/freqi);
% Xi=0:1:100;
Xi = X(1):(X(end)/frames):X(end);

for i = 1:size(long,1)
    yi(i,:) = interp1(X(i,:),In(i,:),Xi(i,:),'pchip');
end