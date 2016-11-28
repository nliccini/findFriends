function [outstr] = findFriends(montage)
%findFriends given the filename or uint8 of a montage determine who is in it
%   Inputs:
%   (char or uint8) 'montage': A filename or image of multiple faces
%
% Outputs:
%   (char) 'outstr': A string describing how many people were in the image and who
%   they were in order starting from the top left and ending in the bottom
%   right.
%
% Output Image Files:
%   (uint8) An updated version of the input photo with the names of each
%   person displayed at the bottom
%   (uint8) The first stored image of the specified person
%
% NOTE: Please have at least 3 different images of each person in the same
% folder to include in the database when creating a new one
%
% NOTE: This machine learning algorithm is reported to have only a 91%
% acurracy rating, so if a group of 9-12 images are analyzed, expect 1-3 to
% be incorrect

%% Output FileName Creation
if ischar(montage)
    [filename, extension] = strtok(montage, '.');
    updated = [filename, '_updated' extension];
else
    updated = 'montage_updated.png';
end

%% Database Creation
% Ask user to create a new image database (structure array) or import a
% faces.mat file that already contains a single structure array with all the
% correct fields. Can save created databases
% NOTE: Upload just head photos, they can be any size or coloring, it will 
% be corrected by the function
% NOTE: Please name the importing file by the name of the struct inside it
% (e.g.) faces.mat contains only faces (struct)
    [faces, imported] = makeData('Do you want to create a new database element? [yes/import/no]\n');
    if ~isempty(imported)
        faces = imported;
    end
    
    % Save the new custom database
    if isempty(imported)
        reply = input('Save this database? [name.mat/no]\n', 's');
        if strcmpi(reply, 'no') || strcmpi(reply, 'n') || strcmpi(reply, 'on')
            % Continue without saving
        else
            filename = reply;
            save(filename, 'faces');
        end
    end
  
%% Image Directory Creation
% Write those images from the database to a new directory for creating the
% Image Set
    dir = 'Friend Images';
    mkdir(dir);
    for ndx=1:length(faces)
        % Create the name of the folder as the name of the person
        folderName = faces(ndx).Name;
        % Make the name directory within the main directory
        mkdir(dir, folderName);
        % Get the first image's filename
        img1Name = faces(ndx).Image1Name;
        % Create the filepath for that image
        filepath = [fullfile(dir, folderName), '/', img1Name]; 
        % Write the new image to the specified location in its directory
        imwrite(faces(ndx).Image1, filepath);
        % Repeat for Image 2
        img2Name = faces(ndx).Image2Name;
        filepath = [fullfile(dir, folderName), '/', img2Name]; 
        imwrite(faces(ndx).Image2, filepath);
        % Repeat for Image 3
        img3Name = faces(ndx).Image3Name;
        filepath = [fullfile(dir, folderName), '/', img3Name]; 
        imwrite(faces(ndx).Image3, filepath);
        % Repeat for Image 4
        img4Name = faces(ndx).Image4Name;
        filepath = [fullfile(dir, folderName), '/', img4Name]; 
        imwrite(faces(ndx).Image4, filepath);
        % Repeat for Image 5
        img5Name = faces(ndx).Image5Name;
        filepath = [fullfile(dir, folderName), '/', img5Name]; 
        imwrite(faces(ndx).Image5, filepath);
    end
    
%% Image Extraction and Creation of Image Set
% Extract images from the 'Friend Images' directory and store in an image set
    imgset = imageSet(dir, 'recursive');
    
%% HOG Feature Extraction
% Extract HOG (Histogram of Oriented Gradients) feature for one person:
% Use this test code to visualize what the HOG features are:
    %[hogfeature, visualization] = extractHOGFeatures(read(imgset(1),1));
    %figure;
    %plot(visualization);
    
% Extract HOG Features for each person and store in 'features'
% Extract names of each face and store in 'labels'
    numFeatures = 1;
    for ndx=1:size(imgset,2)
        for j=1:imgset(ndx).Count
            % Create an array of all the HOG Features
            features(numFeatures,:) = extractHOGFeatures(read(imgset(ndx),j));
            % Create a cell array of all the names in relation to the same
            % indices in 'features'
            labels{numFeatures} = imgset(ndx).Description;
            numFeatures = numFeatures + 1;
        end
    end
    
