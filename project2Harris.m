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