function [numComp, perComp, numExp, wait, waitHi,simManager] = uavSim1(UAV, zones, baseLocation, duration,ftToPix)
% Simulates a uav fleet responding to a disaster
% Runs a simulation and returns the results for analysis
% Inputs:
%   UAV: A vector of [number of UAVs in the fleet, speed of the UAVs, and
%       maximum cargo load for the drones]
%   exprTime: The amount of time that can pass before a high priority
%       request "expires" (The victim dies)
%   zones: A vector of RequestZone3 objects that the fleet will respond to
%   baseLocation: The [x,y] location of the base where the drones resupply
%   duration: The duration of the simulation (hours)
%   ftToPix: The ratio of feet to pixels on the map (used to convert to
%       speed from mph)

% Outputs: 
%   numComp: The number of completed requests
%   perComp: The percentage of all requests that were completed
%   numExp: The number of requests that expired
%   wait: The average wait time for all completed requests
%   waitHi: The average wait time for all high priority requests
%
%   Gabriel Flores and Jonathan Larson 5/17/2018


% Parameters
numUAVs = UAV(1); % The number of UAV's in the fleet
uavSpeed = UAV(2); % in mph
uavFlightTime = UAV(4); % in hrs
uavCap = UAV(3); % Drone capacity 

feetToPix = @(ft) ft/ftToPix;
%pixToFeet = @(pix) pix * f2px;


base = RequestZone3(baseLocation,1,1,0);
base.requestList=Request3('B','B',base,0);
%plot(base.position(1),base.position(2),'k.','MarkerSize',15)

manager = Manager3(zones, base); % Create a manager to receive and assign requests

color = ['y', 'g','m'];

% Assign UAV's 
 for k=1:numUAVs
        uavArray(k)=UAVDrone3(color(k),uavFlightTime,uavCap,feetToPix(uavSpeed * 5280),base,manager);
        manager.addUAV(uavArray(k));
 end
 
% Simulate time step, each is 1 minute

for c=1:60*duration
        manager.refresh(c/60);    
end

%title('UAV simulation test')
[numComp, perComp, numExp, wait, waitHi] = analyze2(manager);
simManager=manager;

%disp(manager.requestsMet + " Requests met")
%disp(manager.expired + " Requests expired")

% [overallTable,uavTable,zoneTable]=analyze(manager);
% disp(zoneTable)
% disp(uavTable)
% % disp(overallTable)
