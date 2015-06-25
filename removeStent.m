%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            PURDUE UNIVERSITY
%                               AETHER LAB
%                  Code Created By:  Melissa Brindise
%                  Code Created On:  January 22, 2015
%
%   ------------------------- CODE INFORMATION-----------------------------
%   TITLE:  removeStent.m
%
%   PURPOSE:  Removes velocity vectors that overlay the stent mask by
%   setting them to NaN
%
%   ---------------------------- INPUTS -----------------------------------
%   infile : File containing the PIV outputted X, Y, U, V information
%   stent : Binary stent mask with 1's indicating stent locations and 0's
%   indicating no stent locations
%
%   ---------------------------- OUTPUTS ----------------------------------
%   nostent : File containing the stent removed X, Y, U, V information
%   (Note: X and Y in this function remain unchanged) 
%   -----------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [nostent] = removeStent(infile,stent)

% Get X,Y,U, V components from infile
X = infile.X;
Y = infile.Y;
U = infile.U(:,:,1);
V = infile.V(:,:,1);
%U1 = infile.U(:,:,2); % Can uncomment if more than 1 peak was saved from Prana
%U2 = infile.U(:,:,3);
%U3 = infile.U(:,:,4);
%V1 = infile.U(:,:,2);
%V2 = infile.U(:,:,3);
%V3 = infile.U(:,:,4);
U = flipud(U);   % Flip components to be compatible with mask
V = flipud(V);
%U1 = flipud(U1);
%U2 = flipud(U2);
%U3 = flipud(U3);
%V1 = flipud(V1);
%V2 = flipud(V2);
%V3 = flipud(V3);



[hgt,wdt] = size(X);

% Runs through each point in vector field and evaluates if it is overlayed
% on a stent or not

for i = 1:1:hgt
    for j = 1:1:wdt
        col = X(i,j);   % Get (x,y) point location
        row = Y(i,j);
        stentval = stent(row,col);  % Determine if stent location
        if stentval == 255
            U(i,j) = NaN;   % Set velocity vectors to NaN
            V(i,j) = NaN;
            %U1(i,j) = 0;
            %U2(i,j) = 0;
            %U3(i,j) = 0;
            %V1(i,j) = 0;
            %V2(i,j) = 0;
            %V3(i,j) = 0;
        end
    end
end
U = flipud(U);
V = flipud(V);
%U1 = flipud(U1);
%U2 = flipud(U2);
%U3 = flipud(U3);
%V1 = flipud(V1);
%V2 = flipud(V2);
%V3 = flipud(V3);

UA(:,:,1) = U;
%UA(:,:,2) = U1;
%UA(:,:,3) = U2;
%UA(:,:,4) = U3;
VA(:,:,1) = V;
%VA(:,:,2) = V1;
%VA(:,:,3) = V2;
%VA(:,:,4) = V3;

% Save nostent output file
nostent = infile;
nostent.U = UA;
nostent.V = VA;

end




