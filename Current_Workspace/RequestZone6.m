%% RequestZone object class
classdef RequestZone6 < handle
    %RequestZone  class to simulate requests for aid in the UAV simulation
        % Stores location, probability of requests, probability of high/low
        % priority, time needed to fulfill requests, etc.
        % This version is a handle class.
    properties
        position    % The location of the drop zone
        activeList  % List of the currently active requests in that zone
        probX       % Probability of the new A request
        probY       % Probability of a B request
        expired     % Number of expired requests
        numUnassigned % Number of unassigned requests
        completed   % The number of completed requets
        manager    % The manager that assigns to the drone
        exprTimeX   % The average time at which A requests expire
        exprTimeY   % The average time at which B requests expire
        waitTime    % The amount of time requests have waited for aid (COMPLETED/EXPIRED ONLY)
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
        function obj = RequestZone6(pos,probX,probY,exprTimeX, exprTimeY, ID)
            obj.position = pos;
            obj.probX = probX;
            obj.probY = probY;
            obj.activeList=Request6.empty;
            obj.expired = 0;
            obj.numUnassigned = 0;
            obj.completed = 0;
            obj.waitTime = 0;
            obj.waitTimeHi = 0;
            obj.manager=Manager6.empty;
            obj.exprTimeX = exprTimeX;
            obj.exprTimeY = exprTimeY;
            obj.priFac = 1;
            obj.timeFac = 1;
            obj.ID = ID;
        end
        
        % Refresh function to be called every few hours
        % The function randomly tests to see if the request is of high
        % priority or low priority and adds it to the list
        function refresh(obj,time)
            x1=rand; % Random number for new A requests
            y1=rand; % Random number for new B requests
            % Generate a new request based on the probabilities of new
            % requests and high priority requests
            priority = obj.priFac;
            newHi = 0;
            % Determine the number of requests to add using random numbers
            %   and the probability of new requests
            while(x1<obj.probX)
                 % Create an X request
                exprTime = obj.getExpire('X');
                if(exprTime <= 1)
                    newHi = 1;
                end
                newreq = Request6(time, obj.manager.priFac,obj.manager.timeFac, obj,exprTime,'X',length(obj.activeList)+1);
                obj.activeList(newreq.index) = newreq;
                x1=rand;
                
            end
            while(y1<obj.probY)
                exprTime = obj.getExpire('Y');
                if(exprTime <= 1)
                    newHi = 1;
                end
                newreq = Request6(time, obj.manager.priFac,obj.manager.timeFac, obj,exprTime,'Y',length(obj.activeList)+1);
                obj.activeList(newreq.index) = newreq;
                y1=rand;
            end
            obj.numUnassigned = obj.getUnassigned();
            % Refresh the all active requests
            p = 1;
            n = length(obj.activeList);
            while (p <= length(obj.activeList))
                if(obj.activeList(p).status > 0)
                    obj.activeList(p).refresh(time);
                else
                    disp('Old request found')
                    obj.remove(obj.activeList(p).index);
                end
                if (n == length(obj.activeList))
                p = p + 1;
                else
                    n = length(obj.activeList);
                end
            end
            % Call the assign function if a new high priority request was
            % generated
            if newHi > 0
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
                obj.activeList = Request6.empty;
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
            obj.activeList=Request6.empty;
            obj.expired = 0;
            obj.numUnassigned = 0;
            obj.manager=Manager6.empty;
        end
        
        %% This function is made to get the highest priority requests from
        % the request zone. The number of requests returned equals the number of UAV's in the fleet  
        function requests = getHighest(obj, numUAV)
            P = zeros(length(obj.activeList), 2); % Stores priority
            sortedRequests=Request6.empty;
            for j = 1:length(obj.activeList)
                P(j, :) = [obj.activeList(j).priority, j];  
            end
            sortedP = sortrows(P, 1);
            for c = 1: length(obj.activeList)
                sortedRequests(c) = obj.activeList(sortedP(c, 2));
                if sortedRequests(c).status<2 || sortedRequests(c).index<1
                    disp('OLD REQUEST FOUND')
                end
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
        %% Find the expiration time for a given request
        function exprTime = getExpire(obj, type)
            p=rand; % uniform random number (0-1)
            % Type X requests
            if(type == 'X')
                exprTime = (obj.exprTimeX.*(p.^(1/4)))./((1-p).^(1/4));
            else
                % Type Y
                 exprTime = (obj.exprTimeY.*(p.^(1/4)))./((1-p).^(1/4)); 
            end
    end
            
    end
end

