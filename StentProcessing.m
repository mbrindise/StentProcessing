%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            PURDUE UNIVERSITY
%                               AETHER LAB
%                  Code Created By:  Melissa Brindise
%                  Code Created On:  January 22, 2015
%
%   ------------------------- CODE INFORMATION-----------------------------
%   TITLE:  StentProcessing.m
%
%   PURPOSE:  Creates Stent Removed velocity field for Pulsatile stent data
%   by reading stent list and removing velocity vectors that overlay the
%   stent mask
%
%   ---------------------------- INPUTS -----------------------------------
%   outbase : The base file name of the stent removed velocity fields
%   resbase : The base file name of the phase averaged velocity fields
%   stentnmbase : Stent mask base file name
%   phend :   The number of phase averaged velocity fields
%   'stentlistXXX.mat' : The file containing what stent masks correspond
%                         with what velocity field
%   SAVEDAT : Indicate whethere a .dat vel. field file should be saved
%   SAVEMAT : Indicate whethere a .mat vel. field file should be saved
%
%   ---------------------------- OUTPUTS ----------------------------------
%   Code saves .mat and/or .dat files containing all of the prana PIV
%   outputted information and velocity fields with data removed at stent
%   struts
%   -----------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% USER INPUTS
% STENT FILE INPUTS
outbase = 'CULv4_p3_StRm_';   % Output base file name
resbase = 'CULv4_p2_PhAvg_';  % Input base file name
stentnmbase = 'CULv4_p2_StRm_StentIm_'; % Stent mask base file name
phend = 243;    % Number of phase averaged velocity fields
load('stentlistCUL.mat');   % Load stent list for which number stent to use
                            % remove stent
% SAVE OPTIONS
SAVEDAT = 0;  % Set to 1 = Save .dat file of velocity field
SAVEMAT = 1;  % Set to 1 = Save .mat file of velocity field


%% CODE RUNNING
% Code runs through each phase averaged velocity field and sets the
% velocity points that are located on a stent location to NaN
for i = 1:1:phend
    stnum = stentlist(i);  % Get current stent value
    stent = double(imread([stentnmbase,num2str(stnum,'%06i'),'.tif']));
    matfile = load([resbase,num2str(i,'%04i'),'.mat']);
    matNS = removeStent(matfile,stent);  % Function sets vel. points to NaN
    
    % Save stent removed output
    X = matNS.X;
    Y = matNS.Y;
    U = matNS.U;
    V = matNS.V;
    Uavgvel = U(:,:,1);
    Vavgvel = V(:,:,1);
    C = matNS.C;
    cavg = C(:,:,1);
    Di = matNS.Di;
    diavg = Di(:,:,1);
    Eval = matNS.Eval;
    evalavg = Eval(:,:,1);
    t_opt = matNS.t_opt;
    outdat = [outbase,num2str(i,'%04i'),'.dat'];    % Set out .dat name
    outmat = [outbase,num2str(i,'%04i'),'.mat'];   % Set out .mat name
    if SAVEDAT
        dattitle = [outbase,'MF_StentRemoved_',num2str(i,'%04i')];
        write_dat_val_C(outdat,X,Y,Uavgvel,Vavgvel,evalavg,cavg,diavg,4,i,dattitle,t_opt);
        fprintf('\nWritten: %s',outdat)
    end
    if SAVEMAT
        save(outmat,'U','V','X','Y','Eval','C','Di','t_opt')
        fprintf('\nWritten: %s',outmat)
    end
    
end




