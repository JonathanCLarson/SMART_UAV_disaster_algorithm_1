%% Request object class
classdef Request3 < handle
    %Request  class to simulate requests for aid in the UAV simulation
        % Stores priority, time needed to fulfill requests, etc.
        % This version is a handle class.
    properties
        timeRequested % when the request was made
        timeElapsed % time since the request was made
        priority % 1 (hi) or 1000 (low)
        status % 2 if unassigned, 1 if assigned, 0 if fulfilled or expired
        zone % the zone (1 of 3) in which the request takes place
        timeExpire % Time at which a high priority request will expire
    end
    
    methods
        % Constructor
        % Initializes the time, starts the status of the request at 2
        % and gets the priority status(high or low) in order to start
        % mission
        function obj = Request3(t,pri,zone,exp)
            obj.timeRequested = t;
            obj.priority = pri;
            obj.status = 2;
            obj.zone = zone;
            obj.timeExpire = exp;
        end
        % Determine if the request was met.
        function obj = complete(obj,time)
            obj.status = 0;
            %disp("Task Completed")
            obj.timeElapsed = time-obj.timeRequested;
            
        end
        function refresh(obj,time)
            obj.timeElapsed=time-obj.timeRequested;
            if(obj.priority == 1000 && obj.status>0&&(time-obj.timeRequested >=obj.timeExpire))
                obj.status=0;
                obj.zone.expired = obj.zone.expired +1;
            end
        end
        
    end
    
end

