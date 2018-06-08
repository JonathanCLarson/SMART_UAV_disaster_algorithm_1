function  [tableOver] = analyze(manager)
% Analyze function for UAV simulation
%   returns numerical results of the UAV simulation
%   for some of the variables, including the high priority requests
%   UAV's, and zones
%   input: manager = UAV manager object to analyze

    %% The loop to get the number of high priority requests, the unfinished requests,
    % and the total wait time
    hiMet = 0;      % number of high priority requests met
    lowMet = 0;     % number of low priority requests met
    unfinished = 0; % number of unfinished requests
    waitTime = 0;   % The total amount of time waited
    hiWait = 0;     % The total time waited for expired requests
    highTotal = 0;  % No 
    lowTotal = 0;   % number of low priority requests
    numHi=0;
    % Check through all requests for counting and waiting times
    for c=1:length(manager.completedList)
        if(manager.completedList(c).priority==1)
            hiMet=hiMet+1;
            hiWait=hiWait+manager.completedList(c).timeElapsed;
            numHi=numHi+1;
        else
            lowMet= lowMet+1;
        end
        waitTime = waitTime + manager.completedList(c).timeElapsed;        
    end
    highTotal = highTotal + hiMet;
    lowTotal = lowTotal + lowMet;
     
    % Count unfinished requests (stored in zones' active lists)
    for c = 1:length(manager.requestZones)
        unfinished = unfinished + length(manager.requestZones(c).activeList);
         for k=1:length(manager.requestZones(c).activeList)
            if(manager.requestZones(c).activeList(k).status == 1)
                highTotal = highTotal + 1;
                
                hiWait=hiWait+manager.requestZones(c).activeList(k).timeElapsed;
            else 
                lowTotal = lowTotal + 1;
            end
        end
    end
    
    % Count expired requests
    for c = 1:length(manager.expiredList)
            highTotal = highTotal + 1;
            hiWait=hiWait+manager.expiredList(c).exprTime;
    end
    
    
    
                
    %% This is where all of the information is stored to make the table for the analysis
    completedPer = (manager.requestsMet/(highTotal+lowTotal)) * 100; % Percent of all requests that have been completed
    averageTime = waitTime/length(manager.completedList); % The average wait time for completed requests
    hiAvg = hiWait/numHi;
        labels1 = {'Completed_Requests','Number_Expired','High_Priority_Met','Low_Priority_Met', 'Unfinished_Requests','Redirected_UAVs','Total_High','Total_Low', 'Percent_Completed', 'Average_Wait','High_Wait'};
        tableOver = table((hiMet+lowMet),manager.expired, hiMet, lowMet, unfinished, manager.numRedirect,highTotal,lowTotal,completedPer, averageTime,hiAvg, 'VariableNames', labels1);
    
end

