classdef UAVDrone
    %UAVDrone A 
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
        manager % The manager object
    end
    
    methods
        % Constructor, object is initialized to 0 distance travelled, full
        % cargo
        function obj = UAVDrone(pos,req,range,maxCargo,sp,base,manager)
            obj.position=pos;
            
            obj.maxRange=range;
            obj.maxCargo = maxCargo;
            obj.cargo = maxCargo;
            obj.speed=sp;
            obj.distTravelled = 0;
            obj.base = base;
            obj.distBuffer = 0.05*obj.maxRange;
            obj.time = 0;
            obj.manager=manager;
            obj.request=req;
        end
        %% Mutator Methods
        % Mutator method to change the request
        function obj = set.request(obj,req)
            disp("Changed request to " + req.position(1)+","+req.position(2))
            obj.request = req;
        end
        % Mutator method to change the cargo
        function obj = set.cargo(obj,cargo)
            obj.cargo = cargo;
        end
        
        %% Action methods
        % Function to simulate delivery of aid to a request
        function obj = deliver(obj)
            if(obj.position == obj.base.position)
                obj.cargo = obj.maxCargo;
                obj.distTravelled = 0;
            else
                % Complete the request by delivering cargo
                obj.cargo = obj.cargo - 1;
                obj.request = obj.request.complete(); 
                % get next request
                obj=obj.manager.assign(obj);
                disp("new assignment received at "+ obj.time)
                % Return to base if necessary
                if (obj.distTravelled+Distance(obj.position,obj.request.position)+Distance(obj.base.position,obj.request.position)+obj.distBuffer >=obj.maxRange)
                    obj=obj.returnToBase();
                end
                if(obj.cargo<1)
                    obj=obj.returnToBase();
                end
            end
        end
        % Function to return the UAV to base
        function obj = returnToBase(obj)
           obj.request= obj.base;
           disp("returning to base at" + obj.time)
        end
        % Refresh the UAV's position, check if another should be assigned
        function obj = refresh(obj,newTime)
                % Find new position of the UAV
                newPos = obj.position+(obj.request.position-obj.position).*obj.speed.*(newTime-obj.time)./Distance(obj.position,obj.request.position);
                if(newPos == obj.request.position)
                    plot([obj.position(1),newPos(1)],[obj.position(2),newPos(2)],'LineWidth',1.5)

                    obj.position=newPos;
                    obj.distTravelled =obj.distTravelled + obj.speed*(newTime-obj.time);
                    obj.time = newTime;
                    obj=obj.deliver();
                    disp("Reached the request at " + obj.time)
                   
                else
                hold on
                % Plot the change in position
                plot([obj.position(1),newPos(1)],[obj.position(2),newPos(2)],'LineWidth',1.5)
                % Move the UAV forward
                obj.position=newPos;
                plot(obj.position(1),obj.position(2),'r*')
                obj.distTravelled =obj.distTravelled + obj.speed*(newTime-obj.time);
                obj.time = newTime;
            
                % If the UAV is close to its target, perform a shorter time
                % step so that it can refresh at the goal location
                if((Distance(obj.position,obj.request.position)/obj.speed) <1)
                    t = obj.time+ (Distance(obj.position,obj.request.position)/obj.speed);
                    obj=obj.refresh(t);
                end
                end
            
        end
    
    end
end
