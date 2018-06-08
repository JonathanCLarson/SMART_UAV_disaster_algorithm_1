%%  Manager1
% Jonathan Larson and Gabe Flores
% Fleet manager to direct the UAV fleet and coordinate with requests from
% the request zones.
%   Assigns UAV's to deliver supplies to request zones, and refreshes the
%   status of the fleet
% 5/10/2018

classdef Manager4 < handle
    
    properties
        requestZones    % list of the request zones
        completedList   % List of requests to assign to UAV's
        expiredList     % List of expired requests
        uavList         % List of uav's in the fleet
        time            % Stores the current time
        base            % the base for the UAV's
        requestsMet     % to keep track of the requests met
        expired         % Counts the number of expired requests
        numRedirect     % Count the number of times UAV's were redirected
        probCrash       % The probability of a UAV crashing each time step
        activeHi        % Number of high priority requests 
    end
    methods
        % Constructor, initialize index to 1 to assign first request
        % Initializes the time at 0, starts off with an empty drone list,
        % and gets the request zones and the base
        
        function obj = Manager4(zones, base)
            obj.requestZones = zones;
            obj.time = 0;
            obj.uavList = UAVDrone4.empty;
            obj.base = base;
            obj.completedList = Request4.empty;
            obj.expiredList = Request4.empty;
            obj.requestsMet = 0;
            obj.expired = 0;
            obj.numRedirect = 0;
            obj.probCrash=0;
            obj.activeHi=0;
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
                obj.uavList=UAVDrone4.empty;                
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
                    disp('RIP :(')
                    disp(obj.time)
                    disp(obj.uavList(c).rangeLeft)
                end
                if rand<obj.probCrash
                    obj.byebye(c);
                end
            end
        end
        
       %% Assign Function
        % Assignment function, which can also set the status of the request 
        %   Output: the request assignment for the UAV
        function assign(obj)
            % Create an array of UAV's that are available to be assigned
            hiUAVs = UAVDrone4.empty; % UAVs with only high priority cargo
            loUAVs = UAVDrone4.empty; % UAVs with only low priority cargo
            for c = 1:length(obj.uavList)
                % Only use UAVs with cargo, separate UAVs by type of cargo
                % available
                if(obj.uavList(c).idleCounter==0)
                    if(contains(obj.uavList(c).cargo,'H'))
                        hiUAVs(length(hiUAVs)+1)=obj.uavList(c);                        
                    elseif contains(obj.uavList(c).cargo,'L')
                        loUAVs(length(loUAVs)+1)=obj.uavList(c);                        
                    end
                end
            end
            numDrones = length(loUAVs)+length(hiUAVs)+length(fullUAVs);
%             requestList = Request4.empty;
            highReqs = Request4.empty; % Array of high priority requests
            lowReqs = Request4.empty; % Array of low priority requests
            obj.activeHi=0; % Reset counter
            % Collect the highest priority requests from each zone, and
            %   store them in an array requestList
            for c = 1:length(obj.requestZones)
                temp = obj.requestZones(c).getHighest(numDrones);
                if ~isempty(temp)
                    for k = 1:length(temp)            
                        if temp(k).priority==1
                            obj.activeHi=obj.activeHi+1;
                            highReqs(length(highReqs)+1)=temp(k);
                        else
                            lowReqs(length(lowReqs)+1)=temp(k);
                        end
                    end
                end
            end
            
            if (~isempty(highReqs)|| ~isempty(lowReqs))
                
                % Call chooseRequests() to assign high priority requests to UAV's
                %   Leftover UAVs are returned    
                if (~isempty(highReqs)&& ~isempty(hiUAVs))
                    leftoverUAVs =Manager4.chooseRequests(highReqs,hiUAVs);
                    for c=1:length(leftoverUAVs)
                        if contains(leftoverUAVs(c).cargo,'L')
                            lowUAVs(length(lowUAVs)+1)=leftoverUAVs(c);
                        end
                    end
                end
                if (~isempty(lowReqs)&&~isempty(loUAVs))
                    Manager4.chooseRequests(lowReqs,loUAVs);
                end
            else
                % If no requests, send all drones to the base
                for c=1:length(droneList)
                    droneList(c).request=droneList(c).base.activeList;
                    % Have drones at the base wait for the next time step
                    if Distance(droneList(c).position,droneList(c).request.zone.position)<.0001
                        droneList(c).idleCounter=1;
                    end
                end
            end
            
            
        end        
