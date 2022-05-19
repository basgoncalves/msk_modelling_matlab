% RGB_double = [3, 252, 161]

% find RGB colors here - https://www.google.com/search?q=rgb+color+picker&rlz=1C1GCEB_enAU798AU798&oq=RGB+color&aqs=chrome.1.69i57j0l7.4093j0j1&sourceid=chrome&ie=UTF-8

function MatColor = convertRGB (RGB_double)

MatColor = [];
for ii = 1:size(RGB_double,1)
    
MatColor(ii,1:3) = RGB_double(ii,1:3)/255;
end
