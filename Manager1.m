%%  Manager1
% Jonathan Larson and Gabe Flores
% manages tests for the driver class
%   Assigns UAV's to deliver supplies to request zones, and refreshes the
%   status of the fleet
% 5/10/2018

classdef Manager1 < handle
    
    properties
        requestZones % list of the request zones
        requestList % List of requests to assign to UAV's
        uavList % List of uav's in the fleet
        time % Stores the current time
        base % the base for the UAV's 
        requestsMet % to keep track of the requests met
        expired % Counts the number of expired requests
    end
    methods
        % Constructor, initialize index to 1 to assign first request
        % Initializes the time at 0, starts off with an empty drone list,
        % and gets the request zones and the base
        
        function obj = Manager1(zones, base)
            obj.requestZones = zones;
            obj.time=0;
            obj.uavList=UAVDrone1.empty;
            obj.base = base;
            obj.requestList=Request1.empty;
            obj.requestsMet = 0;
            obj.expired = 0;
            % Create the requestList
            i=1; % Index counter
            % Loop through each request zone and combine all requests into
            % one list
            for c=1:length(obj.requestZones)
                obj.requestZones(c).manager=obj; % Assign the manager to each zone
                for k=1:length(obj.requestZones(c).requestList)
                    obj.requestList(i)=obj.requestZones(c).requestList(k);
                    i=i+1;
                end
            end
        end
        % Adds uav to the manager's list of uav's 
        function addUAV(obj, uav)
            obj.uavList(length(obj.uavList) + 1)=uav;
        end
            
       % Function to refresh the UAV's and requests
       function refresh(obj, time)
            for c=1:length(obj.uavList)
                obj.uavList(c).refresh(time);
                
            end
            for k=1:length(obj.requestZones)
                obj.requestZones(k).refresh(time);
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
        function request = assign(obj)
            % Counter variables
            c = 1;
            assigned = 0; % the request starts off unassigned
            % Find the first unassigned request
            while (c <= length(obj.requestList))
                if (obj.requestList(c).status > 1)
                        nextRequest = obj.requestList(c);
                        assigned = 1;
                        % exit the loop by skipping to the end
                        c = length(obj.requestList);
                end
               c = c + 1;
            end
            % Check for if a request was assigned
            % if the request is assigned, it will change the status so the drones do not attend to it
            if(assigned==1) % if the request is assigned, it will change the status so the drones do not attend to it
                request=nextRequest;
                request.status=1;
            else 
                request = obj.base.requestList(1);
                disp("No new requests")
            end
        end
        
        
        
    end
    
end