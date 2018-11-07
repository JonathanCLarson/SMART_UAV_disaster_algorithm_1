function  [numComp, numExp,perExp,wait,avgTimeLeft,recharge,extraCargo,refill,idleTotal] = analyze2visual(manager)
% Analyze function for UAV simulation
%   returns numerical results of the UAV simulation
%   for some of the variables, including the high priority requests
%   UAV's, and zones
% Input: manager = UAV manager object to analyze
% Output:
%   numComp: The number of completed requests

    %% The loop to get the number of high priority requests, the unfinished requests,
    % and the total wait time
    numX = 0; % number of high priority requests generated
    XMet = 0; % The number of High Priority Requests Met
    numReq = 0; % number of total requests
    waitTime = 0; % The total amount of time waited
    waitTimeX = 0; % Total time waited by high priority requests
    timeLeft = 0;
    % Each loop processes requests from that source.
    % Completed requests
    for c=1:length(manager.completedList)
        if(manager.completedList(c).cargoType=='X')
            numX=numX+1;
            XMet=XMet+1;
            waitTimeX = waitTimeX + manager.completedList(c).timeElapsed;
        end
        timeLeft = timeLeft + (manager.completedList(c).exprTime-manager.completedList(c).timeElapsed);
        waitTime = waitTime + manager.completedList(c).timeElapsed;
        numReq=numReq+1;
        
    end
    
    % Expired requests
    for c=1:length(manager.expiredList)
        waitTime = waitTime + manager.expiredList(c).exprTime; 
        if manager.expiredList(c).cargoType=='X'
            waitTimeX=waitTimeX+manager.expiredList(c).exprTime;
            numX=numX+1;
        end
        numReq=numReq+1;
    end
    
    % Unfinished requests
    for c=1:length(manager.requestZones)
        for k=1:length(manager.requestZones(c).activeList)
            thisReq = manager.requestZones(c).activeList(k); % temporary variable
            if thisReq.cargoType=='X'
                numX=numX+1;
                waitTimeX = waitTimeX + thisReq.timeElapsed;
            end
            waitTime=waitTime+thisReq.timeElapsed;
            numReq=numReq+1;

        end
    end
    wait = waitTime/numReq;
    waitX=waitTimeX/numX;
    numComp = length(manager.completedList);
    numExp = length(manager.expiredList);
    perExp = numExp/numReq;
    avgTimeLeft = timeLeft/(length(manager.completedList)+length(manager.expiredList));
    
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


