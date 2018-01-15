% script to convert text file to image
fileID = fopen('out.txt', 'r');
A = fscanf(fileID, '%d');
B = vec2mat(A, 124);
C = mat2gray(B);
imshow(C);