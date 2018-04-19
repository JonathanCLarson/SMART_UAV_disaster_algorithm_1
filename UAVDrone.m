classdef UAVDrone
    %UAVDrone A 
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
        
        function obj = addRequest(obj,req)
            obj.requests(length(obj.requests)+1)=req;
        end
        function [eta,fistReq]= choosePath(obj)
            % Compute shortest humanitarian distance traveled and choose
            % which request to go to first
        end
    end
    
end

