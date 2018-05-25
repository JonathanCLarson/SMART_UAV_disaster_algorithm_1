function [numComp, perComp, numExp, wait, waitHi,simManager] = uavSim1(UAV, zones, baseLocation, priFac,duration,kmToPix)
% Simulates a uav fleet responding to a disaster
% Runs a simulation and returns the results for analysis
% Inputs:
%   UAV: A vector of [number of UAVs in the fleet, speed of the UAVs, 
%      maximum cargo load for the drones, and range]
%   zones: A vector of RequestZone4 objects that the fleet will respond to
%   baseLocation: The [x,y] location of the base where the drones resupply
%   priFac: The priority factor which tells the rate comparing low to high
%       priority requests
%   duration: The duration of the simulation (hours)
%   kmToPix: The ratio of kilometers to pixels on the map (used to convert to
%       speed from km/h)


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
uavSpeed = UAV(2); % in km/h
uavRange = UAV(4); % in kilometers
uavCap = UAV(3); % Drone capacity 

km2Pix = @(ft) ft/kmToPix;      % Anonymous function to convert km to pixels
pix2km = @(pix) pix * km2px;    % Anonymous function to convert pixels to km 

% Create the base object, and give it a single request.
base = RequestZone4(baseLocation,'B','B','B','B','B','B');
base.activeList=Request4('B','B','B',base,'B', 0);

% Reset the Request Zones (needed for running multiple simulations
for c=1:length(zones)
    zones(c).reset();
end
% plot(base.position(1),base.position(2),'r.','MarkerSize',25)

manager = Manager4(zones, base); % Create a manager to receive and assign requests
for c=1:length(zones)
    zones(c).manager = manager;
    zones(c).priFac = priFac;
end
% Color array for the UAV's
color = ['y', 'g','m','c','b','k','w','r'];

% Assign UAV's 
% Converts uav speeds and ranges to pixels 
uavArray=UAVDrone4.empty;
 for k=1:numUAVs
        uavArray(k, 1)=UAVDrone4(color(k),km2Pix(uavRange),uavCap,km2Pix(uavSpeed),base,manager);
        manager.addUAV(uavArray(k, 1));
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
