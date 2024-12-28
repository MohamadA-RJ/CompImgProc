clc;
clear all;
%% Identifying Round Objects

% Read Image
Image = imread('Sample_11_Sauna.JPG');
imshow(Image)

%% This needs to be done initially to know the ratio of real-life (um) to pixel scale once done comment it (remove from code) 
% Measure the range of Fiber diameter [Arond 123, in this case] and the set the scale between pixels and um
% d = imdistline;  
% delete(d);
  
% Crop the downbar of image 
% Image = imcrop(Image); %To see the rectangualr position 
% imshow(Image)
Image = imcrop(Image,[0.5 0.5 1920 1434]);

%%
% Make the image Gray (better for visualization)
gray_image = rgb2gray(Image);
imshow(gray_image);

% Finding Circles function built-in matlab, you will need to modify the
% sensitivity based on your image property, I do it manually since I dont
% have many samples. But it would be more efficient to loop it for finding
% the optimal configuration. Just food for thought :)
[centers, radii] = imfindcircles(gray_image,[59 90],'ObjectPolarity','bright','Sensitivity',0.9861)
% Drwaing the Center index inside the circle
X_centers=centers(:,1);
Y_centers=centers(:,2);

%% Show detecting Circles
imshow(gray_image)
h = viscircles(centers,radii)
hold on;
plot(X_centers, Y_centers, 'kp', 'MarkerSize',20, 'MarkerFaceColor','r')

% Manually Deleting wrong or intersecting circles, I tried automamting this
% by making sure any interesting circles with a given area threshold shall
% be modified, but it was out of the scope of the project. 

centers(117,:)=0
radii(117,:)=0

centers(122,:)=0
radii(122,:)=0

centers(123,:)=0
radii(123,:)=0

centers(118,:)=0
radii(118,:)=0

centers(129,:)=0
radii(129,:)=0

centers(121,:)=0
radii(121,:)=0

centers(116,:)=0
radii(116,:)=0

centers(115,:)=0
radii(115,:)=0

centers(101,:)=0
radii(101,:)=0

centers(127,:)=0
radii(127,:)=0

centers(125,:)=0
radii(125,:)=0

centers(133,:)=0
radii(133,:)=0

centers(131,:)=0
radii(131,:)=0

centers(39,:)=0
radii(39,:)=0

centers(130,:)=0
radii(130,:)=0

centers(42,:)=0
radii(42,:)=0

% To delete any rows with zeros 
centers( ~any(centers,2), : ) = [];  %rows
centers( :, ~any(centers,1) ) = [];  %columns

radii( ~any(radii,2), : ) = [];  %rows
radii( :, ~any(radii,1) ) = [];  %columns
%% Show detecting Circles After Modification

% Drwaing the Center index inside the circle
X_centers=centers(:,1);
Y_centers=centers(:,2);
figure (1)
imshow(gray_image)
h = viscircles(centers,radii)
hold on;
plot(X_centers, Y_centers, 'kp', 'MarkerSize',20, 'MarkerFaceColor','r')
hold off; 

exportgraphics(gcf,['Output1.png'],'Resolution',100)

 %% Trying to Mask the Circles in Binary Form
figure(2)

% create a blank canvas similar to our original image.
cartoon_Canvas = zeros(size(gray_image),class(gray_image));

radius=round (radii); % Rounding Radius
centers_round= round (centers);
for i=1:117
newradius= radius(i);   
circ_mask = double(getnhood(strel('ball',newradius,newradius,0)));
imshow(circ_mask, 'InitialMagnification', 100);
exportgraphics(gcf,['figure2.png'],'Resolution',500)
end

%Finally we convolve the image into the canvas

cartoon_Canvas = imfilter(cartoon_Canvas,circ_mask,'conv');

%Next we need to find all the pixels that are part of the background. 
bw = false(size(gray_image,1),size(gray_image,2));
bw(sub2ind(size(bw),centers_round(:,2),centers_round(:,1))) = true;

% Then we convolve this image with a circular mask to get circles painted. 
% Then we complement the image to highlight the background (in white) and record the locations (linear indices) 
% of the pixels belonging to the background.
bw = imfilter(bw,circ_mask);
bw = imcomplement(bw);
imshow(bw)
bg_idx_gray = find(bw);
%% Measuring FVF based on the binary area 
% FVF (1-White area)
percentageWhite = nnz(bw) / numel(bw);
FVF=1-percentageWhite;

exportgraphics(gcf,['Output2.png'],'Resolution',100)
