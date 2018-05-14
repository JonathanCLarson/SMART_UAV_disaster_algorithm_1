%% RequestZone object class
classdef RequestZone < handle
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
        manager;
    end
    
    methods
        % Constructor 
        % This tells what the position of the request is. It also tells
        % what the probability of a new request is and what the probability
        % of a high priority request is
        function obj = RequestZone(pos,probNew,probHi)
            obj.position = pos;
            obj.probNew = probNew;
            obj.probHi = probHi;
            obj.requestList=Request.empty;
            expired = 0;
            numUnassigned = 0;
            manager=Manager1.empty;
        end
        
        % Refresh function to be called every few hours
        % The function randomly tests to see if the request is of high
        % priority or low priority and adds it to the list
        function refresh(obj,time)
            if(rand<obj.probNew)
                if(rand<obj.probHi)
                    priority=1;
                else
                    priority=1000;
                end
                newreq = Request(time,priority, obj);
                obj.requestList(length(obj.requestList)+1) = newreq;
                    
               obj.manager.requestList(length(obj.manager.requestList)+1) = newreq; 
            end
         obj.numUnassigned = obj.getUnassigned();
        end
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

