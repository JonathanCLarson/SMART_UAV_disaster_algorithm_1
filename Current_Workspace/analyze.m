%% Analyze function for UAV simulation
% returns numerical results of the UAV simulation
% input: manager = UAV manager object to analyze

function  {tableOver, tabelUAV, tableZone} = analyze(manager)
    numHi = 0;
    unfinished = 0;
    waitTime = 0;
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

    numLow=length(manager.requestList)-numHi;
    averageTime = waitTime/length(manager.requestList);
    labels1 = {'Completed_Requests','High_Priority_Requests','Low_Priority_Requests', 'Unfinished_Requests', 'Average_Wait'};
    
    tableZone = table(
    tableUAV = table(manager.uavArray.resupplyCounter, manager.uavArray.refuelCounter);
    tableOver = table(manager.requestsMet, numHi, numLow, unfinished, averageTime, 'VariableNames', labels1);
end


