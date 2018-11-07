function [numComp, numExp,perExp, wait, waitX,simManager,recharges,extraCargo,refills, idleTime] = uavSim3visual(UAV, zoneParam, baseLocation, priFac,timeFac,addedVal,duration,kmToPix)
% Simulates a uav fleet responding to a disaster
% Runs a simulation and returns the results for analysis
% Inputs:
%   UAV: A vector of [number of UAVs in the fleet, speed of the UAVs, 
%      maximum cargo load for the drones, and range]
%   zoneParam: A matrix of parameters, used to create the RequestZone6 objects 
%       that the fleet will respond to. The rows in this matrix correspond
%       to the individual zones, while the columns represent:
%       [x-position,y-position,probability of new request, probability of
%       high request, 
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
base = RequestZone6(baseLocation,'B','B','B','B', 'B');
base.activeList=Request6('B','B','B',base,'B','B', 'B');


% Create the Request Zone objects and store them in an array
[numZones,~]=size(zoneParam);
zones = RequestZone6.empty;
for c=1:numZones
    zones(c)=RequestZone6([zoneParam(c,1),zoneParam(c,2)],zoneParam(c,3),zoneParam(c,4),zoneParam(c,5),zoneParam(c,6),c);
end
% Reset the Request Zones (needed for running multiple simulations
for c=1:length(zones)
    zones(c).reset();
end

manager = Manager6visual(zones, base, priFac, timeFac,addedVal); % Create a manager to receive and assign requests
% Add the manager to the zones, assign priority and time factors
for c=1:length(zones)
    zones(c).manager = manager;
end
% Color array for the UAV's
color = ['y', 'c','m','b','r','w','k','g','y','c','m','b','r','w','k','g'];

% Create UAV's and add them to the manager
% Converts uav speeds and ranges to pixels 
uavArray=UAVDrone6.empty;
 for k=1:numUAVs
    uavArray(k, 1)=UAVDrone6(color(k),km2Pix(uavRange),uavCap,km2Pix(uavSpeed),base,manager);
    manager.addUAV(uavArray(k, 1));
 end
 
%  figure
%  % Plot the base location
%  plot(baseLocation(1),baseLocation(2),'ro','MarkerFaceColor','r')
%  hold on;
% Simulate time steps for the duration of the simulation, each is 1 minute

for c=1:60
    manager.refresh(c/60);  
      pause(1)
    end

% Perform analysis and return results, as well as the manager object.
[numComp, numExp,perExp, wait, waitX,recharges,extraCargo,refills,idleTime] = analyze2visual(manager);
simManager=manager;


