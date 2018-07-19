%% Request object class
classdef Request6 < handle
    %Request  class to simulate requests for aid in the UAV simulation
        % Stores priority, time needed to fulfill requests, etc.
        % This version is a handle class.
    properties
        timeRequested   % when the request was made
        timeElapsed     % time since the request was made
        priority        % Value to scale Humanitarian Distance based on request priority
        priFac          % Maximum priority value
        timeFac         % Half-life of the priority function (how long it takes for the priority to double)
        status          % 2 if unassigned, 1 if assigned, 0 if fulfilled, or (-1) if expired
        zone            % the zone (1 of 3) in which the request takes place
        exprTime        % Time at which a high priority request will expire (number of hours)
        index           % The index in the active request list
        cargoType       % The type of cargo needed in the request
    end
    
    methods
        % Constructor
        % Initializes the time, starts the status of the request at 2
        % and gets the priority status(high or low) in order to start
        % mission. Also stores the index in the zone's active request list
        function obj = Request6(t, priFac, timeFac,zone,exp, cargoType, index)
            obj.timeRequested = t;
           
            obj.priFac = priFac;
            obj.timeFac = timeFac;
            obj.status = 2;
            obj.zone = zone;
            obj.exprTime = exp;
            obj.index = index;
            obj.timeElapsed = 0;
            obj.cargoType = cargoType; 
            obj.priority=obj.getPriority();
        end
        
        % Mark a request as complete and remove it from the activeList.
        % Also update counters in RequestZone
        function obj = complete(obj,time)
            obj.timeElapsed = time-obj.timeRequested;
            obj.zone.completed = obj.zone.completed + 1;
            obj.zone.waitTime = obj.zone.waitTime+obj.timeElapsed;
            obj.index = 'completed';
            obj.status = 0;
            obj.priFac = time;

        end
        
        % Refresh the request, called every time step
        function refresh(obj,time)
            % Update the time elapsed
            if(obj.status>0)
                obj.timeElapsed = time-obj.timeRequested;
                obj.priority = obj.getPriority();
            end
            % Expire the request if necessary
            if(obj.timeElapsed >=obj.exprTime)
                obj.status = -1;  % Change status to expired value
                obj.zone.expired = obj.zone.expired +1; % Increase the zone's expired counter
                obj.zone.remove(obj.index); % Remove from zone's activeList
                obj.zone.manager.expiredList(length(obj.zone.manager.expiredList)+1)=obj;
                obj.zone.manager.assign(); % Call assign function so UAV's are reassigned if necessary
                %obj.zone.waitTimeHi = obj.zone.waitTimeHi + obj.exprTime;
            end
        end
        % Function to return the Request's current priority
        %   Exponential function based on time and priority factors
        function pri = getPriority(obj)
            % Exponential
            pri = obj.priFac * exp(-(obj.exprTime-obj.timeElapsed)./(2*obj.timeFac*log(2)));  
            % Linear
%             pri = obj.priFac - obj.timeFac*(obj.exprTime-obj.timeElapsed);
            
        end
    end
    
end

