%% UAV Drone file
classdef UAVDrone6 < handle
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
        speed           % Velocity of the drone (assumed constant in pixels per hour)
        distTravelled   % Total distance travelled by the UAV
        rangeLeft       % Flight time remaining before recharge is needed
        cargo           % the cargo available to the UAV
        rangeBuffer     % Distance the drone should be able to fly after returning to base
        base            % a request zone object for the base location
        time            % time elapsed since beginning of simulation
        manager         % The manager object
        color           % the color of the uav's path
        numAssigned     % The number of requests assigned to the UAV
        emptyCounter    % The number of times the UAV refills its cargo
        lowChargeCounter % The number of times the UAV becomes low on charge
        rechargeCounter % The number of times the batteries are replaced
        extraCargo      % Counter for number of times UAVs return with cargo
        idleCounter     % Counts down to keep the UAV idle
        idleTotal       % keeps track of total idle time
    end

    methods
        %% Constructor, object is initialized to 0 distance travelled, full
        % cargo and its time starts off at 0
        % The color is used to distiguish between the many drones we use
        % The manager assigns the requests to the drone
        function obj = UAVDrone6(color,maxRange,maxCargo,sp,base,manager)
            obj.color = color;
            obj.maxRange = maxRange;
            obj.rangeLeft = maxRange;
            obj.maxCargo = maxCargo;
            obj.speed = sp;
            obj.distTravelled = 0;
            obj.base = base;
            obj.position = base.position;
            obj.rangeBuffer = obj.speed/12; % UAV should reach base with up to 5% of max fuel remaining
            obj.time = 0;
            obj.manager = manager;
            obj.request = base.activeList;
            obj.timeToRequest = 0;
            obj.requestsMet = 0;
            obj.numAssigned = 1;
            obj.emptyCounter = 0;
            obj.lowChargeCounter = 0;
            obj.rechargeCounter = 0;
            obj.idleCounter = 1;
            obj.idleTotal = 0;
            % Initialize cargo
            obj.cargo = char.empty;
            numX = ceil(maxCargo/2); % number of high priority cargos to initially load (at least half)
            for c=1:maxCargo
                if c<=numX
                    obj.cargo(c)='X';
                else
                    obj.cargo(c)='Y';
                end
            end
        end     
        
        %% Deliver
        % Function to simulate delivery of aid to a request
        %   If the "delivery" is a visit to the base to refuel, the cargo
        %   and remaining flight time are both reset
        %   Otherwise, the request is completed
        % The UAV is given a new assignment
        function obj = deliver(obj)
            % disp('Delivery at ')
            % disp(obj.position)
            %disp(obj.position)
            %disp(obj.request.zone.position)
            if Distance(obj.position,obj.request.zone.position)>0.1
                disp('UAV NOT AT REQUEST!')
            end
            if obj.request.status<2
                disp('REDUNDANT DELIVERY')
            end
           
            % Refill if the drone is at the base
            if obj.request.index == 'B'                
                obj.refill();
                %disp("Refilled at " + obj.time)
                if (obj.rangeLeft < obj.maxRange * 0.6)
                    obj.rangeLeft = obj.maxRange;
                    obj.rechargeCounter = obj.rechargeCounter + 1;                  
                end             
            else
                
                % Complete the request by delivering cargo (if not at base)
                % by checking the priority of the requests
%                 disp(""+obj.cargo+" " + obj.request.priority)
                if obj.request.timeElapsed>obj.request.exprTime
                    disp('Too Late :(')
                    disp(obj.request.exprTime-obj.request.timeElapsed)
                end
                if(contains(obj.cargo, obj.request.cargoType))
                    index = strfind(obj.cargo, obj.request.cargoType);
                    if isempty(index)
                        % Check if UAV was sent to a request it did not have
                        % cargo to complete
                        disp('Incorrect delivery') 
                    end
                    % If UAV delivers its last item, it is now empty
                    if (length(obj.cargo)==1)
                        obj.cargo = char.empty;
                        % Remove delivered item from cargo (first 'H')
                    else
                        obj.cargo = horzcat(obj.cargo(1:index-1),obj.cargo(index+1:length(obj.cargo)));
                    end
                else
                    disp('Incorrect Delivery');                
                end
