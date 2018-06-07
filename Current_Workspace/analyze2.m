function  [numComp, numExp,wait,waitHi, recharge,restock,refill,idleTotal] = analyze2(manager)
% Analyze function for UAV simulation
%   returns numerical results of the UAV simulation
%   for some of the variables, including the high priority requests
%   UAV's, and zones
% Input: manager = UAV manager object to analyze
% Output:
%   numComp: The number of completed requests

    %% The loop to get the number of high priority requests, the unfinished requests,
    % and the total wait time
    numHi = 0; % number of high priority requests generated
    hiMet = 0; % The number of High Priority Requests Met
    loMet = 0; % The number of Low Priority Requests met
    numReq=0; % number of total requests
    waitTime = 0; % The total amount of time waited
    waitTimeHi = 0; % Total time waited by high priority requests
    
    % Completed requests
    for c=1:length(manager.completedList)
        if(manager.completedList(c).priority==1)
            numHi=numHi+1;
            hiMet=hiMet+1;
            waitTimeHi = waitTimeHi + manager.completedList(c).timeElapsed;
        end
        waitTime = waitTime + manager.completedList(c).timeElapsed;
        numReq=numReq+1;
    end
    
    % Expired requests
    for c=1:length(manager.expiredList)
        waitTime = waitTime + manager.expiredList(c).exprTime; 
        waitTimeHi=waitTimeHi+manager.expiredList(c).exprTime;
        numHi=numHi+1;
        numReq=numReq+1;
    end
    
    % Unfinished requests
    for c=1:length(manager.requestZones)
        for k=1:length(manager.requestZones(c).activeList)
            thisReq = manager.requestZones(c).activeList(k); % temporary variable
            if thisReq.status==1
                numHi=numHi+1;
                waitTimeHi = waitTimeHi + thisReq.timeElapsed;
            end
            waitTime=waitTime+thisReq.timeElapsed;
            numReq=numReq+1;

        end
    end
    wait = waitTime/numReq;
    numComp = length(manager.completedList);
    numExp = length(manager.expiredList);
    
    %% The loop to get the refuel information for all the UAV's
    restock = 0; % The total number of restocks
    refill = 0; % The total number of refills
    recharge = 0; % The total number of recharges
    idleTime = 0; % Amount of time UAV's were idle
    for c = 1:length(manager.uavList)
        restock = restock + manager.uavList(c).emptyCounter;
        recharge = recharge + manager.uavList(c).rechargeCounter;
        idleTime = idleTime + manager.uavList(c).idleTotal;        
    end
    refill = recharge + restock;
    idleTotal = idleTime;
    %% The loops to get the information for the individual UAV's
    restockuav = zeros(length(manager.uavList), 1);     % The total number of restocks per UAV
    refilluav = zeros(length(manager.uavList), 1);      % The total number of refills per UAV
    rechargeuav = zeros(length(manager.uavList), 1);    % The total number of recharges per UAV
    refueluav = zeros(length(manager.uavList), 1);      % The total number of refuels per UAV
    requestsMetUAV = zeros(length(manager.uavList), 1); % Number of requests met by each UAV
    
    
    for c = 1:length(manager.uavList)
        restockuav(c) = manager.uavList(c).emptyCounter;
        refueluav(c) = manager.uavList(c).lowChargeCounter;
        rechargeuav(c) = manager.uavList(c).rechargeCounter;
        requestsMetUAV(c) = manager.uavList(c).requestsMet;
    end
        refilluav = refueluav + restockuav;
        
        
        %% The information to tell about the requests based on their priority and the average wait time for high priority requests
        
        
        loWait = 0;
        hiWait = 0; % The time Waited by high Priority requests
        
        for c = 1:length(manager.completedList)
            if((manager.completedList(c).priority == 1) && (manager.completedList(c).status == 0))
                hiMet = hiMet + 1;
                hiWait = hiWait + manager.completedList(c).timeElapsed;
            elseif(manager.completedList(c).priority == 1000 && manager.completedList(c).status == 0) 
                loMet = loMet + 1;
            end
    
        end
            % Expired requests
        for c=1:length(manager.expiredList)
            hiWait = hiWait + manager.expiredList(c).exprTime;       
        end
        
        hiAverage = hiWait/hiMet; % The average wait time for high priority requests
        
                
    %% This is where all of the information is stored to make the table for the analysis
    numLow=length(manager.completedList)-numHi; % The Number of Low Priorty requests met
    averageTime = waitTime/(numReq); % The average wait time between requests
    averageTimeHi = waitTimeHi/numHi;
    numComp = manager.requestsMet;
    numExp = manager.expired;
    wait =  averageTime;
    waitHi = averageTimeHi;    
end


