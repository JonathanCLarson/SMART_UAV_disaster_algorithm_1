function  [tableOver, tableZone, tableUAV] = analyze(manager)
% Analyze function for UAV simulation
%   returns numerical results of the UAV simulation
%   for some of the variables, including the high priority requests
%   UAV's, and zones
%   input: manager = UAV manager object to analyze

    %% The loop to get the number of high priority requests, the unfinished requests,
    % and the total wait time
    hiMet = 0; % number of high priority requests met
    lowMet = 0; % number of low priority requests met
    unfinished = 0; % number of unfinished requests
    waitTime = 0; % The total amount of time waited
    hiUnMet = 0; % total unmet high priority requests
    lowUnMet = 0; % total unmet low priority requests
    
    for c=1:length(manager.completedList)
        if(manager.completedList(c).priority==1)
            hiMet=hiMet+1;
        else
            lowMet= lowMet+1;
        end
        waitTime = waitTime + manager.completedList(c).timeElapsed;        
    end
  
    for c = 1:length(manager.requestZones)
        unfinished = unfinished + length(manager.requestZones(c).activeList);
        for k = 1:length(manager.requestZones(c).activeList)
            if(manager.requestZones(c).activeList(k).priority==1)
                hiUnMet=hiUnMet+1;
            else
                lowUnMet=lowUnMet+1;
            end
        end
    end
    highTotal = hiMet+hiUnMet;
    lowTotal = lowMet+lowUnMet;
    

    %% This is a loop to get some information based on the zones
    hiPriZ = zeros(length(manager.requestZones), 1); % The number of High priority requests per zone
    completedRequestZ = zeros(length(manager.requestZones), 1); % The number of completed requests per zone
    waitTimeZ = zeros(length(manager.requestZones), 1); % The combined wait time per zone
    unfinishedRequestZ = zeros(length(manager.requestZones), 1); % The number of unfinished requests per zone
    loPriZ = zeros(length(manager.requestZones), 1); % The number of low priority requests per zone
    averageTimeZ = zeros(length(manager.requestZones), 1); % The average time waited per zone
    zoneNum = zeros(length(manager.requestZones), 1); % The zone number
    for c = 1:length(manager.requestZones)
        for k = 1:length(manager.requestZones(c).activeList)
        if (manager.requestZones(c).activeList(k).priority == 1)
            hiPriZ(c) = hiPriZ(c) + 1;
        end 
        if (manager.requestZones(c).activeList(k).status == 0)
            completedRequestZ(c) = completedRequestZ(c) + 1;
            waitTimeZ(c) = waitTimeZ(c) + manager.requestZones(c).activeList(k).timeElapsed;
        end
        end
        zoneNum(c) = c;
        unfinishedRequestZ(c) = length(manager.requestZones(c).activeList) - completedRequestZ(c); 
        loPriZ(c) = length(manager.requestZones(c).activeList) - hiPriZ(c); 
        averageTimeZ(c) = waitTimeZ(c)./length(manager.requestZones(c).activeList);
    end
    
    %% The loop to get the refuel information for all the UAV's
    restock = 0; % The total number of restocks
    refill = 0; % The total number of refills
    refuel = 0; % The total number of refuels
    recharge = 0; % The total number of recharges
    for c = 1:length(manager.uavList)
        restock = restock + manager.uavList(c).emptyCounter;
        refuel = refuel + manager.uavList(c).lowChargeCounter;
        recharge = recharge + manager.uavList(c).rechargeCounter;
        
    end
        refill = refuel + restock;
        
        %% The loops to get the information for the individual UAV's
        restockuav = zeros(length(manager.uavList), 1); % The total number of restocks per UAV
    refilluav = zeros(length(manager.uavList), 1); % The total number of refills per UAV
    rechargeuav = zeros(length(manager.uavList), 1); % The total number of recharges per UAV
    refueluav = zeros(length(manager.uavList), 1); % The total number of refuels per UAV
    requestsMetUAV = zeros(length(manager.uavList), 1);
    idleTimeuav = zeros(length(manager.uavList), 1); 
    for c = 1:length(manager.uavList)
        
        restockuav(c) = manager.uavList(c).emptyCounter;
        refueluav(c) = manager.uavList(c).lowChargeCounter;
        rechargeuav(c) = manager.uavList(c).rechargeCounter;
        requestsMetUAV(c) = manager.uavList(c).requestsMet;
        idleTimeuav(c) = manager.uavList(c).idleTotal;
    end
        refilluav = refueluav + restockuav;
        
        
        %% The information to tell about the requests based on their priority and the average wait time for high priority requests
        
        hiMet = 0; % The number of High Priority Requests Met
        loMet = 0; % The number of Low Priority Requests met
        hiWait = 0; % The time Waited by high Priority requests
        
        for c = 1:length(manager.completedList)
            if(manager.completedList(c).priority == 1 && manager.completedList(c).status==0)
                hiMet = hiMet + 1;
                hiWait = hiWait + manager.completedList(c).timeElapsed;
            elseif(manager.completedList(c).priority == 1000 && manager.completedList(c).status == 0) 
                loMet = loMet + 1;
            end
    
        end
        
        hiAverage = hiWait/hiMet; % The average wait time for high priority requests
        
                
    %% This is where all of the information is stored to make the table for the analysis
    completedPer = (manager.requestsMet/(highTotal+lowTotal)) * 100;
    numLow=length(manager.completedList)-hiMet; % The Number of Low Priorty requests met
    averageTime = waitTime/length(manager.completedList); % The average wait time between requests
    numComp = manager.requestsMet;
    perComp = completedPer;
    numExp = manager.expired;
    wait =  averageTime;
    waitHi = hiAverage;
    
    
    
        labels1 = {'Completed_Requests','Number_Expired','High_Priority_Met','Low_Priority_Met', 'Unfinished_Requests','Redirected_UAVs','Total_High','Total_Low', 'Percent_Completed', 'Average_Wait', 'High_Priority_Average_Wait','High_Requests_Met', 'Low_Requests_Met', 'Recharge', 'Refuel', 'Restock', 'Refill'};
    labels2 = {'Zone','Completed_Requests','High_Priority_Requests','Low_Priority_Requests', 'Unfinished_Requests', 'Average_Wait'};
    labels3 = {'Recharge','Low_Charge', 'Empty', 'Refill', 'RequestsMet', 'Idle_Time_UAV'};
    tableOver = table((hiMet+lowMet),manager.expired, hiMet, lowMet, unfinished, manager.numRedirect,highTotal,lowTotal,completedPer, averageTime, hiAverage, hiMet, loMet, recharge, refuel, restock, refill, 'VariableNames', labels1);

    tableZone = table(zoneNum,completedRequestZ, hiPriZ, loPriZ, unfinishedRequestZ, averageTimeZ, 'VariableNames', labels2);
    
    tableUAV = table(rechargeuav, refueluav, restockuav, refilluav, requestsMetUAV, idleTimeuav, 'VariableNames', labels3);
end

