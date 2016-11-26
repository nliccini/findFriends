% str2img given a string an a color, produce an image representation of the text
%
%   strImg = str2img(str, color)
%
% Inputs:
%   (char) A string
%   (double) 1x3 vector of an RGB triplet (interger values between 0 and 255)
%
% Outputs:
%   (uint8) An NxMx3 image array of the given text. The text color will be the
%       color specified and the background will be solid black. If any part of the
%       given color is 0, it will be converted to a 1 so that the text can always be
%       distinguished from the background.

function words = str2img(str, color)
load font;
img = [];
color(color == 0) = 1;
for i = str
    img = [img, font{double(i)}];
end
bgMask = ~img;
r = img*color(1);
r(bgMask) = 0;

g = img*color(2);
g(bgMask) = 0;

b = img*color(3);
b(bgMask) = 0;

words = uint8(cat(3, r, g, b));
end