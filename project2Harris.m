%Computer Vision Project 2
close all;
clear all;

%Part A
images = zeros(340,512,3,3,'uint8');
 for i = 0:2
     images(:,:,:,i+1) = imread(sprintf('C:\\Users\\thearchitect\\Desktop\\Dana Office\\DanaOffice\\im%d.jpg',i));
 end

 %Obtain Two Grayscale images form stack
image1 = (images(:,:,:,1));
image2 = (images(:,:,:,2));
gray1 = rgb2gray(image1);
gray2 = rgb2gray(image2);

%Harris Corner Detector
C1 = harris(gray1, 1, 4, 25000,0); %Professor Camps Demo Parameter Values (uses her provided non disclosable library but if you modify parameters works well, just not as well with Matlab Harris Function)
C2 = harris(gray2,1,4,25000,0);

%Sparse Set already obtained and Corner Response Measured
%Display Results

figure, imshow(image1);
hold on
plot(C1(:,2),C1(:,1),'b*')

figure, imshow(image2);
hold on
plot(C2(:,2),C2(:,1),'b*')

% normalized cross correlations

Correspondences = zeros(length(C1), 2, 2);
count = 0;
for i = 1:length(C1)
    y1 = C1(i,1);
    x1 = C1(i,2);
    if x1 <= 10 || y1 <= 10 || x1 > 512-10 || y1 > 340-10
        continue;
    end
    %Creates 20 by 20 Window around each corner in each image
    w1 = gray1(y1-10:y1+10,x1-10:x1+10);
    ccs = zeros(length(C2), 1);
    for j = 1:length(C2)
        y2 = C2(j,1);
        x2 = C2(j,2);
        if x2 <= 10 || y2 <= 10 || x2 > 512-10 || y2 > 340-10
            continue;
        end
        w2 = gray2(y2-10:y2+10,x2-10:x2+10);
        ncc = normxcorr2(w1, w2);
        ccs(j,1) = ncc(21,21);
    end
    [cc, index] = max(ccs);
    if cc > 0.9
        count = count+1;
        Correspondences(count,1:2,1) = [y1,x1];
        Correspondences(count,1:2,2) = C2(index,1:2);
    end
end
Correspondences = Correspondences(1:count,:,:);

% display matching corners with image 1 above image 2
% interesting points with high correlation
figure;
cmap = hsv(length(Correspondences));
bothImgs = zeros(340*2, 512);
bothImgs(1:340,1:end) = gray1(:,:);
bothImgs(340+1:end,1:end) = gray2(:,:);
imshow(bothImgs/255);
hold on;
plot(C1(:,2), C1(:,1), 'rx', 'MarkerSize', 7, 'LineWidth', 2);
plot(C2(:,2), C2(:,1)+340+1, 'bx', 'MarkerSize', 7, 'LineWidth', 2);

for i = 1:length(Correspondences)
    plot([Correspondences(i,2,1), Correspondences(i,2,2)], ...
         [Correspondences(i,1,1), Correspondences(i,1,2)+340+1], ...
         '-o', 'MarkerFaceColor', cmap(i,:), ...
         'LineWidth', 2, 'Color', cmap(i,:));
end

% ransac and homography
m1 = Correspondences(:,:,1);
m1(:,[1,2])=m1(:,[2,1]);
m2 = Correspondences(:,:,2);
m2(:,[1,2])=m2(:,[2,1]);
[H, inliers1, inliers2] = estimateGeometricTransform(m1, m2, 'projective');

% display inliers and outliers from best homography found 
% from the interesting points with high correlation which ones 
% fit the homography
figure;
cmap = hsv(length(inliers1));
imshowpair(gray1(:,:), gray2(:,:), 'montage');
hold on;
scatter(m1(:,1), m1(:,2), 'rx', 'LineWidth', 2);
scatter(m2(:,1)+512+1, m2(:,2), 'gx', 'LineWidth', 2);
scatter(inliers1(:,1), inliers1(:, 2), ...
        36, cmap, 'fill', 'LineWidth', 5);
scatter(inliers2(:,1)+512+1, inliers2(:, 2), ...
        36, cmap, 'fill', 'LineWidth', 5);% ransac and homography
m1 = Correspondences(:,:,1);
m1(:,[1,2])=m1(:,[2,1]);
m2 = Correspondences(:,:,2);
m2(:,[1,2])=m2(:,[2,1]);
[H, inliers1, inliers2] = estimateGeometricTransform(m1, m2, 'projective');

% display inliers and outliers from best homography found 
% from the interesting points with high correlation which ones 
% fit the homography
figure;
cmap = hsv(length(inliers1));
imshowpair(gray1(:,:), gray2(:,:), 'montage');
hold on;
scatter(m1(:,1), m1(:,2), 'rx', 'LineWidth', 2);
scatter(m2(:,1)+512+1, m2(:,2), 'gx', 'LineWidth', 2);
scatter(inliers1(:,1), inliers1(:, 2), ...
        36, cmap, 'fill', 'LineWidth', 5);
scatter(inliers2(:,1)+512+1, inliers2(:, 2), ...
        36, cmap, 'fill', 'LineWidth', 5);
		
% mosaicing/stitching
warp = imwarp(gray1(:,:), H);
% display warped image 1 compared to original image 1
figure;
imshowpair(gray2(:,:), warp, 'montage');
% display warped image 1 next to original image 2
figure;
imshowpair(warp, gray2(:,:), 'montage');
tform = maketform('projective', H.T);
[stitched_image, stitched_mask, im1, im2] = stitch(gray2(:,:), ...
                                                   gray1(:,:), ...
                                                   tform);

figure;
imshow(stitched_image);
