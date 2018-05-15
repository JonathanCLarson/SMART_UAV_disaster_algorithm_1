%% RequestZone object class
classdef RequestZone1 < handle
    %RequestZone  class to simulate requests for aid in the UAV simulation
        % Stores location, probability of requests, probability of high/low
        % priority, time needed to fulfill requests, etc.
        % This version is a handle class.
    properties
        position % The location of the drop zone
        requestList % List of the currently active requests in that zone
        probNew % Probability of the new 
        probHi % Probability of a high priority request
        expired % Number of expired requests
        numUnassigned% Number of unassigned requests
        manager; % The manager that assigns to the drone
        expTime % The time at which high priority requests expire
    end
    
    methods
        % Constructor 
        % This tells what the position of the request is. It also tells
        % what the probability of a new request is and what the probability
        % of a high priority request is
        function obj = RequestZone1(pos,probNew,probHi,expTime)
            obj.position = pos;
            obj.probNew = probNew;
            obj.probHi = probHi;
            obj.requestList=Request1.empty;
            obj.expired = 0;
            obj.numUnassigned = 0;
            obj.manager=Manager1.empty;
            obj.expTime = expTime;
            
        end
        
        % Refresh function to be called every few hours
        % The function randomly tests to see if the request is of high
        % priority or low priority and adds it to the list
        function refresh(obj,time)
            for c=1:length(obj.requestList)
                if(obj.requestList(c).status>0)
                    obj.requestList(c).refresh(time);
                end
            end
            if(rand<obj.probNew)
                if(rand<obj.probHi)
                    priority=1;
                else
                    priority=1000;
                end
                newreq = Request1(time,priority, obj,obj.expTime);
                obj.requestList(length(obj.requestList)+1) = newreq;
                    
               obj.manager.requestList(length(obj.manager.requestList)+1) = newreq; 
            end
         obj.numUnassigned = obj.getUnassigned();
        end
        
        % Function to return the number of unassigned 
        function c = getUnassigned(obj)
            c = 0;
            for i = 1:length(obj.requestList)
                if (obj.requestList(i).status == 2)
                    c = c+1;
                end
            end
        end
    end
end

