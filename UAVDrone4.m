%% UAV Drone file
classdef UAVDrone4 < handle
    %UAVDrone
    %   UAV objects to simulate the distribution of aid after a disaster in
    %   Puerto Rico
    %   UAV is a handle object
    %   Jonathan Larson and Gabe Flores
    %   May 17, 2018
       
    properties % (instance variables)        
        position        % current (last known) position of the UAV
        request         % The next request to fill
        timeToRequest   % The time until the UAV reaches the request
        requestsMet     % The number of requests met by the UAV
        maxRange        % Maximum range of the UAV in pixels
        maxCargo        % Maximum carrying capacity
        speed  % Velocity of the drone (assumed constant in pixels per hour)
        distTravelled % Total distance travelled by the UAV
        rangeLeft % Flight time remaining before recharge is needed
        cargo % the cargo available to the UAV
        rangeBuffer % Distance the drone should be able to fly after returning to base
        base % a request object for the base location
        time % time elapsed since beginning of simulation
        manager % The manager object
        color % the color of the uav's path
        numAssigned % The number of requests assigned to the UAV
        emptyCounter % The number of times the UAV refills its cargo
        lowChargeCounter % The number of times the UAV becomes low on charge
        rechargeCounter % The number of times the batteries are replaced
        idleCounter % Counts down to keep the UAV idle
        idleTotal % keeps track of total idle time
    end

    methods
        % Constructor, object is initialized to 0 distance travelled, full
        % cargo and its time starts off at 0
        % The color is used to distiguish between the many drones we use
        % The manager assigns the requests to the drone
        function obj = UAVDrone4(color,maxRange,maxCargo,sp,base,manager)
            obj.color= color;
            obj.maxRange=maxRange;
            obj.rangeLeft = maxRange;
            obj.maxCargo = maxCargo;
            obj.cargo = ['H','L'];
            obj.speed=sp;
            obj.distTravelled = 0;
            obj.base = base;
            obj.position= base.position;
            obj.rangeBuffer = 0.005*obj.maxRange; % UAV should reach base with up to 5% of max fuel remaining
            obj.time = 0;
            obj.manager=manager;
            obj.request=base.activeList;
            obj.timeToRequest = 0;
            obj.requestsMet = 0;
            obj.numAssigned = 1;
            obj.emptyCounter = 0;
            obj.lowChargeCounter = 0;
            obj.rechargeCounter = 0;
            obj.idleCounter = 1;
            obj.idleTotal = 0;
        end        
        %% Action methods
        % Function to simulate delivery of aid to a request
        %   If the "delivery" is a visit to the base to refuel, the cargo
        %   and remaining flight time are both reset
        %   Otherwise, the request is completed
        % The UAV is given a new assignment
        function obj = deliver(obj)
            % disp('Delivery at ')
            % disp(obj.position)
            % Refill if the drone is at the base
            if(Distance(obj.position, obj.base.position) <= 0.001)
                obj.refill();
                %disp("Refilled at " + obj.time)
                if (obj.rangeLeft < obj.maxRange * 0.4)
                    obj.rangeLeft = obj.maxRange;
                    obj.rechargeCounter = obj.rechargeCounter + 1;
                    
                end
             
            else
                % Complete the request by delivering cargo (if not at base)
                % by checking the priority of the requests
                if(obj.request.priority == 1)
                  index = find(obj.cargo, 'H');
                  if (index == 1 && length(index) == 1)
                      obj.cargo = [];
                  elseif (index(1) == 1 && length(index) == 2)
                      obj.cargo = obj.cargo(2);
                  end
                else
                    index = find(obj.cargo, 'L');
                     if (index == 1)
                      obj.cargo = []; 
                     else
                        obj.cargo = obj.cargo(1);
                     end
                end
                      
                     
                obj.requestsMet = obj.requestsMet + 1;
                obj.request.complete(obj.time);
                obj.manager.completedList(length(obj.manager.completedList) + 1) = obj.request; 
            end
               
            if(isempty(obj.cargo))
                %disp("Cargo empty at " + obj.time)
                obj.emptyCounter = obj.emptyCounter + 1;
                obj.returnToBase();
