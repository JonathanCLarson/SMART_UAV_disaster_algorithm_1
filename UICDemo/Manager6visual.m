%%  Manager6
% Jonathan Larson and Gabe Flores and Ted Townsend
% Fleet manager to direct the UAV fleet and coordinate with requests from
% the request zones.
%   Assigns UAV's to deliver supplies to request zones, and refreshes the
%   status of the fleet
% This version has continuous request values rather than binary
% 6/14/2018

classdef Manager6visual < handle
    
    properties
        requestZones    % list of the request zones
        completedList   % List of requests to assign to UAV's
        expiredList     % List of expired requests
        uavList         % List of uav's in the fleet
        time            % Stores the current time
        timeFac         % The time Factor
        base            % the base for the UAV's
        requestsMet     % to keep track of the requests met
        expired         % Counts the number of expired requests
        priFac          % the Priority factor
        addedVal        % Value added to distance in HD function
        numRedirect     % Count the number of times UAV's were redirected
        probCrash       % The probability of a UAV crashing each time step
%         activeHi        % Number of high priority requests 
        highReqs          % The list for the highest priority requests
        containedCargo  % The cargo currently carried by the UAVs 
    end
    methods
        % Constructor, initialize index to 1 to assign first request
        % Initializes the time at 0, starts off with an empty drone list,
        % and gets the request zones and the base
        
        function obj = Manager6visual(zones, base, priFac, timeFac,addedVal)
            obj.requestZones = zones;
            obj.time = 0;
            obj.uavList = UAVDrone6.empty;
            obj.base = base;
            obj.completedList = Request6.empty;
            obj.expiredList = Request6.empty;
            obj.requestsMet = 0;
            obj.priFac = priFac;
            obj.timeFac = timeFac;
            obj.addedVal = addedVal;
            obj.expired = 0;
            obj.numRedirect = 0;
            obj.probCrash=0;
            obj.highReqs=Request6.empty;
            
        end
        % Adds uav to the manager's list of uav's 
        function addUAV(obj, uav)
            obj.uavList(length(obj.uavList) + 1, 1) = uav;
        end
        
        % Function to lose a UAV
        % Input: index = the index of the lost UAV in the UAV list
        % POSTCONDITION: The designated UAV has been removed from the list
        % and no longer moves.
        function byebye(obj,index)
            plot(obj.uavList(index).position(1),obj.uavList(index).position(2),'rp','MarkerFaceColor','r','MarkerSize',20)

            disp("UAV "+index+" IS DOWN!")
            obj.uavList(index).speed=0;
            % Remove the lost UAV from the UAV list
            if length(obj.uavList)<=1
                % Lose the only remaining UAV
                obj.uavList=UAVDrone6.empty;                
            else
                % Remove the designated UAV
                for c=index:length(obj.uavList)-1
                   obj.uavList(c)=obj.uavList(c+1);             
                end
                obj.uavList=obj.uavList(1:length(obj.uavList)-1);
            
            end
        end
            
            
       % Function to refresh the UAV's and requests
        function refresh(obj, time)
            obj.time = time;
            % Refresh request zones
            for k=1:length(obj.requestZones)
                obj.requestZones(k).refresh(time);
            end
            % Refresh UAV's
            for c=1:length(obj.uavList)
                obj.uavList(c).refresh(time);
                
            end

            obj.requestsMet=0;
            % Set number of requests to 0 and recalculate
            for i = 1:length(obj.uavList)
                obj.requestsMet = obj.requestsMet + obj.uavList(i).requestsMet;
            end
            
            % Count the number of expired requests
            obj.expired = length(obj.expiredList);
            
            % Simulate a lost UAV )`:
            for c=1:length(obj.uavList)
                if isnan(obj.uavList(c).position(1))
                    disp(obj.time)
                    disp(obj.uavList(c).rangeLeft)
                end
%                 if rand<obj.probCrash
%                     obj.byebye(c);
%                 end
            end
        end
        
        %% Get Request types
        % Function to return the total number of X and Y requests
        function [numX,numY] = getNumRequests(obj)
            numX = 0;
            numY = 0;
            % count from completed requests
            for c=1:length(obj.completedList)
                if obj.completedList(c).cargoType == 'X'
                    numX = numX+1;
                else
                    numY = numY + 1;
                end
            end
            % count from expired
            for c=1:length(obj.expiredList)
                if obj.expiredList(c).cargoType == 'X'
                    numX = numX+1;
                else
                    numY = numY + 1;
                end
            end
            % count from active lists
            for c=1:length(obj.requestZones)
                for k=1:length(obj.requestZones(c).activeList)
                    if obj.requestZones(c).activeList(k).cargoType == 'X'
                        numX = numX + 1;
                    else
                        numY = numY + 1;
                    end
                end
            end
        end
        
        
        %% Assign Function
        % Assignment function, which can also set the status of the request 
        %   Output: the request assignment for the UAV
        function assign(obj)
            % Create an array of UAV's that are available to be assigned
            UAVs = UAVDrone6.empty; % UAVs with only high priority cargo
            uavCargo = ''; % list of all the cargo stored by UAVs 
            %lowUAVs = UAVDrone6.empty; % UAVs with only low priority cargo
            for c = 1:length(obj.uavList)
                % Only use UAVs with cargo, separate UAVs by type of cargo
                % available
                if(obj.uavList(c).idleCounter==0)
                    if ~isempty(obj.uavList(c).cargo)
                         UAVs(length(UAVs) + 1) = obj.uavList(c);
 
                    else 
                        % Empty UAV
                        obj.uavList(c).returnToBase();
                    end
                    
                end
                n = length(uavCargo);
                uavCargo(n + 1:n + length(obj.uavList(c).cargo)) = obj.uavList(c).cargo;
            end
            obj.containedCargo = uavCargo;
            numDrones = length(UAVs);
            requestList = Request6.empty;
            %obj.activeHi=0; % Reset counter
            % Collect the highest priority requests from each zone, and
            %   store them in an array requestList
            for c = 1:length(obj.requestZones)
                temp = obj.requestZones(c).getHighest(numDrones);
                if ~isempty(temp)
                    for k = 1:length(temp)            
                        requestList(length(requestList)+1)=temp(k);
                    end
                end
            end
            %
            % Sort and store requests
            %
            requestList = Manager6visual.sortRequests(requestList);
            obj.highReqs = requestList;
            if (~isempty(requestList))
                % Assign UAVs if there are requests
                  Manager6visual.chooseRequests(requestList,UAVs);
                  
            else
                % If no requests, send all drones to the base
                for c=1:length(UAVs)
                    UAVs(c).returnToBase;
                end
            end
            % Send unassigned UAVs to the base
            for c=1:length(UAVs)

                if(isempty(UAVs(c).request))
%                     disp('Empty request found')
                    %disp(obj.uavList(c))
                    %disp(obj.uavList(c).base.activeList)
                    UAVs(c).returnToBase;
                end
                
                % Have drones at the base wait for the next time step
                 
                if Distance(UAVs(c).position,UAVs(c).request.zone.position)<.1                    
                    
                    % Have drones at the base wait for the next time step
                    if UAVs(c).request.index == 'B'
                       
                       % disp(UAVs(c).position)
                        %disp(UAVs(c).request.zone.position)
                        UAVs(c).idleCounter = 1;
                    else
                        % Have drones assigned to a request at their current
                        % location instantly deliver and remove request
                        % from active list
                        UAVs(c).request.zone.remove(UAVs(c).request.index);
                        UAVs(c).deliver();
                        
                    end
                end
            end  
            for l = 1:length(obj.uavList)-1
                for k = 1:length(obj.uavList)-l
                    if obj.uavList(l).request.index ~= 'B'
                        if obj.uavList(l).request.exprTime == obj.uavList(l+k).request.exprTime
                            disp('Multiple UAVs assigned to the same request')
                        end
                    end
                end
            end
        end        
%            activeArray=cell(length(obj.requestZones),1);
%            for j = 1:length(obj.requestZones)
%                 activeArray{j} = obj.requestZones(j).activeList;
%            end
%            nextRequest = Manager6.chooseRequest(activeArray,uav);
%            request=nextRequest;    
%         end
    end

    
    methods (Static)
        %% Choose Requests function
        % Function to determine the optimum UAV destination
        % Inputs:   uav = the UAV to assign
        %           reqList = the requestList (a cell array)
        % Output:   unAssigUAV = the unassigned UAVs
        function unAssigUAV=chooseRequests(requestList,uavList) 
            cargos = ('XY');
            % Cell arrays for UAVs and Requests
            uavCell = cell(length(cargos),2);
            reqCell=cell(length(cargos),2);
            % Initialize cells
            for c=1:length(uavCell(:,1))
                uavCell{c,1} = UAVDrone6.empty;   % UAV 
                reqCell{c,1} = Request6.empty;    % Request array
            end
            % Sort UAVs by cargo using a cell array where each row
            % corresponds to a cargo type. The first column stores UAVs,
            % and the second stores the indexes in the uavList
            for c=1:length(cargos)
                for k=1:length(uavList)
                    if contains(uavList(k).cargo, cargos(c))
                        uavCell{c,1}(length(uavCell{c,1})+1)=uavList(k);
                        uavCell{c,2}(length(uavCell{c,2})+1)=k;
                    end
                end
            end
            
            % Sort requests by cargo type
            for c=1:length(cargos)
                for k=1:length(requestList)
                    if requestList(k).cargoType==cargos(c)
                        reqCell{c,1}(length(reqCell{c,1})+1)=requestList(k);
                        reqCell{c,2}(length(reqCell{c,2})+1)=k;
                    end
                end
            end
            % Initialize arrays for sorting
            reqMatches= cell(length(uavList),2); % Cell array of HD's and indexes to correspond to requests, sorted to correspond to UAVs
            % The first column is the humanitarian distance between a UAV and
            % request, where the row index represents the UAV's place in uavList and the
            % second column element represents the Request's location in
            % requestList
            for n=1:length(cargos)
                % CALCULATE HUMANITARIAN DISTANCES
                M = zeros(length(uavCell{n,1}), length(reqCell{n,1}));
                if ~isempty(M)
                    %   Create a matrix where element (r,c) corresponds to the HD
                    %   between uav(r) and request(c)
                    for r = 1:length(uavCell{n,1})
                        for c = 1:length(reqCell{n,1})
                             M(r, c) = HumanitarianDistance(reqCell{n,1}(c),uavCell{n,1}(r));                    
                        end
                    end

                    [minHDs, index] = min(M,[],1); % Determine which UAV's correspond to a minimum HD from each request
                    % An index value of 2 as the first element means that the
                    % first request's ideal assignment is the 2nd UAV
                    for r=1:length(index)
                        size = length(reqMatches{uavCell{n,2}(index(r)),1});
                        reqMatches{uavCell{n,2}(index(r)),1}(size+1) =minHDs(r);
                        reqMatches{uavCell{n,2}(index(r)),2}(size+1) =reqCell{n,2}(r);
                    end
                    
%                 else
%                     % If there are no requests and UAVs of this cargo type,
%                     % send UAVs with this cargo type to base
%                     for c=1:length(uavCell{n,2})
%                         uavList(uavCell{n,2}(c)).returnToBase;
%                         if uavList(uavCell{n,2}(c)).position==uavList(uavCell{n,2}(c)).base.position
%                             uavList(uavCell{n,2}(c)).idleCounter = 1;
%                         end
%                     end
%                 end
                end
            end
            cargoTest = 0;
            % Check if any compatible matches are availible
            for c=1:length(uavList)
                if ~isempty(reqMatches{c,1})
                    cargoTest=1;
                    break;
                end
            end
            
            
            % Initialize empty arrays
            unAssigUAV=UAVDrone6.empty; % Stores the UAV's that haven't been given requests yet
            hdArray=[]; % Array of humanitarian distances to compare
            %   reqArray=Request6.empty; % Array of requests for which the current UAV minimizes the HD
            assignedIndex=[]; % Stores the index of requests that have been assigned to UAV's
            listIndex = []; % Stores the index in requestList that corresponds to each element in reqArray
            if cargoTest == 1
                % FIND OPTIMUM ASSIGNMENTS
                % If only 1 UAV needs to be assigned, just find the minimum of
                %   the 1-D array of requests
                if ((length(uavList) == 1))                
                    % Assign the optimum to the UAV
                    [~,bestFit]=min(reqMatches{1,1});
                    bestInd = reqMatches{1,2}(bestFit); % The best index for the request
                    if isempty(requestList(bestInd))
                        disp('')
                    end
                    if (Manager6visual.checkTime(uavList(1),requestList(bestInd)))
                        if(Manager6visual.checkRange(uavList(1), requestList(bestInd)))
                            % Count redirected UAV's
                            if(~isempty(uavList(1).request)&& uavList(1).request.zone.ID~=requestList(bestInd).zone.ID&& uavList(1).request.index~='B')
                                uavList(1).manager.numRedirect = uavList(1).manager.numRedirect+1;
                            end
                            uavList.request = requestList(bestInd);
                        else
                            %disp('Not enough battery to reach')
                            uavList.returnToBase();
                        end
                    else % If cannot reach in time, assign to another request
                        unAssigReq = requestList;
                        for c=bestInd:length(requestList)-1
                           unAssigReq(c) = requestList(c+1);                           
                        end
                        unAssigReq = unAssigReq(1:(length(unAssigReq)-1));
                        Manager6visual.chooseRequests(unAssigReq,uavList);
                    end
                % If more than 1 UAV, find ideal UAV's for each Request and
                %   then choose the best request for each UAV to service
                else
                    for u=1:length(uavList)
   
                        % If no requests, the UAV is unassigned
                        if isempty(reqMatches{u,1})
                            unAssigUAV(length(unAssigUAV)+1)=uavList(u);
                        else
                            [~,bestFit]=min(reqMatches{u,1}); % Find the optimum request for each UAV
                            % Determine if the UAV can reach its request
                            % before it expires
                            if Manager6visual.checkTime(uavList(u),requestList(reqMatches{u,2}(bestFit)))
                                % Make sure the UAV has enough charge
                                if(Manager6visual.checkRange(uavList(u), requestList(reqMatches{u,2}(bestFit))))
                                    % Check for redirected UAV's
                                    if(~isempty(uavList(u).request)&& uavList(u).request.zone.ID~=requestList(reqMatches{u,2}(bestFit)).zone.ID)
                                        uavList(u).manager.numRedirect = uavList(u).manager.numRedirect+1;
                                    end
                                    % Assign request to UAV (1st col of reqMatches)
                                    uavList(u).request=requestList(reqMatches{u,2}(bestFit)); 
                                    % Store index of assigned request (2nd column of
                                    % reqMatches, bestFit item)
                                    assignedIndex(length(assignedIndex)+1)=reqMatches{u,2}(bestFit); 
                                else

                                    uavList(u).returnToBase();
                                end
                            else % If the UAV cannot reach in time
                                assignedIndex(length(assignedIndex)+1)=reqMatches{u,2}(bestFit); 
                                unAssigUAV(length(unAssigUAV)+1)=uavList(u);
%                                 disp('Cannot reach request')
                            end
                        end
                    end
                

                    % ASSIGN LEFTOVER DRONES
                    % Sort list of assigned indices into descending order to remove
                    % assigned requests from the list
                    assignedIndex=sort(assignedIndex,'descend'); 
                    unAssigReq = requestList; % Array to store the unassigned requests

                    % Remove assigned requests from the unassigned array
                    if length(requestList)==1 && ~isempty(assignedIndex)
                        unAssigReq = Request6.empty;
                    else
                        for c=1:length(assignedIndex)
                            for k=assignedIndex(c)+1:length(unAssigReq)
                                unAssigReq(k-1)=unAssigReq(k);
                            end
                            unAssigReq=unAssigReq(1:length(unAssigReq)-1);
                        end
                    end
                    % Call the chooseRequests function on the unassigned UAV's,
                    %   if there are still requests available
                    if(~isempty(unAssigUAV) && ~isempty(unAssigReq))
                        Manager6visual.chooseRequests(unAssigReq,unAssigUAV);
                    % Send extra UAV's to base if there are no more Requests
                    elseif(isempty(unAssigReq)&& ~isempty(unAssigUAV))                    
                        for c=1:length(unAssigUAV)
                            % Check for redirected UAV's
                            if(~isempty(unAssigUAV(c).request)&& unAssigUAV(c).request.zone.ID~=unAssigUAV(c).base.ID)
                                unAssigUAV(c).manager.numRedirect = unAssigUAV(c).manager.numRedirect+1;
                            end
                            % Assign the request
                            unAssigUAV(c).returnToBase();
                        end
                    end
                end
            else 
                for c = 1:length(uavList)
                    if ~isempty(uavList(c).request) && uavList(c).request.index ~= 'B'
                        uavList(c).manager.numRedirect = uavList(c).manager.numRedirect+1;
                    end
                        uavList(c).returnToBase();
                end
                
            end
            % Check for repeat requests
            obj = uavList(1).manager;
            for l = 1:length(obj.uavList)-1
                for k = 1:length(obj.uavList)-l
                    if ~isempty(obj.uavList(l).request)&& ~isempty(obj.uavList(l+k).request)
                        if obj.uavList(l).request.index ~= 'B'
                            if obj.uavList(l).request.exprTime == obj.uavList(l+k).request.exprTime
                                disp('Multiple UAVs assigned to the same request') % if this pops up then this is proof that DISNEY                             end
                            end
                        end
                    end
                end
            end
        end
        %% Additional Static Functions
        % Function to determine whether UAVs have the range to meet assignments
        function canReach = checkRange(uav, request)
                landingFuel = uav.speed * 1/12;
                uav2req = Distance(uav.position, request.zone.position);
                req2base = Distance(request.zone.position, uav.base.position);
                canReach = (uav2req + req2base + landingFuel + uav.rangeBuffer <= uav.rangeLeft);
        end
        % Function to determine if the UAV can reach the request in time,
        % returns a logical value
        function canReach = checkTime(uav,request)
            timeToReq = Distance(uav.position,request.zone.position)/uav.speed;
            timeLeft = request.exprTime-request.timeElapsed;
            canReach = (timeToReq<timeLeft);
        end
            
            
            
            % This is where we sort the list in order to get
            % the highest priority requests
        function sortedList = sortRequests(requestList)
                sortedList = Request6.empty;
                temp = zeros(length(requestList), 2);
                for n = 1:length(requestList)
                    temp(n, 1) = requestList(n).priority;
                    temp(n, 2) = n;
                end
                sortedTemp = sortrows(temp, 'descend');
                for n = 1:length(requestList)
                    sortedList(n, 1) = requestList(sortedTemp(n, 2)); 
                end
        end
    end
end