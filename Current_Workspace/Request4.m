
%% Request object class
classdef Request4 < handle
    %Request  class to simulate requests for aid in the UAV simulation
        % Stores priority, time needed to fulfill requests, etc.
        % This version is a handle class.
    properties
        timeRequested % when the request was made
        timeElapsed % time since the request was made
        priority % 1 (hi) or 1000 (low)
        status % 2 if unassigned, 1 if assigned, 0 if fulfilled or expired
        zone % the zone (1 of 3) in which the request takes place
        exprTime % Time at which a high priority request will expire
        index % The index in the active request list
    end
    
    methods
        % Constructor
        % Initializes the time, starts the status of the request at 2
        % and gets the priority status(high or low) in order to start
        % mission. Also stores the index in the zone's active request list
        function obj = Request4(t,pri,zone,exp, index)
            obj.timeRequested = t;
            obj.priority = pri;
            obj.status = 2;
            obj.zone = zone;
            obj.exprTime = exp;
            obj.index = index;
        end
        % Determine if the request was met.
        function obj = complete(obj,time)
            obj.status = 0;
            obj.timeElapsed = time-obj.timeRequested;
            obj.zone.remove(obj.index);
            obj.index = -1;
            
        end
        function refresh(obj,time)
            obj.timeElapsed=time-obj.timeRequested;
            if(obj.priority == 1000 && obj.status>0&&(time-obj.timeRequested >=obj.exprTime))
                obj.status=0;
                obj.zone.expired = obj.zone.expired +1;
                obj.zone.remove(obj.index);
            end
        end
        
    end
    
end

