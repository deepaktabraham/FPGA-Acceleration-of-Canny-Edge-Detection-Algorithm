% script to convert image to text file
A = imread('Lenna.jpg');
B = imresize(A, [128 128]);
C = rgb2gray(B);
D = imgaussfilt(C);

fileID = fopen('test.txt', 'w');
fprintf(fileID, '%d\n', D);
fclose(fileID);
