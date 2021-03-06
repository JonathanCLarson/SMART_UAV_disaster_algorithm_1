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
        completed   % The number of completed requets
        manager;    % The manager that assigns to the drone
        exprTime    % The time at which high priority requests expire
        waitTime    % The amount of time requests have waited for aid
        waitTimeHi  % The amount of time high priority requests have waited
        priFac      % The priority factor
        timeFac     % The time factor (how requests gain importance over time)
        ID          % The Request zone ID number, equals the zone's index in the manager's requestZones list
        
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
            obj.completed = 0;
            obj.waitTime = 0;
            obj.waitTimeHi = 0;
            obj.manager=Manager4.empty;
            obj.exprTime = exprTime;
            obj.priFac = 1;
            obj.timeFac = 1;
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
            a1=rand; % Random number for new requests
            b1=rand; % Random number for high priority requests
            numNew=0; % number of new requests to add
            % Generate a new request based on the probabilities of new
            % requests and high priority requests
            priority = obj.priFac;
            newHi = 0;
            % Determine the number of requests to add using random numbers
            %   and the probability of new requests
            while(a1<obj.probNew)
                numNew=numNew+1;
                a1=rand;
            end
            % Create new requests
            for c=1:numNew                
                if(b1<obj.probHi)
                    priority=1;
                    newHi=1;
                end
                expTime = obj.exprTime+randn*(1/6);
                if expTime<0
                    expTime=0;
                end
                newreq = Request4(time,priority,obj.timeFac, obj,expTime,length(obj.activeList)+1);
                obj.activeList(newreq.index) = newreq;
                priority=obj.priFac;
            end
            obj.numUnassigned = obj.getUnassigned();
            % Call the assign function if a new high priority request was
            % generated
            if newHi == 1
                obj.manager.assign();
            end
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

