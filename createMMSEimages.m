%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            PURDUE UNIVERSITY
%                               AETHER LAB
%                  Code Created By:  Melissa Brindise
%                  Code Created On:  November 1, 2014
%             Code Last Updated On:  June 26, 2015
%
%   ------------------------- CODE INFORMATION-----------------------------
%   TITLE:  createMMSEimages.m
%
%   PURPOSE:  Code was designed for stacking n PIV images and taking the max
%   pixel intensity at each point, in order to better identify masked
%   regions such as a stent that is blocking the images.  Each image is
%   processed with a minimal mean square error (MMSE) linear filter prior
%   to stacking it.
%
%   ---------------------------- INPUTS -----------------------------------
%   base : File path and name base of images
%   numstart : Number corresponding to the first image to be stacked
%   n : Number of images to stack
%
%   ---------------------------- OUTPUTS ----------------------------------
%   A single image is saved to the path of the base image with the name for
%   example being CRUv4_ImMMSE_000000.tif.  The inputted variable numstart
%   is the number used for saving the file.
%   -----------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = createMMSEimages(base,numstart,n)

% Get zeropad
% NOTE: THIS IS AN OBSOLETE METHOD FOR CODING ZEROPAD
if numstart < 10
    zeropad = '000';
elseif numstart < 100
    zeropad = '00';
elseif numstart < 1000
    zeropad = '0';
else
    zeropad = '';
end
imstart = numstart + (n-1)/2; % Get middle of stack number
im1 = [base,zeropad,num2str(numstart),'.tif']; % Load fist image
I = double(imread(im1));
[hgt,wdt] = size(I);        % Get size of images

% Initialize variables
imAdd = zeros(hgt,wdt,n);
improA = zeros(hgt,wdt,n);
initval = imstart - (n-1)/2; % First stack number
endval = imstart + (n-1)/2; % Last stack number
w = 1;

% Start MMSE filter and image stacking
for i = initval:1:endval
    if i < 10
        zeropad = '000';
    elseif i < 100
        zeropad = '00';
    elseif i < 1000
        zeropad = '0';
    else
        zeropad = '';
    end
    imname = [base,zeropad,num2str(i),'.tif'];
    I = double(imread(imname));

    %% APPLY FIR MMSE FILTER
    corrIm = I;

    % Get training data set
    [hgt,wdt] = size(corrIm);
    a = 1;
    b = 1;
    c = 0;
    for m = 6:20:(hgt-3)
        for n = 4:20:(wdt-3)
            c = c + 1;
            Y(c,1) = I(m,n);
            z = corrIm(m-3:m+3,n-3:n+3);
            zC = reshape(z,1,49);
            zPt = [zC(1:24),zC(26:end)];
            zF = [corrIm(m,n),zPt];
            Z(c,:) = zF;
        end
    end

    % Compute Covariance and Correlation
    [v1,v2] = size(Z);
    Y = Y(1:v1,:);
    N = c;
    Rzz = (Z'*Z)/N;
    rzy = (Z'*Y)/N;

    % Compute Theta Star
    theta = Rzz\rzy;
    ord_theta = [theta(2:25)',theta(1),theta(26:end)'];
    Fscale = sum(theta);
    tFilt = reshape(ord_theta,7,7)';
    tFilt2 = rot90(fliplr(tFilt),-1);

    % Apply Linear FIR Filter
    X = zeros(hgt,wdt);
    for m = 4:1:(hgt-3)
        for n = 4:1:(wdt-3)
            wind = corrIm(m-3:m+3,n-3:n+3);
            X(m,n) = sum(sum(wind.*tFilt2))/Fscale;
        end
    end
    
    % Contract stretch image
    if mod(i,2) == 0
        I = stretch(I,60,160);
    else
        I = stretch(I,15,30);
    end
    
    % Add new image to stack
    imAdd(:,:,w) = X;
    improA(:,:,w) = I;
    w = w + 1;
    fprintf('\nImage %s Processed',imname)
end
fprintf('\n\n')
% Take max of stacked images
imMMSE = max(imAdd,[],3);

% Save Image file
imwrite(uint8(imMMSE),[base,'CRUv4_ImMMSE_',num2str(numstart,'%06i'),'.tif'])



