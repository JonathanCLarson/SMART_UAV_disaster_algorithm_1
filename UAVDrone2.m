classdef UAVDrone2 < handle
    %UAVDrone Handle edition 
    %   UAV objects to simulate the distribution of aid after a disaster in
    %   Puerto Rico
    % UAV is a handle object
    % Jonathan Larson and Gabe Flores
    % May 9, 2018
       
    properties % (instance variables)        
        position % current (last known) position of the UAV
        request % The next request to fill
        timeToRequest % The time until the UAV reaches the request
        requestsMet % The number of requests met by the UAV
        maxTime % Maximum flight time of the UAV
        maxCargo % Maximum carrying capacity
        speed  % Velocity of the drone (assumed constant)
        distTravelled % Total distance travelled by the UAV
        timeLeft % Flight time remaining before recharge is needed
        cargo % Amount of cargo remaining
        timeBuffer % Distance the drone should be able to fly after returning to base
        base % a request object for the base location
        time % time elapsed since beginning of simulation
        manager % The manager object
        color % the color of the uav's path
        numAssigned % The number of requests assigned to the UAV
        restockCounter
        refuelCounter
    end

    methods
        % Constructor, object is initialized to 0 distance travelled, full
        % cargo and its time starts off at 0
        % The color is used to distiguish between the many drones we use
        % The manager assigns the requests to the drone
        function obj = UAVDrone2(color,maxTime,maxCargo,sp,base,manager)
            obj.color= color;
            obj.maxTime=maxTime;
            obj.maxCargo = maxCargo;
            obj.cargo = maxCargo;
            obj.speed=sp;
            obj.distTravelled = 0;
            obj.base = base;
            obj.position= base.position;
            obj.timeBuffer = 0.005*obj.maxTime; % UAV should reach base with up to 5% of max fuel remaining
            obj.time = 0;
            obj.manager=manager;
            obj.request=obj.manager.assign(obj);
            obj.timeToRequest = Distance(obj.position,obj.request.zone.position)/obj.speed;
            obj.requestsMet = 0;
            obj.numAssigned = 1;
            obj.restockCounter = 0;
            obj.refuelCounter = 0;
        end        
        %% Action methods
        % Function to simulate delivery of aid to a request
        %   If the "delivery" is a visit to the base to refuel, the cargo
        %   and remaining flight time are both reset
        %   Otherwise, the request is completed
        % The UAV is given a new assignment
        function obj = deliver(obj)
            if(Distance(obj.position, obj.base.position) <= 0.001)
                obj.cargo = obj.maxCargo;
                obj.timeLeft = obj.maxTime;
                %disp("Refilled at " + obj.time)
             
            else
                % Complete the request by delivering cargo
                obj.cargo = obj.cargo - 1;
                obj.requestsMet = obj.requestsMet + 1;
                obj.request.complete(obj.time); 
            end
                % Get the next request from the manager
%            
                   obj.request=obj.manager.assign(obj);
%                 end
                %disp("new assignment received at "+ obj.time)
                % Return to base if there is not enough fuel to reach the
                % next request
                if (obj.timeToRequest+(Distance(obj.base.position,obj.request.zone.position)/obj.speed)+obj.timeBuffer >=obj.timeLeft)
                    %disp("Fuel empty at " + obj.time)
                    obj.returnToBase();
                    %disp("Fuel low at " + obj.time)
                    obj.refuelCounter = obj.refuelCounter + 1;
                    obj.timeToRequest = Distance(obj.position,obj.request.zone.position)/obj.speed;
                end
                % Return to base if there is not enough cargo to complete the
                % next request
                if(obj.cargo<1)
                    %disp("Cargo empty at " + obj.time)
                    obj.restockCounter = obj.restockCounter + 1;
                    obj.returnToBase();
                    obj.timeToRequest = Distance(obj.position,obj.request.zone.position)/obj.speed;
                end
                
                % Instantly perform a delivery if the new request is at the
                % current UAV location (same zone as the previous request)
                if(Distance(obj.request.zone.position,obj.position)<=.001 && (obj.request.priority ~= 'B'))
                    obj.deliver();
                end
               
                
                
                    
                end
    
          
        % Check if the UAV can meet all of the zone's requests
        function checkZone(obj,zone)
                if (zone.numUnassigned <= obj.cargo)
                    for i = 1:zone.numUnassigned
                        zone.requestList(i).status = 1;
                        obj.numAssigned = obj.numAssigned + 1;
                        
                    end
                    zone.numUnassigned=zone.numUnassigned-obj.numAssigned;
                end
        end
        
        % Function to return the UAV to base
        %   Replaces the current request with the base
        %   Marks the request as unassigned
        function  returnToBase(obj)
            obj.request.status = 2;
            obj.request= obj.base.requestList;
           
        end
        
        % Function to refresh the UAV position, called every time step and
        % when the UAV has reached a request
        %   Check if it has reached its request, and call deliver() if 
        %       it has arrived
        %   If the UAV is less than one time step away from the
        %       request, call refresh() again at the time when it will
        %       arrive
        %   Update the UAV's position, check if another should be assigned
        %   Input: newTime = the time at which refresh is called
        function  refresh(obj,newTime)
            % Make the UAV idle for 1 timestep if it has nowhere to go
            
            if(Distance(obj.position,obj.base.position)<.00001 && obj.request.priority=='B')
                disp('UAV idle')
                obj.time=newTime;
                obj.request=obj.manager.assign(obj);
            else
                % Find new position of the UAV
                newPos = obj.position+(obj.request.zone.position-obj.position).*obj.speed.*(newTime-obj.time)./Distance(obj.position,obj.request.zone.position);
                % Execute a delivery if the UAV reached the request or is
                % within 0.001 miles
                if(Distance(newPos,obj.request.zone.position)<=0.001)
                    % Plots the path from the UAV to the request and
                    % updates the UAV at the time of delivery
                    plot([obj.position(1),newPos(1)],[obj.position(2),newPos(2)], obj.color,'LineWidth',1.5)

                    obj.position=newPos;
                    obj.distTravelled =obj.distTravelled + obj.speed*(newTime-obj.time);
                    obj.time = newTime;
                    obj.deliver();
                   
                else
                hold on
                % Plot the change in position
                plot([obj.position(1),newPos(1)],[obj.position(2),newPos(2)], obj.color,'LineWidth',1.5)
                % Move the UAV forward by updating its position and time
                % and plot the results
                obj.position=newPos;
                plot(obj.position(1),obj.position(2),'k.')
                obj.distTravelled =obj.distTravelled + obj.speed*(newTime-obj.time);
                obj.timeToRequest = Distance(obj.position,obj.request.zone.position)/obj.speed;
                obj.time = newTime;
            
                % If the UAV is close to its target, perform a shorter time
                % step so that it can refresh at the goal location
                if((Distance(obj.position,obj.request.zone.position)/obj.speed) <1/60)
                    t = obj.time+ (Distance(obj.position,obj.request.zone.position)/obj.speed);
                    obj.refresh(t);
                end
                
            
                end
            end
    
        end
    end
end