%% Create Model for Classifying Faces
% Create classifier (the naming model) using fitcecoc
% model = fit[c/l][model](features, labels)
    faceClassifier = fitcecoc(features, labels);
    
%% Extract Query Image
% NOTE: Make sure that you have already created your montage photo
    % Find query features by extracting the next face square in the montage
    if ischar(montage)
        montage = imread(montage);
    end
    [rows, cols, ~] = size(montage);
    [increment, ~, ~] = size(read(imgset(1),1));
    incrementr = increment;
    incrementc = increment;
    m=1;
    n=1;
    names = [];
    imgs = [];
    num = 0;
    numrows = 0;
    while m < rows
        while n < cols
            % Get the face in question 
            queryImg = montage(m:incrementr,n:incrementc,:);
            % Store this image for later use in creating the output image
            imgs = [imgs, {queryImg}];
            %imshow(queryImg);  
            % Get the HOG Features for the face in question
            queryFeatures = extractHOGFeatures(queryImg);
            % Determine who's face is in the image
            label = predict(faceClassifier, queryFeatures);
            % Save that name to a cell array for use later
            names = [names, label];
            % Update the increment within this row
            n = incrementc+1;
            incrementc = n+increment-1;
            % 'num' will be used later to create the final output img
            num = num + 1;
        end
        % Update the row increment and reset the col increments
        n = 1;
        incrementc = increment;
        m = incrementr+1;
        incrementr = m+increment-1;
        numrows = numrows + 1;
    end
    
%% Create Output String
    numfaces = length(names);
    people = [];
    for ndx=1:numfaces
        person = names{ndx};
        people = [people, person, ', '];
    end
    people(end-1:end) = [];
    outstr = sprintf('There are %d faces in this photo: %s.', numfaces, people);

%% Create Output Image
    friends = [];
    [~, cols, l] = size(imgs{1});
    if l == 1
        % Skip the tagging, we cannot manipulate 1 dimensional images
        for ndx=1:numfaces
            friend = imgs{ndx};
            friends = [friends, {friend}];
        end
    else
        % clrs is pure white
        clrs = [255 255 255];
        for ndx=1:numfaces
            % Extract image
            friend = imgs{ndx};
            % Convert that face's name to a text image
            nameimg = str2img(names{ndx}, clrs);
            % Create scale vector
            [trows, tcols, ~] = size(nameimg);
            scale = cols ./ tcols;
            scale = [round(trows.*scale), tcols.*scale];
            % Resize the text image
            nameimg = imresize(nameimg, scale, 'nearest');
            [trows, ~, ~] = size(nameimg);
            % Use iteration to insert the text image to the bottom of the face
            % NOTE: When using .pgm files, you need to comment out lines 191-197
            % (the for loop). This means that unfortunately the montage will not
            % be labelled, but the output string will still be correct.
            for clr=1:3
                layer1 = friend((end-trows)+1:end,:,clr);
                layer2 = nameimg(:,:,clr);
                mask = layer2 == clrs(clr);
                layer1(mask) = layer2(mask);
                friend((end-trows)+1:end,:,clr) = layer1;
            end
            % Store each image as a new element in a cell array
            friends = [friends, {friend}];
        end
    end
    % Compute how many images were in each row of the montage
    numinrow = num ./ numrows;
    % Create a montage image from the cell array
    friends = ca2img(friends, numinrow);
    % Write the new image and show it to the user immediately
    imwrite(friends, updated);
    figure;
    imshow(friends)
    
%% Determine if User Wants a Specific Face
    reply = input('Want to see anyone in particular? [name/no]\n', 's');
    mask = strcmpi({faces.Name}, reply);
    if any(mask)
        % If there's a match, get the first instance of that person and get
        % the first image of them from the database
        mask = find(mask);
        mask = mask(1);
        figure;
        imshow(faces(mask).Image1);
    elseif strcmpi(reply, 'no')
        % Do nothing
    else
        % Just skip this if they don't type a real name
    end
end

%% Notes:     
    % SUMMARY OF THE FACE RECOGNITION ALGORITHM: %
% ----------------------------------------------------%
% 1. Create Image Set
% 2. Extract HOG Features for each photo in the image set and store name of person
% 3. Create classifier model using fitcecoc
% 4. Extract HOG Features for the photo in question
% 5. Predict the name of the face using prediction with the model
% 
    % ACTUAL FUNCTIONS AND COMMANDS SIMPLIFIED: %
