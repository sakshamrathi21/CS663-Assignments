% im1 = double(imread("goi1.jpg"));
% im2 = double(imread("goi2_downsampled.jpg"));
% n = 12; % Number of points
% x1 = zeros(1, n);
% y1 = zeros(1, n);
% x2 = zeros(1, n);
% y2 = zeros(1, n);
% 
% for i=1:n
%     figure(1); 
%     imshow(im1/255); 
%     [x1(i), y1(i)] = ginput(1);
%     figure(2); 
%     imshow(im2/255); 
%     [x2(i), y2(i)] = ginput(1);
% end
% save('selected_points.mat', 'x1', 'y1', 'x2', 'y2');
im1 = double(imread("goi1.jpg"));
im2 = double(imread("goi2_downsampled.jpg"));

% Check if images loaded correctly
if isempty(im1)
    disp('Error: im1 is empty.');
end
if isempty(im2)
    disp('Error: im2 is empty.');
end

% Load the saved points
load('selected_points.mat', 'x1', 'y1', 'x2', 'y2');

% Display the loaded points
disp('Loaded points from Image 1:');
disp([x1' y1']);
disp('Loaded points from Image 2:');
disp([x2' y2']);

movingPoints = [x1' y1'];
fixedPoints = [x2' y2'];
n = size(movingPoints, 1);

A = zeros(2*n, 6);
b = zeros(2*n, 1);

for i = 1:n
    A(2*i-1, :) = [movingPoints(i, 1), movingPoints(i, 2), 0, 0, 1, 0];
    A(2*i, :) = [0, 0, movingPoints(i, 1), movingPoints(i, 2), 0, 1];
    b(2*i-1) = fixedPoints(i, 1);
    b(2*i) = fixedPoints(i, 2);
end

x = A\b;


T = [x(1), x(2), x(5); x(3), x(4), x(6); 0, 0, 1];


disp('Transformation Matrix:');
disp(T);
invT = inv(T);

[rows, cols, channels] = size(im1);
warpedImg = zeros(size(im2), 'uint8');

for r = 1:size(im2, 1)
    for c = 1:size(im2, 2)
        originalCoords = invT * [c; r; 1];
        xOriginal = originalCoords(1);
        yOriginal = originalCoords(2);
        
        xNearest = round(xOriginal);
        yNearest = round(yOriginal);
        
        if xNearest >= 1 && xNearest <= cols && yNearest >= 1 && yNearest <= rows
            warpedImg(r, c, :) = im1(yNearest, xNearest, :);
        end
    end
end

combinedImg = [im1, im2, warpedImg];
imshow(combinedImg);
title('Original Image (Left), Target Image (Middle), Warped Image (Right)');

% % Compute the affine transformation
% tform = fitgeotform2d(movingPoints, fixedPoints, 'affine');
% 
% % Check the transformation parameters
% disp('Transformation Matrix:');
% disp(tform);
% 
% % Apply the affine transformation to goi1
% outputImage = imwarp(im1, tform, 'OutputView', imref2d(size(im2)));
% 
% % Display the original, target, and transformed images
% figure;
% subplot(1, 3, 1); imshow(im1 / 255); title('Original Image (goi1)');
% subplot(1, 3, 2); imshow(im2 / 255); title('Target Image (goi2)');
% subplot(1, 3, 3); imshow(outputImage / 255); title('Transformed Image (goi1 to goi2)');
% 

