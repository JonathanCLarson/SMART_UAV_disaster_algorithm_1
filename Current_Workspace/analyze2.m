function  [numComp, numExp,wait,waitHi, recharge,extraCargo,refill,idleTotal] = analyze2(manager)
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
    waitHi=waitTimeHi/numHi;
    numComp = length(manager.completedList);
    numExp = length(manager.expiredList);
    
    
    %% The loop to get the refuel information for all the UAV's
    extraCargo = 0; % The number of times when the UAV returns to base with cargo
    recharge = 0; % The total number of recharges
    idleTime = 0; % Amount of time UAV's were idle
    lowCharge=0;
    empty=0;
    % Add up counted properties from each UAV
    for c = 1:length(manager.uavList)
        extraCargo = extraCargo + manager.uavList(c).extraCargo;
        recharge = recharge + manager.uavList(c).rechargeCounter;
        idleTime = idleTime + manager.uavList(c).idleTotal; 
        lowCharge = lowCharge + manager.uavList(c).lowChargeCounter;
        empty=empty+manager.uavList(c).emptyCounter;
    end
    refill = empty+lowCharge;   % Combined restocks and refuels
    idleTotal = idleTime;       % Total amount of time spent idle
end


