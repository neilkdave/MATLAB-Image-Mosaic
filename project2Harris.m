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