%            activeArray=cell(length(obj.requestZones),1);
%            for j = 1:length(obj.requestZones)
%                 activeArray{j} = obj.requestZones(j).activeList;
%            end
%            nextRequest = Manager4.chooseRequest(activeArray,uav);
%            nextRequest.status=1;
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

            % CALCULATE HUMANITARIAN DISTANCES
            M = zeros(length(uavList), length(requestList));
            % Create a matrix where element (r,c) corresponds to the HD
            %   between uav(r) and request(c)
            for r = 1:length(uavList)
                for c = 1:length(requestList)
                     M(r, c) = HumanitarianDistance(requestList(c),uavList(r));                    
                end
            end

            [~, index] = min(M); % Determine which UAV's correspond to a minimum HD from each request
            
            % Initialize empty arrays
            unAssigUAV=UAVDrone4.empty; % Stores the UAV's that haven't been given requests yet
            hdArray=[]; % Array of humanitarian distances to compare
            reqArray=Request4.empty; % Array of requests for which the current UAV minimizes the HD
            assignedIndex=[]; % Stores the index of requests that have been assigned to UAV's
            listIndex = []; % Stores the index in requestList that corresponds to each element in reqArray
            
            % FIND OPTIMUM ASSIGNMENTS
            % If only 1 UAV needs to be assigned, just find the minimum of
            %   the 1-D array of requests
            if(length(uavList) == 1)
                 % Count redirected UAV's
                 if(~isempty(uavList(1).request)&& uavList(1).request.zone.ID~=requestList(index).zone.ID)
                            uavList(1).manager.numRedirect = uavList(1).manager.numRedirect+1;
                 end
                % Assign the optimum to the UAV
                uavList.request = requestList(index);
                
            % If more than 1 UAV, find ideal UAV's for each Request and
            %   then choose the best request for each UAV to service
            else
                for u=1:length(uavList)
                    for i=1:length(index)
                        if index(i)==u
                            % Build an array of the requests for which the 
                            %   current UAV is the closest and the HD between
                            %   that request and the UAV
                            reqArray(length(reqArray)+1)=requestList(i); % Request object array
                            % Calculate Humanitarian Distances
                            hdArray(length(hdArray)+1)=HumanitarianDistance(requestList(i),uavList(u));
                            %hdArray(length(hdArray)+1)=Distance(requestList(i).zone.position,uavList(u).position);
                            listIndex(length(listIndex)+1)=i;
                        end
                    
                    end
                    % If no requests, all UAV's are unassigned
                    if isempty(reqArray)
                        unAssigUAV(length(unAssigUAV)+1)=uavList(u);
                    else
                    [~,bestFit]=min(hdArray); % Find the optimum UAV for each Request
                    % Check for redirected UAV's
                    if(~isempty(uavList(u).request)&& uavList(u).request.zone.ID~=reqArray(bestFit).zone.ID)
                            uavList(u).manager.numRedirect = uavList(u).manager.numRedirect+1;
                    end
                    % Assign request to UAV
                    uavList(u).request=reqArray(bestFit); 
                    % Store index of assigned request
                    assignedIndex(length(assignedIndex)+1)=listIndex(bestFit);                
                    % RESET arrays before moving to next UAV
                    reqArray=Request4.empty;
                    hdArray=[];
                    end
                end
                
                % ASSIGN LEFTOVER DRONES
                % Sort list of assigned indices into descending order to remove
                % assigned requests from the list
                assignedIndex=sort(assignedIndex,'descend'); 
                unAssigReq = requestList; % Array to store the unassigned requests

                % Remove assigned requests from the unassigned array
                for c=1:length(assignedIndex)
                    for k=assignedIndex(c)+1:length(unAssigReq)
                            unAssigReq(k-1)=unAssigReq(k);
                    end
                    unAssigReq=unAssigReq(1:length(unAssigReq)-1);
                end

                % Call the chooseRequests function on the unassigned UAV's,
                %   if there are still requests available
                if(~isempty(unAssigUAV)&&~isempty(unAssigReq))
                    Manager4.chooseRequests(unAssigReq,unAssigUAV);
                    
                % Send extra UAV's to base if there are no more Requests
                elseif(isempty(unAssigReq)&& ~isempty(unAssigUAV))                    
                    for c=1:length(unAssigUAV)
                        % Check for redirected UAV's
                        if(~isempty(unAssigUAV(c).request)&& unAssigUAV(c).request.zone.ID~=unAssigUAV(c).base.ID)
                            unAssigUAV(c).manager.numRedirect = unAssigUAV(c).manager.numRedirect+1;
                        end
                        % Assign the request
                        unAssigUAV(c).request=unAssigUAV(c).base.activeList;

                    end
                end
            end 
                       
        end
    end
    
end