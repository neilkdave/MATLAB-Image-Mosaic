%Computer Vision Project 2
%image mosaicing

close all;
clear all;
 
%Part A
%Read in images
images = zeros(340,512,3,3,'uint8');
 for i = 0:2
     %images(:,:,:,i+1) = imread(sprintf('C:\\Users\\thearchitect\\Desktop\\Dana Office\\DanaHallWay2\\im%d.jpg',i));
     images(:,:,:,i+1) = imread(sprintf('C:\\Users\\thearchitect\\Desktop\\DanaHallWay2\\im%d.jpg',i));
 end
 
 %Obtain Two images from stack and convert 2 to grayscale
image1 = (images(:,:,:,1));
image2 = (images(:,:,:,2));
gray1 = rgb2gray(image1);
gray2 = rgb2gray(image2);

%Harris Corner Detector (used harris.m on Computer Vision blackboard page)
C1 = harris(gray1, 1, 4, 25000,0); %Professor Camps Demo Parameter Values
C2 = harris(gray2,1,4,25000,0);
%Sparse Set already obtained and Corner Response Measured in harris.m to obtain best corner results
 
%Results
figure, imshow(image1);
hold on
plot(C1(:,2),C1(:,1),'g*')
 
figure, imshow(image2);
hold on
plot(C2(:,2),C2(:,1),'g*')
 
% Normalized Cross Correlation
  
Correspondences = zeros(length(C1), 2, 2);
count = 0;
for index = 1:length(C1)
    y1 = C1(index,1);
    x1 = C1(index,2);
    %Ignore Borders
    if x1 <= 10 || y1 <= 10 || x1 > 512-10 || y1 > 340-10
        continue;
    end
    %Creates 20 by 20 Window around each corner in each image
    window1 = gray1(y1-10:y1+10,x1-10:x1+10);
    Cors = zeros(length(C2), 1);
    for index2 = 1:length(C2)
        y2 = C2(index2,1);
        x2 = C2(index2,2);
        
      
        %Ignore Borders
        
     if x2 <= 10 || y2 <= 10 || x2 > 512-10 || y2 > 340-10
            continue;
     end
        window2 = gray2(y2-10:y2+10,x2-10:x2+10);
        NCC = normxcorr2(window1, window2);
        
        %Look at center of NCC matrix
        Cors(index2,1) = NCC(21,21);
    end
 [cthresh, index] = max(Cors);
   %90 Percent Threshold on NCC
    if cthresh > 0.9
     count = count+1;
     Correspondences(count,1:2,1) = [y1,x1];
     Correspondences(count,1:2,2) = C2(index,1:2);
    end
end
Correspondences = Correspondences(1:count,:,:);
 
figure;
 
bothImgs = zeros(340*2, 512);
bothImgs(1:340,1:end) = gray1(:,:);
bothImgs(340+1:end,1:end) = gray2(:,:);
imshow(bothImgs/255);
nu = 45;
colz = jet(nu);
hold on;
plot(C1(:,2), C1(:,1), 'rx', 'MarkerSize', 7, 'LineWidth', 2);
plot(C2(:,2), C2(:,1)+340+1, 'bx', 'MarkerSize', 7, 'LineWidth', 2);
for i = 1:length(Correspondences)
plot([Correspondences(i,2,1), Correspondences(i,2,2)], ...
    [Correspondences(i,1,1), Correspondences(i,1,2)+340+1], ...
    '-o', 'MarkerFaceColor', colz(i,:), ...
    'LineWidth', 2, 'Color', colz(i,:));
end
 
% Homography, function already does RANSAC
m1 = Correspondences(:,:,1);
m1(:,[1,2])=m1(:,[2,1]);
m2 = Correspondences(:,:,2);
m2(:,[1,2])=m2(:,[2,1]);
[H, inliers1, inliers2] = estimateGeometricTransform(m1, m2, 'projective');
 
% Display Homography Outliers
figure;
imshowpair(gray1(:,:), gray2(:,:),'montage');
hold on;
scatter(m1(:,1), m1(:,2), 'rx', 'LineWidth', 2);
scatter(m2(:,1)+512+1, m2(:,2), 'gx', 'LineWidth', 2);
scatter(inliers1(:,1), inliers1(:, 2),36, 'b', 'fill', 'LineWidth', 5);
scatter(inliers2(:,1)+512+1, inliers2(:, 2), 36, 'b', 'fill', 'LineWidth', 5);
 
%mosaicing
homo = imwarp(gray1(:,:), H);
% Warped Compared to Original
figure;
imshowpair(gray2(:,:), homo, 'montage');
Tform = maketform('projective', H.T);
[mosaic, stitched_mask, im1, im2] = stitch(gray2(:,:), gray1(:,:),Tform);
figure;
imshow(mosaic);








