function  [tableOver] = analyze(manager)
% Analyze function for UAV simulation
%   returns numerical results of the UAV simulation
%   for some of the variables, including the high priority requests
%   UAV's, and zones
%   input: manager = UAV manager object to analyze

    %% The loop to get the number of high priority requests, the unfinished requests,
    % and the total wait time
    XMet = 0;      % number of high priority requests met
    YMet = 0;     % number of low priority requests met
    unfinished = 0; % number of unfinished requests
    waitTime = 0;   % The total amount of time waited
    XWait = 0;     % The total time waited for expired requests
    XTotal = 0;  % No 
    YTotal = 0;   % number of low priority requests
    numX=0;
    % Check through all requests for counting and waiting times
    for c=1:length(manager.completedList)
        if(manager.completedList(c).cargoType == 'X')
            XMet=XMet+1;
            XWait=XWait+manager.completedList(c).timeElapsed;
            numX=numX+1;
        else
            YMet= YMet+1;
        end
        waitTime = waitTime + manager.completedList(c).timeElapsed;        
    end
    XTotal = XTotal + XMet;
    YTotal = YTotal + YMet;
     
    % Count unfinished requests (stored in zones' active lists)
    for c = 1:length(manager.requestZones)
        unfinished = unfinished + length(manager.requestZones(c).activeList);
         for k=1:length(manager.requestZones(c).activeList)
            if(manager.requestZones(c).activeList(k).status == 1)
                XTotal = XTotal + 1;
                
                XWait=XWait+manager.requestZones(c).activeList(k).timeElapsed;
            else 
                YTotal = YTotal + 1;
            end
        end
    end
    
    % Count expired requests
    for c = 1:length(manager.expiredList)
            XTotal = XTotal + 1;
            XWait=XWait+manager.expiredList(c).exprTime;
    end
    
    
    
                
    %% This is where all of the information is stored to make the table for the analysis
    completedPer = (manager.requestsMet/(XTotal+YTotal)) * 100; % Percent of all requests that have been completed
    averageTime = waitTime/length(manager.completedList); % The average wait time for completed requests
    XAvg = XWait/numX;
        labels1 = {'Completed_Requests','Number_Expired','X_Met','Y_Met', 'Unfinished_Requests','Redirected_UAVs','Total_X','Total_Y', 'Percent_Completed', 'Average_Wait','X_Wait'};
        tableOver = table((XMet+YMet),manager.expired, XMet, YMet, unfinished, manager.numRedirect,XTotal,YTotal,completedPer, averageTime,XAvg, 'VariableNames', labels1);
    
end

