# MATLAB-Image-Mosaic

The following code stitches two images together into the image one coordinate space based on a homography taken
between the images based on their correspondences. The stitch library used was obtained from http://tobw.net/index.php?cat_id=2&project=Panorama+Stitching+Demo+in+Matlab.

Rename your two images to Image001 and Image002 and enter the filepath to each location in the for loop at line 11.

This will then use a Harris Corner Detector to generate features for each image. Windows around each corner feature are compared to every corner feature of the 
second image (Normalized Cross Correlation). This generates a correspondences matrix. Features with a high correspondence between images are similar. 
Features that meet a similarity threshold in each image are used to generate a homography to warp image 2 to the image 1 coordinate system.

These images are then stitch together with functions found in the stitch.m library.