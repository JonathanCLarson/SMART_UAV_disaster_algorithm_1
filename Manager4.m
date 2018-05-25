%%  Manager1
% Jonathan Larson and Gabe Flores
% manages tests for the driver class
%   Assigns UAV's to deliver supplies to request zones, and refreshes the
%   status of the fleet
% 5/10/2018

classdef Manager4 < handle
    
    properties
        requestZones % list of the request zones
        completedList % List of requests to assign to UAV's
        uavList % List of uav's in the fleet
        time % Stores the current time
        base % the base for the UAV's 
        requestsMet % to keep track of the requests met
        expired % Counts the number of expired requests
        numRedirect % Count the number of times UAV's were redirected
    end
    methods
        % Constructor, initialize index to 1 to assign first request
        % Initializes the time at 0, starts off with an empty drone list,
        % and gets the request zones and the base
        
        function obj = Manager4(zones, base)
            obj.requestZones = zones;
            obj.time=0;
            obj.uavList=UAVDrone4.empty;
            obj.base = base;
            obj.completedList=Request4.empty;
            obj.requestsMet = 0;
            obj.expired = 0;
            obj.numRedirect = 0;
        end
        % Adds uav to the manager's list of uav's 
        function addUAV(obj, uav)
            obj.uavList(length(obj.uavList) + 1, 1)=uav;
        end
            
       % Function to refresh the UAV's and requests
        function refresh(obj, time)
            obj.time=time;
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
            obj.expired = 0;
            for i=1:length(obj.requestZones)
                obj.expired = obj.expired + obj.requestZones(i).expired;
            end
       end
        
       
        % Assignment function, which can also set the status of the request 
        %   Output: the request assignment for the UAV
        function assign(obj)
            % Create an array of UAV's that are available to be assigned            
            j = 1;
            droneList=UAVDrone4.empty;
            for c = 1:length(obj.uavList)
                if(obj.uavList(c).cargo ~= 0&& obj.uavList(c).idleCounter==0)
                    droneList(j) = obj.uavList(c);
                    j = j + 1;
                end
            end
            
            requestList = Request4.empty;
            n=1;
            % Collect the highest priority requests from each zone
            for c = 1:length(obj.requestZones)
                temp = obj.requestZones(c).getHighest(length(droneList));
                if ~isempty(temp)
                    for k = 1:length(temp)            
                        requestList(n) = temp(k);
                        n  = n + 1;
                    end
                end
            end
            if (~isempty(requestList))
                % Call chooseRequests() to assign requests to UAV's
                Manager4.chooseRequests(requestList,droneList);
                % disp(droneList)
            
                % Check that each drone has enough power left to reach the
                % request
                for c=1:length(droneList)
                   % droneList(c).checkFuel();
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
        % Function to determine the optimum UAV destination
        % Inputs:   uav = the UAV to assign
        %           reqList = the requestList (a cell array)
        % Output:   req = the selected request
        function chooseRequests(requestList,uavList) 

            
            M = zeros(length(uavList), length(requestList));
            % disp(M)
            % disp(uavList)
            % disp(requestList)
            for r = 1:length(uavList)
                for c = 1:length(requestList)
                     M(r, c) = HumanitarianDistance(requestList(c),uavList(r));
                    %M(r, c) = Distance(requestList(c).zone.position,uavList(r).position);
                    
                end
              
            end
            %disp(M)
            [~, index] = min(M); % Determine which UAV's correspond to a minimum HD from each request
            
            % Assign optimum requests to each UAV
            unAssigUAV=UAVDrone4.empty; % Stores the UAV's that haven't been given requests yet
            hdArray=[]; % Array of humanitarian distances to compare
            reqArray=Request4.empty; % Array of requests for which the current UAV minimizes the HD
            assignedIndex=[]; % Stores the index of requests that have been assigned to UAV's
            listIndex = []; % Stores the index in requestList that corresponds to each element in reqArray
            if(length(uavList) == 1)
                 % Count redirected UAV's
                 if(~isempty(uavList(1).request)&& uavList(1).request.zone.ID~=requestList(index).zone.ID)
                            uavList(1).manager.numRedirect = uavList(1).manager.numRedirect+1;
                 end
                uavList.request = requestList(index);
            else
                for u=1:length(uavList)
                    for i=1:length(index)
                        if index(i)==u
                            % build an array of the requests for which the 
                            % current UAV is the closest and the HD between
                            % that request and the UAV
                            reqArray(length(reqArray)+1)=requestList(i); % Request object array
                            % Calculate Humanitarian Distances
                            hdArray(length(hdArray)+1)=HumanitarianDistance(requestList(i),uavList(u));
                            %hdArray(length(hdArray)+1)=Distance(requestList(i).zone.position,uavList(u).position);
                            listIndex(length(listIndex)+1)=i;
                        end
                    
                    end
                    if isempty(reqArray)
                        unAssigUAV(length(unAssigUAV)+1)=uavList(u);
                    else
                    [~,bestFit]=min(hdArray); % Find the optimum UAV assignment
                    
                    if(~isempty(uavList(u).request)&& uavList(u).request.zone.ID~=reqArray(bestFit).zone.ID)
                            uavList(u).manager.numRedirect = uavList(u).manager.numRedirect+1;
                    end
                    uavList(u).request=reqArray(bestFit); % Assign request to UAV
                    assignedIndex(length(assignedIndex)+1)=listIndex(bestFit);                
                    % RESET arrays before moving to next UAV
                    reqArray=Request4.empty;
                    hdArray=[];
                    end
                end
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

                % Call the chooseRequests function on the unassigned UAV's, if necessary 
                if(~isempty(unAssigUAV)&&~isempty(unAssigReq))
                    Manager4.chooseRequests(unAssigReq,unAssigUAV);
                elseif(isempty(unAssigReq)&& ~isempty(unAssigUAV))
                    % Send extra drones to base
                    for c=1:length(unAssigUAV)
                        % Check for redirected UAV's
                        if(~isempty(unAssigUAV(c).request)&& unAssigUAV.request.zone.ID~=unAssigUAV(c).base.ID)
                            unAssigUAV(c).manager.numRedirect = unAssigUAV(c).manager.numRedirect+1;
                        end
                        unAssigUAV(c).request=unAssigUAV(c).base.activeList;

                    end
                end
            end 
            
%             k=1;
%             
%             for c=1:length(reqList)
%                 
%                 for j = 1:length(reqList{c})
%                     temp = reqList{c};
%                     % Create a list of requests to choose from
%                     chooseList(k)= temp(j);
%                     % The Humanitarian distance function version
%                     % This version makes use of the humanitarian distance
%                     % function in order to show how the UAV behaves when
%                     % commanded to go to the high priority requests first
%                     dist(k)= HumanitarianDistance(chooseList(k),uav);
%                     % The Standard distance function version
%                     % This version will get the requests based on the zones
%                     % that they are in regardless of priority
%                     %dist(k) = Distance(chooseList(k).zone.position,uav.position);
%                     k=k+1;
%                 end
%             end
%             
%             if k==1
%                 %% disp("No unassigned requests")
%                 req = uav.base.activeList;
%                 if(Distance(uav.position,req.zone.position)<.001)
%                     uav.idleCounter = 3;
%                 end
%             else
%                 [~,index]=min(dist);
%                 req=chooseList(index);
%             end         
            
        end
    end
    
end