classdef Request
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        time
        position % location on the map
        priority % 0 (hi) or 0 (low)
        status % 1 if active, 0 if fulfilled or expired
    end
    
    methods
        function obj = Request(t,pos,pri,st)
            obj.time = t;
            obj.position = pos;
            obj.priority = pri;
            obj.status = st;
        end
        function obj = complete(obj)
            obj.status = 0;
        end
    end
    
end