% ----------------------------------------------------%
% 1. imgset = imageSet(imgFolder, 'recursive');
% 2. HOGfeatures = extractHOGFeatures(show(imgset(n),j)); label = imgset(n).Description;
% 3. model = fitcecoc(features, labels);
% 4. ** This part is relative, my method is to take out squares in the montage I made **
% 5. name = predict(model, queryfeatures);

% Function to create database from user or import one they have already
function [data, imported] = makeData(question)
    reply = input(question, 's');
    reply = lower(reply);
    imported = [];
    data = [];
    switch reply
        case {'yes','y','yse','esy','eys'}
            name = input('Name:\n', 's');
            data.Name = name;
            img1 = input('Image 1:\n', 's');
            % Store image filename
            data.Image1Name = img1;
            % Open image and store edited uint8 array
            img1 = imread(img1);
            img1 = editImg(img1);
            data.Image1 = img1;
            % Repeat for image 2
            img2 = input('Image 2:\n', 's');
            data.Image2Name = img2;
            img2 = imread(img2);
            img2 = editImg(img2);
            data.Image2 = img2;
            % Repeat for image 3
            img3 = input('Image 3:\n', 's');
            data.Image3Name = img3;
            img3 = imread(img3);
            img3 = editImg(img3);
            data.Image3 = img3;
            % Repeat for image 4
            img4 = input('Image 4:\n', 's');
            data.Image4Name = img4;
            img4 = imread(img4);
            img4 = editImg(img4);
            data.Image4 = img4;
            % Repeat for image 5
            img5 = input('Image 5:\n', 's');
            data.Image5Name = img5;
            img5 = imread(img5);
            img5 = editImg(img5);
            data.Image5 = img5;
            % Recursively gather new inputs until user specifies to stop
            newData = makeData(question);
            data = [data, newData];           
        case {'import'}
            % If they are using an existing database, enter the name.mat
            import = input('Please type the file.mat you wish to import:\n','s');
            strct = strtok(import, '.');
            sa = load(import);
            if ~strcmp(strct, 'faces')
                imported = sa.faces;
            else
                imported = sa.(strct);
            end
            for n=1:length(imported)
                imported(n).Image1 = editImg(imported(n).Image1);
                imported(n).Image2 = editImg(imported(n).Image2);
                imported(n).Image3 = editImg(imported(n).Image3);
                imported(n).Image4 = editImg(imported(n).Image4);
                imported(n).Image5 = editImg(imported(n).Image5);
            end
        case {'no','n','on'}
            % If they are done entering, add an empty struct so nothing is
            % affected
            data = struct('Name', {}, 'Image1', {}, 'Image1Name', {}, 'Image2', {}, ...
                'Image2Name', {}, 'Image3', {}, 'Image3Name', {}, 'Image4', {}, 'Image4Name', {}, ...
                'Image5', {}, 'Image5Name', {});
        otherwise
            % If they input an invalid response, just ask the question again
            data = makeData(question);
    end
end

% Helper function to edit image and make the gallery faces all grayscaled squares
function [gry] = editImg(img)
    img = imresize(img, [400, 400]);
    [~,~,l] = size(img);
    if l == 1
        % This is used for certain image files like .pgm that load with 1
        % dimension
        gry = img;
    else
        gry = double(img);
        gry = uint8((gry(:,:,1) + gry(:,:,2) + gry(:,:,3)) ./ 3);
        gry = cat(3, gry, gry, gry);
    end
end

% Helper function to create a montage image given a cell array of images
% (This is a little different than the separate ca2img function
function [montage] = ca2img(imgs, numinrow)
    numImgs = length(imgs);
    montage = [];
    montage1 = [];
    numimg = 0;
    ndx = 1;
    while ndx <= numImgs
        for n=ndx:ndx+numinrow-1
            img = imgs{n};
            montage1 = [montage1, img];
            numimg = numimg + 1;
            ndx = ndx + 1;
            if mod(numimg, numinrow) == 0 && numimg ~= 0
                montage = [montage; montage1];
                numimg = 0;
                montage1 = [];
            end
        end
    end
end

% Helper function to create an image out of input text and color
function [words] = str2img(str, color)
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
