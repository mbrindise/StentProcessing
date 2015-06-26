%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            PURDUE UNIVERSITY
%                               AETHER LAB
%                  Code Created By:  Melissa Brindise
%                  Code Created On:  November 1, 2015
%
%   ------------------------- CODE INFORMATION-----------------------------
%   TITLE:  findStent.m
%
%   PURPOSE:  Using the max stack, MMSE filtered image, this code processes
%   the image in sections to maximize the contrast between the stent
%   locations and no-stent locations.  Then it runs connected components to
%   find the stent.
%
%   ---------------------------- INPUTS -----------------------------------
%   ImMMSEname : File path and base name of the MMSE and max stacked image
%   (should be the output image from createMMSEimage.m)
%   maskname : File path and base name of PIV mask
%
%   ---------------------------- OUTPUTS ----------------------------------
%   stent : Binary image of the same size as the input MMSE image, where 1
%   indicates a pixel where the stent is located and 0 indicates a pixel
%   where the stent is not located
%   
%   -----------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [stent] = findStent(ImMMMSEname,maskname)
    
    % Load MMSE image and mask
    imraw = double(imread(ImMMSEname));
    mask = double(imread(maskname));
    [hgt,wdt] = size(imraw);
    
    imCC = zeros(hgt,wdt);  % Initialize corrected image
    avgfilt = fspecial('average',5);  % Initialze image processing filters
    se = strel('diamond',1);


    %% SEGMENT IMAGE PROCESSING
    % MMSE image is processed in sections for best results due to
    % differences in pixel intensity spacially throughout the image.  This
    % process is different for different image inputs, so this section
    % will be changed often.

    % SEGMENT 1 PROCESSING
    seg1o = imraw(20:810,1:475);
    seg1o = seg1o.*2;
    seg11 = stretch(seg1o,46,100);
    seg12 = stretch(seg11,92,113);
    seg13 = imdilate(seg12,se);
    seg1F = imdilate(seg13,se);
    imCC(20:810,1:475) = seg1F;

    % SEGMENT 2 PROCESSING
    seg2o = imraw(20:810,476:774);
    seg2o = seg2o.*2;
    seg21 = stretch(seg2o,56,70);
    seg22 = stretch(seg21,70,90);
    seg2F = imerode(seg22,se);
    imCC(20:810,476:774) = seg2F;

    % SEGMENT 3 PROCESSING
    seg3o = imraw(50:483,775:1336);
    seg3o = seg3o.*2;
    seg31 = stretch(seg3o,56,100);
    seg32 = stretch(seg31,0,128);
    seg33 = imdilate(seg32,se);
    seg3F = stretch(seg33,30,255);
    %seg32 = imfilter(seg31,avgfilt);
    %seg3F = stretch(seg32,80,150);
    imCC(50:483,775:1336) = seg3F;

    % SEGMENT 4 PROCESSING
    seg4o = imraw(80:810,1337:2014);
    seg4o = seg4o.*4;
    seg41 = stretch(seg4o,94,200);
    seg42 = imdilate(seg41,se);
    seg43 = stretch(seg42,62,102);
    %seg4F = stretch(seg43,220,255);
    %seg44 = stretch(seg43,128,185);
    %seg45 = imdilate(seg44,se);
    seg4F = imdilate(seg43,se);
    seg4F = imdilate(seg4F,se);
    imCC(80:810,1337:2014) = seg4F;
    
    % SEGMENT 4p1 PROCESSING
    seg4p1o = imraw(150:390,1625:1915);
    seg4p1o = seg4p1o.*4;
    seg4p11 = stretch(seg4p1o.*2,255,304);
    seg4p12 = imdilate(seg4p11,se);
    seg4p13 = imdilate(seg4p12,se);
    seg4p1F = stretch(seg4p13,88,172);
    imCC(150:390,1625:1915) = seg4p1F;

    % SEGMENT 5 PROCESSING
    seg5o = imraw(811:965,776:1515);
    seg5o = seg5o.*6;
%     seg51 = stretch(seg5o,150,180);
%     seg52 = imdilate(seg51,se);
%     seg5F = imdilate(seg52,se);
%     seg51 = stretch(seg5o.*2,135,190);
%     seg51d = imdilate(seg51,se);
%     seg52 = imdilate(seg51d,se);
%     seg53 = stretch(seg52,180,235);
%     seg5F = imdilate(seg53,se);
    seg51 = stretch(seg5o.*2,215,300);
    seg52 = stretch(seg51,180,255);
    seg5F = imdilate(seg52,se);
    imCC(811:965,776:1515) = seg5F;

    % SEGMENT 6 PROCESSING
    seg6o = imraw(966:1712,900:2014);
    seg6o = seg6o.*3;
    seg61 = stretch(seg6o.*4,160,220);
    seg62 = imdilate(seg61,se);
    seg6F = stretch(seg62,138,238);