%                 disp(obj.cargo)
                      
%                 disp(obj.position)     
                obj.requestsMet = obj.requestsMet + 1;
                obj.request.complete(obj.time);
                obj.manager.completedList(length(obj.manager.completedList) + 1) = obj.request;
                obj.request.index = 0;
            end
               
            if(isempty(obj.cargo))
                obj.emptyCounter = obj.emptyCounter + 1;
                obj.returnToBase();       
            else
                % Set this uav's request to empty if it still has cargo
                obj.request=Request6.empty;
                obj.manager.assign();
            end
                     
            % Check if the request is still active
            flag = 0; % binary value to allow loop to be continue as long as necessary
            while flag == 0
                if obj.request.status<1
                    disp('Assigned to outdated request')
                    if obj.request.index>0
                        obj.request.zone.remove(obj.request.index);
                    end
                    obj.manager.assign;
                else
                    flag = 1;
                end
            end
            % Determine the drone's time to its new request.
            obj.timeToRequest = Distance(obj.position,obj.request.zone.position)/obj.speed;
            % Return to base if there is not enough cargo to complete the
            % next request
            obj.checkFuel();                  
        end   
          
%         % Check if the UAV can meet all of the zone's requests
%         function checkZone(obj,zone)
%                 if (zone.numUnassigned <= obj.cargo)
%                     for i = 1:zone.numUnassigned
%                         zone.requestList(i).status = 1;
%                         obj.numAssigned = obj.numAssigned + 1;                        
%                     end
%                     zone.numUnassigned=zone.numUnassigned-obj.numAssigned;
%                 end
%         end
        
        % Function to send the UAV back to the base if it is too low on
        % charge
        function checkFuel(obj)
            % Return to base if there is not enough fuel to reach the
            % next request
            landingFuel = obj.speed/12;
            if (Distance(obj.position, obj.request.zone.position) + Distance(obj.base.position,obj.request.zone.position) + obj.rangeBuffer + landingFuel >=obj.rangeLeft)
                obj.lowChargeCounter = obj.lowChargeCounter + 1;
                obj.returnToBase();
                obj.timeToRequest = Distance(obj.position,obj.request.zone.position)/obj.speed;
            end
        end
        
        %% This is the function to refill the cargo for the UAVs.
          % The function will refill the UAVs cargo, with high priority 
          % items placed first in the list (ex. ['HHLLL']). The UAV will
          % always have at least one high priority unit, but may have more
          % depending on the ratio of high priority requests to UAVs
        function refill(obj)
            uavCargo = obj.manager.containedCargo;
            reqCargo='';
            % Determine which units of cargo to add
            if length(obj.manager.highReqs)>=(length(uavCargo)+ obj.maxCargo)
                for c=1:(obj.maxCargo-length(obj.cargo)+length(obj.manager.containedCargo))
                    reqCargo(length(reqCargo)+1)=obj.manager.highReqs(c).cargoType;
                end
                uavNumX = length(strfind(uavCargo, 'X'));
                uavNumY = length(strfind(uavCargo, 'Y'));
                reqNumX = length(strfind(reqCargo, 'X'));
                reqNumY = length(strfind(reqCargo, 'Y'));
                fillX = reqNumX-uavNumX;
                fillY = reqNumY-uavNumY;
            else
                for c=1:length(obj.manager.highReqs)
                    reqCargo(length(reqCargo)+1)=obj.manager.highReqs(c).cargoType;
                end
                reqNumX = length(strfind(reqCargo, 'X'));
                reqNumY = length(strfind(reqCargo, 'Y'));
                if reqNumX>=reqNumY
                    fillX = ceil(obj.maxCargo/2);
                    fillY = obj.maxCargo-fillX;
                else
                    fillY = ceil(obj.maxCargo/2);
                    fillX = obj.maxCargo - fillY;
                end
            end
            % Fill the UAV, if it has empty spots
            if length(obj.cargo)<obj.maxCargo
                for c=1:(obj.maxCargo-length(obj.cargo))
                    if(c<=fillX)
                        obj.cargo(length(obj.cargo)+1) = 'X';
                    else
                        obj.cargo(length(obj.cargo)+1)= 'Y';
                    end
                end
            else
                % Replace the UAV's cargo if it comes in with full cargo
                obj.cargo = '';
                for c=1:obj.maxCargo
                    if fillX >= fillY
                        obj.cargo(c)='X';
                        fillX = fillX-1;
                    else
                        obj.cargo(c)='Y';
                        fillY = fillY-1;
                    end
                end   
            end
        end
          
        % Function to return the UAV to base
        %   Replaces the current request with the base
        %   Marks the request as unassigned
        function  returnToBase(obj)
