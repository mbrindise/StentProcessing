inbase = 'CULv4_p3_StRm_';
ext = '.mat';
extD = '.dat';
numstart = 1;
numend = 243;
newct = 1;

set(gcf,'Visible','off')              % turns current figure "off"
set(0,'DefaultFigureVisible','off');
warning off

for dumbiect = numstart:1:numend
    close all
    infileWSS = [inbase,num2str(dumbiect,'%04i'),ext];
    fprintf('\nRunning File %s',infileWSS)
    try
        WSS
        [size1,size2] = size(wsheartop);
        for dumbiect2 = 1:1:size1
            if isnan(wsheartop(dumbiect2,1))
                wsheartop(dumbiect2,1) = 0;
                wsheartop(dumbiect2,2) = 0;
                wsheartop(dumbiect2,3) = 0;
            end
            if abs(wsheartop(dumbiect2,1)) > 1e4
                wsheartop(dumbiect2,1) = 0;
            end
        end
        [size1,size2] = size(wshearbot);
        for dumbiect2 = 1:1:size1
            if isnan(wshearbot(dumbiect2,1))
                wshearbot(dumbiect2,1) = 0;
                wshearbot(dumbiect2,2) = 0;
                wshearbot(dumbiect2,3) = 0;
            end
            if abs(wshearbot(dumbiect2,1)) > 1e4
                wshearbot(dumbiect2,1) = 0;
            end
        end
        WSStop(:,dumbiect) = wsheartop(:,1);
        WSSbot(:,dumbiect) = wshearbot(:,1);
        WSS_Xtop(:,dumbiect) = wsheartop(:,2);
        WSS_Ytop(:,dumbiect) = wsheartop(:,3);
        WSS_Xbot(:,dumbiect) = wshearbot(:,2);
        WSS_Ybot(:,dumbiect) = wshearbot(:,3);
    catch
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

WSStopsave = WSStop;
WSSbotsave = WSSbot;
[WSStop,WSSbot] = removeNaN(WSStop,WSSbot);
[WSStop,WSSbot] = removeZeros(WSStop,WSSbot);
WSStopTA = mean(abs(WSStop),2);
WSSbotTA = mean(abs(WSSbot),2);
WSStopT = mean(WSStop,1);
WSSbotT = mean(WSSbot,1);

OSIbot_num = abs(trapz(WSSbot,2));
OSIbot_den = trapz(abs(WSSbot),2);
OSItop_num = abs(trapz(WSStop,2));
OSItop_den = trapz(abs(WSStop),2);
OSIbot = 1/2*(1 - OSIbot_num./OSIbot_den);
OSItop = 1/2*(1 - OSItop_num./OSItop_den);
[OSItop,OSIbot] = removeNaN(OSItop,OSIbot);

RRTbot = 1./((1-2*OSIbot).*WSSbotTA);
RRTtop = 1./((1-2*OSItop).*WSStopTA);
RRTbot = isfinite(RRTbot).*RRTbot;
RRTtop = isfinite(RRTtop).*RRTtop;
[RRTtop,RRTbot] = removeNaN(RRTtop,RRTbot);

if caseinfo.loc == 1
    save('WSS_CUL_DistalMB_StRm2.mat','WSStopsave','WSSbotsave','WSStopTA','WSSbotTA','WSStopT','WSSbotT')
    save('OSI_CUL_DistalMB_StRm2.mat','OSIbot','OSItop')
    save('RRT_CUL_DistalMB_StRm2.mat','RRTbot','RRTtop')
elseif caseinfo.loc == 2
    save('WSS_CUL_ProximalMB_StRm2.mat','WSStopsave','WSSbotsave','WSStopTA','WSSbotTA','WSStopT','WSSbotT')
    save('OSI_CUL_ProximalMB_StRm2.mat','OSIbot','OSItop')
    save('RRT_CUL_ProximalMB_StRm2.mat','RRTbot','RRTtop')
end

