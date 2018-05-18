%% uavDriver
% Test driver for the UAVDrone class
% Simulates the UAV over Puerto Rico
% Creates requests for the drone to fulfill
%close all;
clear; format long;

% Parameters
numUAVs = 2; % The number of UAV's in the fleet
timeExp = 2; % Time at which high priority requests expire 
uavSpeed = 15; % in mph
uavFlightTime = 1; % in hrs
uavCap = 3; % Drone capacity 
duration = 12;

feetToPix = @(ft) ft/16.7;
pixToFeet = @(pix) pix * 16.7;

% Read in map for background of graph
MAP=imread('TestRun2Map.png'); image(MAP);
axis=[0 900 100 450];
hold on
base = RequestZone3([130,285],1,1,0);
base.requestList=Request3('B','B',base,0);
plot(base.position(1),base.position(2),'k.','MarkerSize',15)

hold on

% for c = 1:40
% reqList(c) = Request(0,[1100*rand,700*rand],0,2);
% plot(reqList(c).position(1),reqList(c).position(2),'b.','MarkerSize',15);
% end
dZone1 = RequestZone3([510,660],0.05,.5,timeExp); % Request object for drop zone 1
dZone2 = RequestZone3([785,580],0.05,0.4,timeExp); % Request object for drop zone 2
dZone3 = RequestZone3([1080,170],0.05,.6,timeExp); % Request object for drop zone 3
dZone4 = RequestZone3([886, 68], 0.05, .4, timeExp); % Request object for drop zone 4
dZone5 = RequestZone3([716, 235], 0.05, .5, timeExp); % Request object for drop zone 5
dZone6 = RequestZone3([826, 328], 0.05, .4, timeExp); % Request object for drop zone 6


zoneList = [dZone1,dZone2,dZone3, dZone4,dZone5,dZone6];
% zoneList(1).requestList = [Request2(0,1000, zoneList(1),timeExp) Request2(0,1,zoneList(1),timeExp)];%,Request(0,1, zoneList(1)),Request(0,1, zoneList(1)),Request(0,1,zoneList(1))];
% zoneList(2).requestList = [Request2(0,1, zoneList(2),timeExp) Request2(0,1000,zoneList(2),timeExp)];%,Request(0,1000, zoneList(2))];
% zoneList(3).requestList = [Request2(0,1000, zoneList(3),timeExp), Request2(0, 1, zoneList(3),timeExp)];%,Request(0,1000, zoneList(3))];
% zoneList(4).requestList = [Request2(0,1000, zoneList(4),timeExp) Request2(0,1,zoneList(4),timeExp)];%,Request(0,1, zoneList(1)),Request(0,1, zoneList(1)),Request(0,1,zoneList(1))];
% zoneList(5).requestList = [Request2(0,1, zoneList(5),timeExp) Request2(0,1000,zoneList(5),timeExp)];%,Request(0,1000, zoneList(2))];
% zoneList(6).requestList = [Request2(0,1000, zoneList(6),timeExp), Request2(0, 1, zoneList(6),timeExp)];%,Request(0,1000, zoneList(3))];

manager = Manager3(zoneList, base); % Create a manager to receive and assign requests

color = ['y', 'g','m'];

% uav1 = UAVDrone(color(1),10,3,200,base,manager);
% uav2 = UAVDrone(color(2),10,3,200,base,manager);
% uav3 = UAVDrone(color(3),10,3,200,base,manager);
% uavArrayTest = [uav1,uav2,uav3];

% Assign UAV's 
 for k=1:numUAVs
        uavArray(k)=UAVDrone3(color(k),uavFlightTime,uavCap,feetToPix(uavSpeed * 5280),base,manager);
        manager.addUAV(uavArray(k));
 end
 
% Simulate time step, each is 1 minute
for c=1:60*duration
        manager.refresh(c/60);    
end

title('UAV simulation test')

disp(manager.requestsMet + " Requests met")
disp(manager.expired + " Requests expired")

[overallTable,uavTable,zoneTable]=analyze(manager);
disp(zoneTable)
disp(uavTable)
disp(overallTable)
