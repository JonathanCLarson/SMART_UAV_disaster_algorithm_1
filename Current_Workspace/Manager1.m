%%  Manager1
% Jonathan Larson and Gabe Flores
% manages tests for the driver class
% 5/10/2018

classdef Manager1 < handle
    
    properties
        requestZones % list of the request zones
        requestList % List of requests to assign to UAV's
        uavList % List of uav's in the fleet
        time % Stores the current time
        base % the base for the UAV's 
    end
    methods
        % Constructor, initialize index to 1 to assign first request
        % Initializes the time at 0, starts off with an empty drone list,
        % and gets the request zones and the base
        
        function obj = Manager1(zones, base)
            obj.requestZones = zones;
            obj.time=0;
            obj.uavList=UAVDrone.empty;
            obj.base = base;
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
                requestZone(k).refresh(time);
            end                
        end
        % Assignment function, which can also set the status of the request 
        function request = assign(manager)
            c = 1;
            k = 1;
            assigned = 0; % the request starts off unassigned
            while (c <= length(manager.requestZones))
                while (k <= length (manager.requestZones(c).requestList))
                    if (manager.requestZones(c).requestList(k).status > 1)
                    nextRequest = manager.requestZones(c).requestList(k);
                    assigned = 1;
                    % exit the loop by skipping to the end
                    k = length(manager.requestZones(c).requestList);
                    c = length(manager.requestZones);
                    end
                    k=k+1;
                    
                end
               c = c + 1;
            end
            if(assigned==1) % if the request is assigned, it will change the status so the drones can attend to it
                request=nextRequest;
                request.status=1;
            else 
                request = manager.base.requestList(1);
            end
        end
        
    end
    
end

            


