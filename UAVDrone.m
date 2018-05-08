classdef UAVDrone
    %UAVDrone A 
    %   Detailed explanation goes here
    
    properties
        
        position
        request
        maxRange
        speed 
        distTravelled
        basePosition
        distBuffer
        base % a request object for the base location
    end
    
    methods
        function obj = UAVDrone(pos,req,range,sp,base)
            obj.position=pos;
            obj.request=req;
            obj.maxRange=range;
            obj.speed=sp;
            obj.distTravelled = 0;
            obj.base = base;
            obj.distBuffer = 0.05*obj.maxRange;
        end
        
        function obj = changeRequest(obj,req)
            obj.request=req;
        end
        %function [eta,fistReq]= choosePath(obj)
            % Compute shortest humanitarian distance traveled and choose
            % which request to go to first
       % end
        function obj = deliver(obj)
            obj.request.complete(); 
            % get next request
            
            if (obj.distTravelled+Distance(pos,obj.request.position)+obj.distBuffer >=obj.maxRange)
                obj.returnToBase();
            else
            
            end
        end
        % Function to 
        function obj = returnToBase(obj)
           obj.request = obj.base;
        end
            
    end
    
end