%               disp(obj.position)
%               disp(obj.request)
            else
                % Set this uav's request to empty if it still has cargo
                obj.request=Request4.empty;
            end
            
            % Have the manager give new assignments
            
           
            % Call assign function in the manager
            obj.manager.assign();
            % Determine the drone's time to its new request.
            obj.timeToRequest = Distance(obj.position,obj.request.zone.position)/obj.speed;

                % Return to base if there is not enough cargo to complete the
                % next request
                
            % Instantly perform a delivery if the new request is at the
            % current UAV location (same zone as the previous request)
            if(Distance(obj.request.zone.position,obj.position)<=.0001)
                if(obj.request.priority ~= 'B')
                    obj.deliver();
                else
                    obj.idleCounter = 1;
                end
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
        
        % Function to send the UAV back to the base if it is too low on
        % charge
        function checkFuel(obj)
            % Return to base if there is not enough fuel to reach the
            % next request
            if (Distance(obj.position, obj.request.zone.position) + Distance(obj.base.position,obj.request.zone.position)+obj.rangeBuffer >=obj.rangeLeft)
                obj.lowChargeCounter = obj.lowChargeCounter + 1;
                % disp("Fuel empty at " + obj.time)
                obj.returnToBase();
                %disp("Fuel low at " + obj.time)
                obj.timeToRequest = Distance(obj.position,obj.request.zone.position)/obj.speed;
            end
        end
        
        %% This is the function to refill the cargo for the UAVs.
          % The function will put two high priority cargo in the UAV if 
          % There are more high priority requests than drones, otherwise,
          % it will put the high and low priority cargo in the UAVs
        function refill(obj)
            if obj.manager.activeHi>=obj.manager.uavList
                obj.cargo = ['H','H'];
            else
                obj.cargo = ['H', 'L'];
            end
        end
        
        
        % Function to return the UAV to base
        %   Replaces the current request with the base
        %   Marks the request as unassigned
        function  returnToBase(obj)
%            obj.request.status = 2;
            obj.request= obj.base.activeList;
           
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
                % Make the UAV wait, if necessary
                if(obj.idleCounter>0)
                    % Idle UAV
                    obj.time=newTime;
                    obj.idleCounter=obj.idleCounter-1;
                    obj.idleTotal = obj.idleTotal + 1;
                    if(obj.idleCounter==0)
                        obj.deliver();
                    end                                           
                else
                % Find new position of the UAV
                newPos = obj.position+(obj.request.zone.position-obj.position).*obj.speed.*(newTime-obj.time)./Distance(obj.position,obj.request.zone.position);
                
                % Begin delivery process if the UAV has reached its goal
                if(Distance(newPos,obj.request.zone.position)<=0.001)
                    % Plots the path from the UAV to the request and
                    % updates the UAV at the time of delivery
                   plot([obj.position(1),newPos(1)],[obj.position(2),newPos(2)], obj.color,'LineWidth',1.5)

                    obj.position=newPos;
                    obj.distTravelled =obj.distTravelled + obj.speed*(newTime-obj.time);
                    obj.rangeLeft = obj.rangeLeft - (obj.speed * (newTime-obj.time));
                    obj.time = newTime;
                    obj.idleCounter = 5;
                    if(obj.request.priority ~= 'B')
                        obj.request.zone.remove(obj.request.index);
                    end
                else
                %hold on
                % Plot the change in position
               plot([obj.position(1),newPos(1)],[obj.position(2),newPos(2)], obj.color,'LineWidth',1.5)
                % Move the UAV forward by updating its position and time
                % and plot the results
                obj.position=newPos;
                plot(obj.position(1),obj.position(2),'k.')
                obj.distTravelled =obj.distTravelled + obj.speed*(newTime-obj.time);
                obj.timeToRequest = Distance(obj.position,obj.request.zone.position)/obj.speed;
                obj.rangeLeft = obj.rangeLeft - (obj.speed * (newTime-obj.time));
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
