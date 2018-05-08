classdef UAVDrone
    %UAVDrone A 
    %   Detailed explanation goes here
    
    
    
    properties
        
        position
        request
        maxRange
        maxCargo
        speed 
        distTravelled
        cargo        
        basePosition
        distBuffer
        base % a request object for the base location
    end
    
    methods
        % Constructor, object is initialized to 0 distance travelled, full
        % cargo
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

        function obj = deliver(obj)
            if(obj.request.position == obj.base.position)
                obj.cargo = obj.maxCargo;
                obj.distTravelled = 0;
            end
            obj.request.complete(); 
            % get next request
            
            if (obj.distTravelled+Distance(pos,obj.request.position)+obj.distBuffer >=obj.maxRange)
                obj.returnToBase();
            else if(obj.distTravelled+obj.distBuffer>= obj.maxRange)
                obj.returnToBase();
            end
        end
        % Function to 
        function obj = returnToBase(obj)
           obj.request = obj.base;
        end
            
    end
    
end

