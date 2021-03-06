function  [tableOver, tableUAV, tableZone] = analyze(manager)
% Analyze function for UAV simulation
%   returns numerical results of the UAV simulation
%   for some of the variables, including the high priority requests
%   UAV's, and zones
%   input: manager = UAV manager object to analyze

    %% The loop to get the number of high priority requests, the unfinished requests,
    % and the total wait time
    numHi = 0; % number of high priority requests generated
    unfinished = 0; % number of unfinished requests
    waitTime = 0; % The total amount of time waited
    
    for c=1:length(manager.requestList)
        if(manager.requestList(c).priority==1)
            numHi=numHi+1;
            
        end
        if (manager.requestList(c).status > 0)
            unfinished = unfinished + 1;
        else
            waitTime = waitTime + manager.requestList(c).timeElapsed;
        end
        
    end
    
    %% This is a loop to get some information based on the zones
    hiPriZ = zeros(length(manager.requestZones), 1); % The number of High priority requests per zone
    completedRequestZ = zeros(length(manager.requestZones), 1); % The number of completed requests per zone
    waitTimeZ = zeros(length(manager.requestZones), 1); % The combined wait time per zone
    unfinishedRequestZ = zeros(length(manager.requestZones), 1); % The number of unfinished requests per zone
    loPriZ = zeros(length(manager.requestZones), 1); % The number of low priority requests per zone
    averageTimeZ = zeros(length(manager.requestZones), 1); % The average time waited per zone
    zoneNum = zeros(length(manager.requestZones), 1); % The zone number
    for c = 1:length(manager.requestZones)
        for k = 1:length(manager.requestZones(c).requestList)
        if (manager.requestZones(c).requestList(k).priority == 1)
            hiPriZ(c) = hiPriZ(c) + 1;
        end 
        if (manager.requestZones(c).requestList(k).status == 0)
            completedRequestZ(c) = completedRequestZ(c) + 1;
            waitTimeZ(c) = waitTimeZ(c) + manager.requestZones(c).requestList(k).timeElapsed;
        end
        end
        zoneNum(c) = c;
        unfinishedRequestZ(c) = length(manager.requestZones(c).requestList) - completedRequestZ(c); 
        loPriZ(c) = length(manager.requestZones(c).requestList) - hiPriZ(c); 
        averageTimeZ(c) = waitTimeZ(c)./length(manager.requestZones(c).requestList);
    end
    
    %% The loop to get the refuel information for all the UAV's
    restock = 0; % The total number of restocks
    refill = 0; % The total number of refills
    refuel = 0; % The total number of refuels
    for c = 1:length(manager.uavList)
        restock = restock + manager.uavList(c).restockCounter;
        refuel = refuel + manager.uavList(c).refuelCounter;
        
    end
        refill = refuel + restock;
        
        %% The loops to get the information for the individual UAV's
        restockuav = zeros(length(manager.uavList), 1); % The total number of restocks per UAV
    refilluav = zeros(length(manager.uavList), 1); % The total number of refills per UAV
    refueluav = zeros(length(manager.uavList), 1); % The total number of refuels per UAV
    requestsMetUAV = zeros(length(manager.uavList), 1);
    for c = 1:length(manager.uavList)
        
        restockuav(c) = manager.uavList(c).restockCounter;
        refueluav(c) = manager.uavList(c).refuelCounter;
        requestsMetUAV(c) = manager.uavList(c).requestsMet;
    end
        refilluav = refueluav + restockuav;
        
        
        %% The information to tell about the requests based on their priority and the average wait time for high priority requests
        
        hiMet = 0; % The number of High Priority Requests Met
        loMet = 0; % The number of Low Priority Requests met
        hiWait = 0; % The time Waited by high Priority requests
        
        for c = 1:length(manager.requestList)
            if((manager.requestList(c).priority == 1) && (manager.requestList(c).status == 0))
                hiMet = hiMet + 1;
                hiWait = hiWait + manager.requestList(c).timeElapsed;
            elseif(manager.requestList(c).priority == 1000 && manager.requestList(c).status == 0) 
                loMet = loMet + 1;
            end
    
        end
        
        hiAverage = hiWait/hiMet; % The average wait time for high priority requests
        
                
    %% This is where all of the information is stored to make the table for the analysis
    completedPer = (manager.requestsMet/length(manager.requestList)) * 100;
    numLow=length(manager.requestList)-numHi; % The Number of Low Priorty requests met
    averageTime = waitTime/length(manager.requestList); % The average wait time between requests
    labels1 = {'Completed_Requests','Number_Expired','High_Priority_Requests','Low_Priority_Requests', 'Unfinished_Requests', 'Percent_Completed', 'Average_Wait', 'High_Priority_Average_Wait','High_Requests_Met', 'Low_Requests_Met', 'Refuel', 'Restock', 'Refill'};
    labels2 = {'Zone','Completed_Requests','High_Priority_Requests','Low_Priority_Requests', 'Unfinished_Requests', 'Average_Wait'};
    labels3 = {'Refuel', 'Restock', 'Refill', 'RequestsMet'};
    tableOver = table(manager.requestsMet,manager.expired, numHi, numLow, unfinished, completedPer, averageTime, hiAverage, hiMet, loMet, refuel, restock, refill, 'VariableNames', labels1);

    tableZone = table(zoneNum,completedRequestZ, hiPriZ, loPriZ, unfinishedRequestZ, averageTimeZ, 'VariableNames', labels2);
    
    tableUAV = table(refueluav, restockuav, refilluav, requestsMetUAV, 'VariableNames', labels3);
end


