%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            PURDUE UNIVERSITY
%                               AETHER LAB
%                  Code Created By:  Melissa Brindise
%                  Code Created On:  June 26, 2015
%
%   ------------------------- CODE INFORMATION-----------------------------
%   TITLE:  WSSRunFile.m
%
%   PURPOSE:  Runs the WSS.m code iteratively through the time series of
%   phase averaged data.  Computes time averaged wall shear stress (TAWSS),
%   space averaged wall shear stress (SAWSS), oscillatory shear index
%   (OSI), and relative residence time (RRT).  Prior to calculating these
%   variables, NaN and zero columns are removed so they do not affect the
%   calculation.
%
%   ---------------------------- INPUTS -----------------------------------
%   inbase : File name base of files containing u and v velocity fields
%   which WSS is to be computed from
%   numstart : Number of phase averaged field to start with
%   numend : Number of phase averaged field to end with
%   caseinfo.loc : Indicates which part of the stent (i.e. which walls)
%   will be evaluated
%
%   ---------------------------- OUTPUTS ----------------------------------
%   This code saves three .mat whose names are of the form:
%   WSS_PSB_DistalMB_StRm.mat, OSI_PSB_DistalMB_StRm.mat, RRT_PSB_DistalMB_StRm.mat
%   These files contain the corresponding data for each variable computed.
%   The variables for the top and bottom wall are saved as two matlab
%   variables.
%   -----------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear

% USER INPUTS
caseinfo.loc = 1; % Set: 1 = Distal MB, 2 = Proximal MB, 3 = Side Branch
inbase = 'CRUv4_p3_StRm_';
numstart = 1;
numend = 229;

% COMPUTATIONS
set(gcf,'Visible','off')              % turns current figure "off" to prevent
set(0,'DefaultFigureVisible','off');  % pop ups and warnings
warning off

ext = '.mat';
extD = '.dat';
newct = 1;

% ITERATE THROUGH SPECIFIED TIME SERIES
for dumbiect = numstart:1:numend
    close all
    infileWSS = [inbase,num2str(dumbiect,'%04i'),ext]; % Infile name for WSS code
    fprintf('\nRunning File %s',infileWSS)
    % Try, Catch is used here once all bugs from WSS code are found.
    % Recommended to comment out try, catch, end for initial runs to
    % determine if any errors in code exist
    try
        WSS   % Run the WSS code
        [size1,size2] = size(wsheartop);
        for dumbiect2 = 1:1:size1
            if isnan(wsheartop(dumbiect2,1))    % Remove NaN data
                wsheartop(dumbiect2,1) = 0;
                wsheartop(dumbiect2,2) = 0;
                wsheartop(dumbiect2,3) = 0;
            end
            if abs(wsheartop(dumbiect2,1)) > 1e4    % Remove outlier calculations
                wsheartop(dumbiect2,1) = 0;
            end
        end
        [size1,size2] = size(wshearbot);    
        for dumbiect2 = 1:1:size1
            if isnan(wshearbot(dumbiect2,1))    % Remove NaN data
                wshearbot(dumbiect2,1) = 0;
                wshearbot(dumbiect2,2) = 0;
                wshearbot(dumbiect2,3) = 0;
            end
            if abs(wshearbot(dumbiect2,1)) > 1e4    % Remove outlier calculations
                wshearbot(dumbiect2,1) = 0;
            end
        end
        % Save WSS, x-position, and y-position data in matrices
        WSStop(:,dumbiect) = wsheartop(:,1);
        WSSbot(:,dumbiect) = wshearbot(:,1);
        WSS_Xtop(:,dumbiect) = wsheartop(:,2);
        WSS_Ytop(:,dumbiect) = wsheartop(:,3);
        WSS_Xbot(:,dumbiect) = wshearbot(:,2);
        WSS_Ybot(:,dumbiect) = wshearbot(:,3);
    catch
        % If error in WSS calculations of a specific time series, NaNs are
        % reported for that time series in the data and saved in the
        % variable badPhAvgTimes
        [len,~] = size(WSStop);
        [len2,~] = size(WSSbot);
        WSStop(:,dumbiect) = NaN.*ones(len,1);
        WSSbot(:,dumbiect) = NaN.*ones(len2,1);
        WSS_Xtop(:,dumbiect) = NaN.*ones(len,1);
        WSS_Ytop(:,dumbiect) = NaN.*ones(len,1);
        WSS_Xbot(:,dumbiect) = NaN.*ones(len2,1);
        WSS_Ybot(:,dumbiect) = NaN.*ones(len2,1);
        badPhavgTimes(newct) = dumbiect;
        newct = newct + 1;
        fprintf('\nBad Time Point: %i',dumbiect)
    end
end 

% TAWSS, SAWSS, OSI, AND RRT CALCULATIONS
WSStopsave = WSStop;    % Save off WSStop and WSSbot so bad time series points
WSSbotsave = WSSbot;    % are known
[WSStop,WSSbot] = removeNaN(WSStop,WSSbot);   % Remove NaN values for calculations
[WSStop,WSSbot] = removeZeros(WSStop,WSSbot); % Remove zero columns for calculations

% Compute TAWSS and SAWSS
WSStopTA = mean(abs(WSStop),2);
WSSbotTA = mean(abs(WSSbot),2);
WSStopT = mean(WSStop,1);
WSSbotT = mean(WSSbot,1);

% Compute OSI
OSIbot_num = abs(trapz(WSSbot,2));
OSIbot_den = trapz(abs(WSSbot),2);
OSItop_num = abs(trapz(WSStop,2));
OSItop_den = trapz(abs(WSStop),2);
OSIbot = 1/2*(1 - OSIbot_num./OSIbot_den);
OSItop = 1/2*(1 - OSItop_num./OSItop_den);
[OSItop,OSIbot] = removeNaN(OSItop,OSIbot);

% Compute RRT
RRTbot = 1./((1-2*OSIbot).*WSSbotTA);
RRTtop = 1./((1-2*OSItop).*WSStopTA);
RRTbot = isfinite(RRTbot).*RRTbot;
RRTtop = isfinite(RRTtop).*RRTtop;
[RRTtop,RRTbot] = removeNaN(RRTtop,RRTbot);

% Save Output files
if caseinfo.loc == 1
    save('WSS_CRU_DistalMB_StRm2.mat','WSStopsave','WSSbotsave','WSStopTA','WSSbotTA','WSStopT','WSSbotT')
    save('OSI_CRU_DistalMB_StRm2.mat','OSIbot','OSItop')
    save('RRT_CRU_DistalMB_StRm2.mat','RRTbot','RRTtop')
elseif caseinfo.loc == 2
    save('WSS_CRU_ProximalMB_StRm2.mat','WSStopsave','WSSbotsave','WSStopTA','WSSbotTA','WSStopT','WSSbotT')
    save('OSI_CRU_ProximalMB_StRm2.mat','OSIbot','OSItop')
    save('RRT_CRU_ProximalMB_StRm2.mat','RRTbot','RRTtop')
else
    save('WSS_CRU_SideBranch_StRm2.mat','WSStopsave','WSSbotsave','WSStopTA','WSSbotTA','WSStopT','WSSbotT')
    save('OSI_CRU_SideBranch_StRm2.mat','OSIbot','OSItop')
    save('RRT_CRU_SideBranch_StRm2.mat','RRTbot','RRTtop')
end

