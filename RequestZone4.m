%% RequestZone object class
classdef RequestZone4 < handle
    %RequestZone  class to simulate requests for aid in the UAV simulation
        % Stores location, probability of requests, probability of high/low
        % priority, time needed to fulfill requests, etc.
        % This version is a handle class.
    properties
        position    % The location of the drop zone
        activeList  % List of the currently active requests in that zone
        probNew     % Probability of the new request
        probHi      % Probability of a high priority request
        expired     % Number of expired requests
        numUnassigned % Number of unassigned requests
        manager;    % The manager that assigns to the drone
        exprTime    % The time at which high priority requests expire
        priFac      % The priority factor
        ID          % The Request zone ID number
    end
    
    
    methods
        % Constructor 
        % This tells what the position of the request is. It also tells
        % what the probability of a new request is and what the probability
        % of a high priority request is
        function obj = RequestZone4(pos,probNew,probHi,exprTime,ID)
            obj.position = pos;
            obj.probNew = probNew;
            obj.probHi = probHi;
            obj.activeList=Request4.empty;
            obj.expired = 0;
            obj.numUnassigned = 0;
            obj.manager=Manager4.empty;
            obj.exprTime = exprTime;
            obj.priFac = 0;
            obj.ID = ID;
        end
        
        % Refresh function to be called every few hours
        % The function randomly tests to see if the request is of high
        % priority or low priority and adds it to the list
        function refresh(obj,time)
            % Refresh the all active requests
            p = 1;
            n = length(obj.activeList);
            while (p <= length(obj.activeList))
                if(obj.activeList(p).status > 0)
                    obj.activeList(p).refresh(time);
                end
                if (n == length(obj.activeList))
                p = p + 1;
                else 
                    n = length(obj.activeList);
                end
            end
            a1=rand;
            a2=rand;    
            % Generate a new request based on the probabilities of new
            % requests and high priority requests
            if(a1<obj.probNew)
                if(a2<obj.probHi)
                    priority=1;
                else
                    priority = obj.priFac;
                end
                newreq = Request4(time,priority, obj,obj.exprTime,length(obj.activeList)+1);
                obj.activeList(newreq.index) = newreq;
            end
         obj.numUnassigned = obj.getUnassigned();
        end
        
        % Function to remove the request from the active list upon completion
        % This is a homemade way of removing the request from the 
        % active list so it will not be attempted twice
        function remove(obj, index)
            n = length(obj.activeList);
            % Check that the index is less than the list length and that
            % the list has more than one value
            if(n>index && n>1)
               for c = index:n-1   
                    obj.activeList(c) = obj.activeList(c+1);
                    obj.activeList(c).index = c;
               end
                    obj.activeList = obj.activeList(1:n-1);
                elseif(n<=1)
                % Remove the only element in a list
                   obj.activeList = Request4.empty;
                elseif(index == n)
                % Remove the last element(if necessary)
                    obj.activeList=obj.activeList(1:n-1);
            
            end
                
                
        end               
        % Function to return the number of unassigned requests
        function c = getUnassigned(obj)
            c = 0;
            for i = 1:length(obj.activeList)
                if (obj.activeList(i).status == 2)
                    c = c+1;
                end
            end
        end
        
        % Function to reset the zone at the beginning of a simulation
        function reset(obj)
            obj.activeList=Request4.empty;
            obj.expired = 0;
            obj.numUnassigned = 0;
            obj.manager=Manager4.empty;
        end
        
        % This function is made to get the highest priority requests from
        % the request zone. The number of requests returned equals the number of UAV's in the fleet  
        function requests = getHighest(obj, numUAV)
            P = zeros(length(obj.activeList), 2);
            sortedRequests=Request4.empty;
            for j = 1:length(obj.activeList)
                P(j, :) = [obj.activeList(j).priority * 0.95 ^ (obj.activeList(j).timeElapsed), j];  
            end
              sortedP = sortrows(P, 1);
                for c = 1: length(obj.activeList)
                sortedRequests(c) = obj.activeList(sortedP(c, 2)); 
                sortedRequests(c).index=c;
                
                end
                if isempty(sortedRequests)
                    requests=sortedRequests;
                else
                obj.activeList=sortedRequests;
                if(numUAV<length(sortedRequests))
                    requests = sortedRequests(1:numUAV);
                else
                    requests=sortedRequests;
                end
                end
        end
    end
end
