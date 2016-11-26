function [montage] = ca2img(imgs, numinrow)
%ca2img given a cell array and number of images per row, make a montage
%   Inputs:
%   (cell) 'imgs': A cell array of either all file names or all uint8's
%   (double) 'numinrow': The number of faces you wish to have in each row
%   of the montage
%
%   Outputs:
%   (uint8) 'montage': An image array of the created montage
%
%   Output Image Files:
%   (.png) An image file of all the images specified in the inputs
%
% NOTE: Please make sure that you have enough photos to fill each row!

% Input a cell array of image filenames
    % Initialize variables
    numImgs = length(imgs);
    montage = [];
    montage1 = [];
    numimg = 0;
    ndx = 1;
    while ndx <= numImgs
        for n=ndx:ndx+numinrow-1
            % If ca has img names then it can easily handle that
            if ischar(imgs{n})
                img = imread(imgs{n});
            end
            % If ca has uint8's then just goes right on ahead
            img = editImg(img);
            montage1 = [montage1, img];
            numimg = numimg + 1;
            ndx = ndx + 1;
            % Determines what number of images can be in each row
            if mod(numimg, numinrow) == 0 && numimg ~= 0
                montage = [montage; montage1];
                numimg = 0;
                montage1 = [];
            end
        end
    end
    % Write the output image to the new file 'montage.png'
    imwrite(montage, 'montage.png');
end

% Helper function to edit image and make the gallery faces all grayscaled squares
function [gry] = editImg(img)
    img = imresize(img, [400, 400]);
    gry = double(img);
    gry = uint8((gry(:,:,1) + gry(:,:,2) + gry(:,:,3)) ./ 3);
    gry = cat(3, gry, gry, gry);
end