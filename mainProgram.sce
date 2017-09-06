clear;clc;
//Monte Carlo simulation for light propagation in tissue
//   (assume it's a single-layer tissue)
//Input:
//   times - repeated times of light propagation
//   theta_i - incident angle of light
//   ua, ut - absorption and extinction coefficient
//   n0, n1 - upper and lower refractive index
//Output:
//   A - absorption distribution in x-z plane (1cm*1cm)
//       (with a figure)

// main program //
// Custom function
exec (".\Function_MonteCarloOnSingleLayerTissue.sce");
//
times = 100;
ua = 0.1; ut = 20.1; n0 = 1; n1 = 1; theta_i = (45)*%pi/180;
delta_z = 0.005;
width=1; depth=0.5;
A = Function_MonteCarloOnSingleLayerTissue( times, theta_i, ua, ut, n0, n1 );
A = A /(delta_z*times*ua);
x = -width/2:0.005:width/2;
z = 0:0.005:depth;
//plot(A);
// Normalization
/*
sizeA = size(A);
maxA = 0;
minA = 255;
for i=1:1:sizeA(1)
    for j=1:1:sizeA(2)
        if(A(i,j) > maxA)
            maxA = A(i,j);
        end
        if(A(i,j) < minA)
            minA = A(i,j);
        end
    end
end
//A(:,:) = (A(:,:)-minA)/(maxA-minA)*255;
*/
im(:,:,1) = A(:,:);
im(:,:,2) = A(:,:);
im(:,:,3) = A(:,:);
imshow(im);
