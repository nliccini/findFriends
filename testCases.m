%% Testing The Code
%--------------------------------------------------------------------------
%
% You may use the following test cases for each problem to test your code.
% The function call with the test-inputs is shown in the first line of each
% test case, and the correct outputs are displayed in subsequent lines.
%
% If you wish to try this out with your own friends, take at least 4 screen
% shots of each person's face. Ideally it's best to rename each face as
% 'Name1', 'Name2', etc (just to make things easier when making your
% database). 
%
% 1. Take screenshots of your friends' faces and name appropriately
% 2. Create a cell array of the file names (usually use 'Name6' for each)
% 3. Call mont = ca2img(filenames, number of faces you want in each row)
% 4. Call str = findFriends(mont) where mont is either the filename or the
% uint8 image of the montage you just created
% 5. Check for accuracy by dividing the number of correct names by the
% total number of names. This algorithm is reported to have only a 91%
% average accuracy, so judge its performance with that in mind 
%
%% Grading
%--------------------------------------------------------------------------------
%
% Keep in mind that I did not create this machine learning algorithm
% (although I wish I had!) and am subject to its inaccuracy. When grading
% the outputs, do not use isequal(str3_soln, str3), instead I suggest you divide the
% number of correct names by the total number of names and average the
% scores for all the test cases. This might be a handy grading system, but then
% again you all know how to grade things better than I do!
%
%% Function Name: findFriends
%
% load montages.mat
% load filenames.mat
% load solns.mat
%
% Test Cases:
% str1_soln = findFriends(mont1);
% 		There are 8 faces in this photo: Nick, Paul, Sam, David, Gianna, Fleming, ...
%           Geraghty, Joe.
% 
% str2_soln = findFriends(mont2);
% 		There are 12 faces in this photo: Sam, Julia, Ben, Lee, Paul, Sam, Andrew, ...
%           Chris, Nick, Gianna, David, Fleming.
% 
% str3_soln = findFriends(mont3);
% 		There are 24 faces in this photo: Julia, Nick, Lee, Paul, Joe, Jimmy, ...
%           Geraghty, David, Chris, Ben, Andrew, Nick, Julia, Gianna, Sam, Joe, ... 
%           Fleming, Andrew, Lee, Julia, Chris, Ben, Andrew, Fleming.
%
% str4_soln = findFrinds(customMont)
%       Make your own! Please refer to the README.txt file for steps to
%       make your own cases using the ATT_FACES faces
%
%-------------------------------------------------------------------------------