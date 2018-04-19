classdef UAVDrone
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        position
        requests
        flightTime
        speed        
    end
    
    methods
        function obj = UAVDrone(pos,req,time,sp)
            obj.position=pos;
            obj.requests=req;
            obj.flightTime=time;
            obj.speed=sp;
        end
        function addRequest(place,priority,time)
            
    end
    
end