%            obj.request.status = 2;
            %disp('Sent Back to the base')
            obj.request= obj.base.activeList;
            if Distance(obj.position,obj.base.position)<.1
                %disp(obj.position)
                %disp(obj.request.zone.position)
                obj.idleCounter = 1;
            end
           
        end
        
        %% Function to refresh the UAV position, called every time step and
        % when the UAV has reached a request
        %   Check if it has reached its request, and call deliver() if 
        %       it has arrived
        %   If the UAV is less than one time step away from the
        %       request, call refresh() again at the time when it will
        %       arrive
        %   Update the UAV's position, check if another should be assigned
        %   Input: newTime = the time at which refresh is called
        function  refresh(obj,newTime)
            if obj.rangeLeft<=0
                %disp('UAV out of fuel')
                disp(obj.rangeLeft)
               
            end
            % Make the UAV wait, if necessary
            if(obj.idleCounter>0)
                % Idle UAV
                
                obj.time=newTime;
                %disp(obj.position)
                %disp(obj.request.zone.position)
                
                obj.idleCounter=obj.idleCounter-1;
                %disp("Idle: " + obj.idleCounter)
                obj.idleTotal = obj.idleTotal + 1;
                
                if(obj.idleCounter==0)
                    %disp(obj.position)
                    %disp(obj.request.zone.position)
                    obj.deliver();
                    
                end                                           
            else
                % Find new position of the UAV
                newPos = obj.position+(obj.request.zone.position-obj.position).*obj.speed.*(newTime-obj.time)./Distance(obj.position,obj.request.zone.position);
                
                % Begin delivery process if the UAV has reached its goal
                if(Distance(newPos,obj.request.zone.position)<0.1)
                    % Plots the path from the UAV to the request and
                    % updates the UAV at the time of delivery
                     plot([obj.position(1),newPos(1)],[obj.position(2),newPos(2)], obj.color,'LineWidth',1.5)

                    obj.position=newPos;
                    obj.distTravelled =obj.distTravelled + obj.speed*(newTime-obj.time);
                    obj.rangeLeft = obj.rangeLeft - (obj.speed * (newTime-obj.time));
                    obj.time = newTime;                    
                    %disp(obj.position)
                    %disp(obj.request.zone.position)
                    obj.idleCounter = 5;
                    if(obj.request.index ~= 'B')
                        if obj.request.status<1
                            disp('Already completed or expired request')
                            obj.manager.assign();
                        end                       
                        obj.rangeLeft = obj.rangeLeft - obj.speed/12;
                        obj.request.zone.remove(obj.request.index);
                        obj.request.index = -10;
                    end
                else
                    %hold on
                    % Plot the change in position
                    plot([obj.position(1),newPos(1)],[obj.position(2),newPos(2)], obj.color,'LineWidth',1.5)
                    % Move the UAV forward by updating its position and time
                    % and plot the results
                    if obj.request.status<1
                        disp('Redirecting from completed or expired request')
                        obj.manager.assign();
                    end
                    obj.position=newPos;
                    plot(obj.position(1),obj.position(2),'k.','MarkerSize',7)
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
