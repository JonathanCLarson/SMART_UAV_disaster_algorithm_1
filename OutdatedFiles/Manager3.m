%%  Manager1
% Jonathan Larson and Gabe Flores
% manages tests for the driver class
%   Assigns UAV's to deliver supplies to request zones, and refreshes the
%   status of the fleet
% 5/10/2018

classdef Manager3 < handle
    
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
        
        function obj = Manager3(zones, base)
            obj.requestZones = zones;
            obj.time=0;
            obj.uavList=UAVDrone3.empty;
            obj.base = base;
            obj.requestList=Request3.empty;
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
        function request = assign(obj,uav)
           nextRequest = Manager3.chooseRequest(obj.requestList,uav);
           nextRequest.status=1;
           request=nextRequest;    
        end
    end
    
    methods (Static)
        % Function to determine the optimum UAV destination
        % Inputs:   uav = the UAV to assign
        %           reqList = the requestList
        % Output:   req = the selected request
        function req = chooseRequest(reqList,uav) 
            k=1;
            
            for c=1:length(reqList)
                if(reqList(c).status==2)
                    % Create a list of requests to choose from
                    chooseList(k)=reqList(c);
                    % The Humanitarian distance function version
                    % This version makes use of the humanitarian distance
                    % function in order to show how the UAV behaves when
                    % commanded to go to the high priority requests first
                    dist(k)= HumanitarianDistance(chooseList(k),uav);
                    % The Standard distance function version
                    % This version will get the requests based on the zones
                    % that they are in regardless of priority
                    %dist(k) = Distance(chooseList(k).zone.position,uav.position);
                    k=k+1;
                end
            end
            
            if k==1
                %disp("No unassigned requests")
                req = uav.base.requestList(1);
            else
                [~,index]=min(dist);
                req=chooseList(index);
            end         
            
        end
    end
    
end