classdef UAVDrone
    %UAVDrone A 
        cargo        
    %   UAV objects to simulate the distribution of aid after a disaster in
    %   Puerto Rico
       
    properties % (instance variables)        
        position % current (last known) position of the UAV
        request % The next request to fill
        maxRange % Maximum range of the UAV
        maxCargo % Maximum carrying capacity
        speed  % Velocity of the drone (assumed constant)
        distTravelled % Distance travelled since last recharge
        cargo % Amount of cargo remaining
        basePosition % Location of resupply
        distBuffer % Distance the drone should be able to fly after returning to base
        base % a request object for the base location
        time % time elapsed
    end
    
    methods
        % Constructor, object is initialized to 0 distance travelled, full
        % cargo
        function obj = UAVDrone(pos,req,range,maxCargo,sp,base)
            obj.position=pos;
            obj.request=req;
            obj.maxRange=range;
            obj.maxCargo = maxCargo;
            obj.cargo = maxCargo;
            obj.speed=sp;
            obj.distTravelled = 0;
            obj.base = base;
            obj.distBuffer = 0.05*obj.maxRange;
            obj.time = 0;
        end
        % Function to handle a new object assignment
        function obj = changeRequest(obj,req)
            obj.request=req;
        end
        
        % Function to simulate delivery of aid to a request
        function obj = deliver(obj)
            if(obj.position == obj.base.position)
                obj.cargo = obj.maxCargo;
                obj.distTravelled = 0;
            else
                % Complete the request by delivering cargo
                obj.cargo = obj.cargo - 1;
                obj.request.complete(); 
                % get next request
                % Return to base if necessary
                if (obj.distTravelled+Distance(obj.position,obj.request.position)+Distance(obj.base.position,obj.request.position)+obj.distBuffer >=obj.maxRange)
                    obj.returnToBase();
                end
                if(obj.cargo<1)
                    obj.returnToBase();
                end
            end
        end
        % Function to return the UAV to base
        function obj = returnToBase(obj)
           obj.request = obj.base;
        end
        % Refresh the UAV's position, check if another should be assigned
        function obj = refresh(obj,nextTime)
                % Find new position of the UAV
                nextPos = obj.position+(obj.request.position-obj.position).*obj.speed.*(nextTime-obj.time)./Distance(obj.position,obj.request.position);
                if(nextPos == obj.request.position)
                    obj.deliver();
                    obj.request = obj.base;
                    disp("YAY")
                else
                hold on
                % Plot the change in position
                plot([obj.position(1),nextPos(1)],[obj.position(2),nextPos(2)],'LineWidth',1.5)
                % Move the UAV forward
                obj.position=nextPos;
                obj.distTravelled =obj.distTravelled + obj.speed*(nextTime-obj.time);
                obj.time = nextTime;
            
                % If the UAV is close to its target, perform a shorter time
                % step so that it can refresh at the goal location
                if((Distance(obj.position,obj.request.position)/obj.speed) <1)
                    t = obj.time+ (Distance(obj.position,obj.request.position)/obj.speed);
                    disp(t);
                    obj.refresh(t);
                end
                end
            
        end
    
    end
end

