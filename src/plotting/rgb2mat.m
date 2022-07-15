% rgb2mat = [3, 252, 161]
% find RGB colors:  https://imagecolorpicker.com/en

function MatColor = rgb2mat (RGB_double)

MatColor = [];
for ii = 1:size(RGB_double,1)
    
MatColor(ii,1:3) = RGB_double(ii,1:3)/255;
end
