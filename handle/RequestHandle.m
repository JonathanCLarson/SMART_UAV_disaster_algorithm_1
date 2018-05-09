classdef RequestHandle 
    %Request  class to simulate requests for aid in the UAV simulation
        % Stores priority, time needed to fulfill requests, etc.
        % This version is a handle class.
    properties
        timeRequested % when the request was made
        timeElapsed % time since the request was made
        position % location on the map
        priority % 0 (hi) or 0 (low)
        status % 2 if unassigned, 1 if assigned, 0 if fulfilled or expired
    end
    
    methods
        % Constructor
        function obj = Request(t,pos,pri,st)
            obj.timeRequested = t;
            obj.position = pos;
            obj.priority = pri;
            obj.status = st;
        end
        % Determine if the request was met.
        function obj = complete(obj)
            obj.status = 0;
            disp("Task Completed")
        end
    end
    
end

