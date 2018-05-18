function [numComp, perComp, numExp, wait, waitHi,simManager] = uavSim1(UAV, exprTime, zones, baseLocation, duration)
% Simulates a uav fleet responding to a disaster
% Runs a simulation and returns the results for analysis
% Inputs:
%   UAV: A vector of [number of UAVs in the fleet, speed of the UAVs, and
%       maximum cargo load for the drones]
%   exprTime: The amount of time that can pass before a high priority
%       request "expires" (The victim dies)
%   zones: A vector of RequestZone2 objects that the fleet will respond to
%   baseLocation: The [x,y] location of the base where the drones resupply
%   duration: The duration of the simulation (hours)

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

feetToPix = @(ft) ft/16.7;
%pixToFeet = @(pix) pix * 16.7;

% Read in map for background of graph

base = RequestZone2(baseLocation,1,1,0);
base.requestList=Request2('B','B',base,0);
%plot(base.position(1),base.position(2),'k.','MarkerSize',15)



% dZone1 = RequestZone2([510,660],0.1,.5,20); % Request object for drop zone 1
% dZone2 = RequestZone2([785,580],0.12,0.3,20); % Request object for drop zone 2
% dZone3 = RequestZone2([1080,170],0.1,.6,20); % Request object for drop zone 3
% dZone4 = RequestZone2([886, 68], 0.08, .4, 20); % Request object for drop zone 4
% dZone5 = RequestZone2([716, 235], 0.07, .5, 20); % Request object for drop zone 5
% dZone6 = RequestZone2([826, 328], 0.09, .3, 20); % Request object for drop zone 6



% zoneList(1).requestList = [Request2(0,1000, zoneList(1),timeExp) Request2(0,1,zoneList(1),timeExp)];%,Request(0,1, zoneList(1)),Request(0,1, zoneList(1)),Request(0,1,zoneList(1))];
% zoneList(2).requestList = [Request2(0,1, zoneList(2),timeExp) Request2(0,1000,zoneList(2),timeExp)];%,Request(0,1000, zoneList(2))];
% zoneList(3).requestList = [Request2(0,1000, zoneList(3),timeExp), Request2(0, 1, zoneList(3),timeExp)];%,Request(0,1000, zoneList(3))];
% zoneList(4).requestList = [Request2(0,1000, zoneList(4),timeExp) Request2(0,1,zoneList(4),timeExp)];%,Request(0,1, zoneList(1)),Request(0,1, zoneList(1)),Request(0,1,zoneList(1))];
% zoneList(5).requestList = [Request2(0,1, zoneList(5),timeExp) Request2(0,1000,zoneList(5),timeExp)];%,Request(0,1000, zoneList(2))];
% zoneList(6).requestList = [Request2(0,1000, zoneList(6),timeExp), Request2(0, 1, zoneList(6),timeExp)];%,Request(0,1000, zoneList(3))];

manager = Manager2(zones, base); % Create a manager to receive and assign requests

color = ['y', 'g','m'];

% Assign UAV's 
 for k=1:numUAVs
        uavArray(k)=UAVDrone2(color(k),uavFlightTime,uavCap,feetToPix(uavSpeed * 5280),base,manager);
        manager.addUAV(uavArray(k));
 end
 for j = 1:length(zones)
     zones(j).expTime = exprTime;
 end
 
% Simulate time step, each is 1 minute

for c=1:60*duration
        manager.refresh(c/60);    
end

%title('UAV simulation test')
[numComp, perComp, numExp, wait, waitHi] = analyze(manager);
simManager=manager;

%disp(manager.requestsMet + " Requests met")
%disp(manager.expired + " Requests expired")

% [overallTable,uavTable,zoneTable]=analyze(manager);
% disp(zoneTable)
% disp(uavTable)
% % disp(overallTable)
hold off
