# findFriends
A MATLAB function that performs facial recognition

## How to Use:
- Download all the files inlcuded in the repository
- Copy over the photos you want to use to the main folder where findFriends is (you may want to rename them for organization)
- Create a cell array of the file names (e.g. ca = {'p1.pgm', 'p2.pgm', ...};)
  - Alternatively you can create a cell array of MxNx3 uint8 image arrays
- Call ca2img to make your montage (e.g. montage = ca2img(ca, 2);)
- Call findFriends and make your custom database (REMEMBER TO HAVE 5 IMAGES FOR IT)
- Save your database as anything you want!

## Download Sample Images for Testing:
Download the ATT Face Database for trying this out on your own!
http://www.cl.cam.ac.uk/research/dtg/attarchive/facedatabase.html
