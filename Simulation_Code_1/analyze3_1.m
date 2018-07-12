function  [numComp, perComp, numExp, totAvgWait, XAvgWait,YAvgWait,totAvgWaitZ,XAvgWaitZ,YAvgWaitZ,recharge,restock,refill,idleTotal] = analyze3_1(manager)
% Analyze function for UAV simulation
%   returns numerical results of the UAV simulation
%   for some of the variables, including the high priority requests
%   UAV's, and zones
%   input: manager = UAV manager object to analyze

    %% The loop to get the number of high priority requests, the unfinished requests,
    % and the total wait time
    numX = 0; % number of high priority requests generated
    numY = 0;
    unfinished = 0; % number of unfinished requests
    waitTime = 0; % The total amount of time waited
    waitX = 0;
    waitY = 0;
    % Completed requests
    for c=1:length(manager.completedList)
        if(manager.completedList(c).cargoType == 'X')
            numX=numX+1;
            waitX = waitX + 1;
        else
            numY = numY + 1;
            waitY = waitY + 1;
        end
            waitTime = waitTime + manager.completedList(c).timeElapsed;        
    end
    % Expired requests
    for c=1:length(manager.expiredList)
        waitTime = waitTime + manager.expiredList(c).exprTime;       
    end
    
    %% Consolidate the lists into: Low & High priority
    XReq = Request6.empty;
    YReq = Request6.empty;
    
    XWait = 0;
    YWait = 0;
    zoneWaitX = zeros(length(manager.requestZones),1); % Stores high priority wait times for each zone
    zoneWaitY = zeros(length(manager.requestZones),1); % Stores low priority wait times per zone
    zoneCountX = zeros(length(manager.requestZones),1); % Stores number of high priority requests in each zone
    zoneCountY = zeros(length(manager.requestZones),1); % Stores number of low priority requests in each zone
    % Extract requests from completed list and count up wait times
    for c=1:length(manager.completedList)
        if manager.completedList(c).cargoType == 'X'
            XReq(length(XReq)+1)= manager.completedList(c);
            XWait = XWait+manager.completedList(c).timeElapsed;
            i=manager.completedList(c).zone.ID;
            zoneWaitX(i)=zoneWaitX(i)+manager.completedList(c).timeElapsed;
            zoneCountX(i)=zoneCountX(i)+1;       
        else
            YReq(length(YReq)+1)=manager.completedList(c);
            YWait = YWait + manager.completedList(c).timeElapsed;
            i=manager.completedList(c).zone.ID;
            zoneWaitY(i)=zoneWaitY(i)+manager.completedList(c).timeElapsed;
            zoneCountY(i)=zoneCountY(i)+1;
        end
    end
    % Extract from the expired list and count wait times
    for c=1:length(manager.expiredList)
        if manager.expiredList(c).priority==1
            XReq(length(XReq)+1)= manager.expiredList(c);
            XWait = XWait + manager.expiredList(c).exprTime;
            i=manager.expiredList(c).zone.ID;
            zoneWaitX(i)=zoneWaitX(i)+manager.expiredList(c).timeElapsed;
            zoneCountX(i)=zoneCountX(i)+1;
        else
            YReq(length(YReq)+1)=manager.expiredList(c);
            YWait = YWait + manager.expiredList(c).exprTime;
            i=manager.expiredList(c).zone.ID;
            zoneWaitY(i)=zoneWaitY(i)+manager.expiredList(c).timeElapsed;
            zoneCountY(i)=zoneCountY(i)+1;

        end
    end
    % Extract from active lists and count up wait times
    for c=1:length(manager.requestZones)
        for k=1:length(manager.requestZones(c).activeList)
           if(manager.requestZones(c).activeList(k).cargoType==1)
                XReq(length(XReq)+1)= manager.requestZones(c).activeList(k);
                XWait = XWait+manager.requestZones(c).activeList(k).timeElapsed;
                zoneWaitX(c)=zoneWaitX(c)+manager.requestZones(c).activeList(k).timeElapsed;
                zoneCountX(c)=zoneCountX(c)+1;
           else
                YReq(length(YReq)+1)= manager.requestZones(c).activeList(k);
                YWait = YWait+manager.requestZones(c).activeList(k).timeElapsed;
                zoneWaitY(c)=zoneWaitY(c)+manager.requestZones(c).activeList(k).timeElapsed;
                zoneCountY(c)=zoneCountY(c)+1;
           end
        end
    end
    % Calculate averages
    XAvgWait = XWait/length(XReq);
    YAvgWait = YWait/length(YReq);
    totAvgWait = (XWait+YWait)/(length(XReq)+length(YReq));
    
    XAvgWaitZ = zoneWaitX./zoneCountX;
    YAvgWaitZ = zoneWaitY./zoneCountY;
    totAvgWaitZ = (zoneWaitX+zoneWaitY)./(zoneCountX+zoneCountY);
    
    
    %% This is a loop to get some information based on the zones
    XPriZ = zeros(length(manager.requestZones), 1)'; % The number of High priority requests per zone
    completedRequestZ = zeros(length(manager.requestZones), 1)'; % The number of completed requests per zone
    waitTimeZ = zeros(length(manager.requestZones), 1)'; % The combined wait time per zone
    unfinishedRequestZ = zeros(length(manager.requestZones), 1)'; % The number of unfinished requests per zone
    YPriZ = zeros(length(manager.requestZones), 1)'; % The number of low priority requests per zone
    averageTimeZ = zeros(length(manager.requestZones), 1)'; % The average time waited per zone
    zoneNum = zeros(length(manager.requestZones), 1)'; % The zone number
    for c = 1:length(manager.requestZones)
        for k = 1:length(manager.requestZones(c).activeList)
        if (manager.requestZones(c).activeList(k).cargoType == 'X')
            XPriZ(c) = XPriZ(c) + 1;
        end 
        if (manager.requestZones(c).activeList(k).status == 0)
            completedRequestZ(c) = completedRequestZ(c) + 1;
            waitTimeZ(c) = waitTimeZ(c) + manager.requestZones(c).activeList(k).timeElapsed;
        end
        end
        zoneNum(c) = c;
        unfinishedRequestZ(c) = length(manager.requestZones(c).activeList) - completedRequestZ(c); 
        YPriZ(c) = length(manager.requestZones(c).activeList) - XPriZ(c); 
        averageTimeZ(c) = waitTimeZ(c)./length(manager.requestZones(c).activeList);
    end
    
    %% The loop to get the refuel information for all the UAV's
    restock = 0; % The total number of restocks
    refill = 0; % The total number of refills
    recharge = 0; % The total number of refuels
    recharge = 0; % The total number of recharges
    idleTime = 0; % Amount of time UAV's were idle
    for c = 1:length(manager.uavList)
        restock = restock + manager.uavList(c).emptyCounter;
        recharge = recharge + manager.uavList(c).lowChargeCounter;
        recharge = recharge + manager.uavList(c).rechargeCounter;
        idleTime = idleTime + manager.uavList(c).idleTotal;        
    end
        refill = recharge + restock;
        idleTotal = idleTime;
        %% The loops to get the information for the individual UAV's
        restockuav = zeros(length(manager.uavList), 1); % The total number of restocks per UAV
    refilluav = zeros(length(manager.uavList), 1); % The total number of refills per UAV
    rechargeuav = zeros(length(manager.uavList), 1); % The total number of recharges per UAV
    refueluav = zeros(length(manager.uavList), 1); % The total number of refuels per UAV
    requestsMetUAV = zeros(length(manager.uavList), 1);
    for c = 1:length(manager.uavList)
        
        restockuav(c) = manager.uavList(c).emptyCounter;
        refueluav(c) = manager.uavList(c).lowChargeCounter;
        rechargeuav(c) = manager.uavList(c).rechargeCounter;
        requestsMetUAV(c) = manager.uavList(c).requestsMet;
    end
        refilluav = refueluav + restockuav;
        
        
        %% The information to tell about the requests based on their priority and the average wait time for high priority requests
        
        XMet = 0; % The number of High Priority Requests Met
        YMet = 0; % The number of Low Priority Requests met
        YWait = 0;
        XWait = 0; % The time Waited by high Priority requests
        
        for c = 1:length(manager.completedList)
            if((manager.completedList(c).cargoType == 'X') && (manager.completedList(c).status == 0))
                XMet = XMet + 1;
                XWait = XWait + manager.completedList(c).timeElapsed;
            elseif(manager.completedList(c).cargoType == 'Y' && manager.completedList(c).status == 0) 
                YMet = YMet + 1;
            end
    
        end
            % Expired requests
        for c=1:length(manager.expiredList)
            XWait = XWait + manager.expiredList(c).exprTime;       
        end
        
        XAverage = XWait/XMet; % The average wait time for high priority requests
        
                
    %% This is where all of the information is stored to make the table for the analysis
    completedPer = (manager.requestsMet/length(manager.completedList)) * 100;
    numY = length(manager.completedList)-numX; % The Number of Low Priorty requests met
    averageTime = waitTime/(length(manager.expiredList)+length(manager.completedList)); % The average wait time between requests
    numComp = manager.requestsMet;
    perComp = completedPer;
    numExp = manager.expired;
    wait =  averageTime;
    waitX = XAverage;
    
    
    
%         labels1 = {'Completed_Requests','Number_Expired','High_Priority_Requests','Low_Priority_Requests', 'Unfinished_Requests', 'Percent_Completed', 'Average_Wait', 'High_Priority_Average_Wait','High_Requests_Met', 'Low_Requests_Met', 'Recharge', 'Refuel', 'Restock', 'Refill'};
%     labels2 = {'Zone','Completed_Requests','High_Priority_Requests','Low_Priority_Requests', 'Unfinished_Requests', 'Average_Wait'};
%     labels3 = {'Recharge','Low_Charge', 'Empty', 'Refill', 'RequestsMet'};
%     tableOver = table(manager.requestsMet,manager.expired, numHi, numLow, unfinished, completedPer, averageTime, hiAverage, hiMet, loMet, recharge, refuel, restock, refill, 'VariableNames', labels1);
% 
%     tableZone = table(zoneNum,completedRequestZ, hiPriZ, loPriZ, unfinishedRequestZ, averageTimeZ, 'VariableNames', labels2);
%     
%     tableUAV = table(rechargeuav, refueluav, restockuav, refilluav, requestsMetUAV, 'VariableNames', labels3);
end


