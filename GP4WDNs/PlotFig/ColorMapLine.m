M=[140400 70.7850 1
 140401 70.7923 2
 140402 70.7993 3
 140403 70.8067 4
 140404 70.8139 5
 140405 70.8212 3];

x = M(:,1) ; %// extract "X" column
y = M(:,2) ; %// same for "Y"
c = M(:,3) ; %// extract color index for the custom colormap

%% // define your custom colormap
custom_colormap = [
    1  0 0 ; ... %// red
    1 .5 0 ; ... %// orange
    1  1 0 ; ... %// yellow
    0  1 0 ; ... %// green
    0  0 1 ; ... %// blue
    ] ;

%% // Prepare matrix data
xx=[x x];           %// create a 2D matrix based on "X" column
yy=[y y];           %// same for Y
zz=zeros(size(xx)); %// everything in the Z=0 plane
cc =[c c] ;         %// matrix for "CData"

%// draw the surface (actually a line)
hs=surf(xx,yy,zz,cc,'EdgeColor','interp','FaceColor','none','Marker','o') ;

colormap(custom_colormap) ;     %// assign the colormap
shading flat                    %// so each line segment has a plain color
view(2) %// view(0,90)          %// set view in X-Y plane
colorbar