%     seg61 = stretch(seg6o,47,80);
%     seg61d = imdilate(seg61,se);
%     seg6F = stretch(seg61d,77,124);
    imCC(966:1712,900:2014) = seg6F;
    
    % SEGMENT 6p1 PROCESSING
    seg6p1o = imraw(968:1229,900:2014);
    seg6p1o = seg6p1o.*3;
    %seg6p11 = stretch(seg6p1o.*4,160,220);
    %seg6p12 = imdilate(seg6p11,se);
    %seg6p1F = stretch(seg6p12,138,238);
    seg6p11 = stretch(seg6p1o.*3,160,190);
    seg6p12 = imdilate(seg6p11,se);
    seg6p1F = stretch(seg6p12,170,255);
%     seg61 = stretch(seg6o,47,80);
%     seg61d = imdilate(seg61,se);
%     seg6F = stretch(seg61d,77,124);
    imCC(968:1229,900:2014) = seg6p1F;

    % SEGMENT 7a PROCESSING
    seg7o = imraw(141:810,2015:2352);
    seg7o = seg7o.*4;
    seg71 = stretch(seg7o,96,140);
    seg72 = stretch(seg71,140,210);
    seg73 = imdilate(seg72,se);
    seg7F = stretch(seg73,165,255);
    imCC(141:810,2015:2352) = seg7F;
    
    % SEGMENT 7b PROCESSING
    seg7o = imraw(350:810,2015:2352);
    seg7o = seg7o.*4;
    seg71 = stretch(seg7o,100,132);
    seg72 = imdilate(seg71,se);
    seg73 = imdilate(seg72,se);
    seg74 = stretch(seg73,96,159);
    seg7F = imdilate(seg74,se);
    imCC(350:810,2015:2352) = seg7F;

    % SEGMENT 8 PROCESSING
    seg8o = imraw(484:600,775:1336);
    seg8o = seg8o.*2;
    seg81 = stretch(seg8o,46,54);
    seg82 = stretch(seg81,130,255);
    seg82e = imerode(seg82,se);
    seg8F = imdilate(seg82e,se);
    imCC(484:600,775:1336) = seg8F;

    % SEGMENT 9 PROCESSING
    seg9o = imraw(601:810,775:1336);
    seg9o = seg9o.*2;
%     seg91 = stretch(seg9o,47,63);
%     seg9F = stretch(seg91,80,123);
    seg91 = stretch(seg9o.*2,102,252);
    seg92 = imdilate(seg91,se);
    seg93 = stretch(seg92,34,57);
    seg94 = imdilate(seg93,se);
    seg95 = imdilate(seg94,se);
    seg9F = stretch(seg95,111,188);
    seg9F = imdilate(seg9F,se);
    seg9F = imdilate(seg9F,se);
    imCC(601:810,775:1336) = seg9F;
    
    % SEGMENT 10 PROCESSING
    seg1o = imraw(480:730,1016:1290);
    seg1o = seg1o.*4;
    seg11 = stretch(seg1o.*2,224,255);
    seg12 = imdilate(seg11,se);
    seg1F = stretch(seg12,132,197);
    imCC(480:730,1016:1290) = seg1F;
    
    % SEGMENT 4p2 PROCESSING
    seg4p2o = imraw(590:810,1287:1900);
    seg4p2o = seg4p2o.*4;
    seg4p21 = stretch(seg4p2o.*2,168,216);
    seg4p22 = stretch(seg4p21,180,255); 
    seg4p23 = stretch(seg4p22,112,255);
    seg4p2F = imdilate(seg4p23,se);
    imCC(590:810,1287:1900) = seg4p2F;
    
    % SEGMENT 4p3 PROCESSING
    seg4p3o = imraw(590:810,1900:2352);
    seg4p3o = seg4p3o.*4;
    seg4p31 = stretch(seg4p3o.*2,168,184);
    seg4p32 = imdilate(seg4p31,se);
    seg4p3F = stretch(seg4p32,150,255);
    imCC(590:810,1900:2352) = seg4p3F;
    
    
    
    %imCC = imerode(imCC,se);
    %imCC = imdilate(imCC,se);
    
    %% CONNECTED COMPONENTS
    stent = ConnectedComponents_mex(imCC,10,800,600,mask);
    




