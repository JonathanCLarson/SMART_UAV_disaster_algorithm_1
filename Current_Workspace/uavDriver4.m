%% uavDriver
% Test driver for the UAVDrone class
% Simulates the UAV over Puerto Rico
% Creates requests for the drone to fulfill
close all; clear; format long;

% Parameters
numUAVs = 3; % The number of UAV's in the fleet
timeExp = 50; % Time at which high priority requests expire 
uavSpeed = 15; % in mph
uavFlightTime = 4; % in hrs

feetToPix = @(ft) ft/16.7;
pixToFeet = @(pix) pix * 16.7;

% Read in map for background of graph
MAP=imread('TestRun1Map.png'); image(MAP);
axis=[0 900 100 450];
hold on
base = RequestZone2([130,285],1,1,0);
base.requestList=Request2('B','B',base,0);
plot(base.position(1),base.position(2),'k.','MarkerSize',15)

hold on

% for c = 1:40
% reqList(c) = Request(0,[1100*rand,700*rand],0,2);
% plot(reqList(c).position(1),reqList(c).position(2),'b.','MarkerSize',15);
% end
dZone1 = RequestZone2([510,660],0.4,.5,20); % Request object for drop zone 1
dZone2 = RequestZone2([785,580],0.4,0.2,20); % Request object for drop zone 2
dZone3 = RequestZone2([1080,170],0.4,.4,20); % Request object for drop zone 3
dZone4 = RequestZone2([886, 68], 0.4, .1, 20); % Request object for drop zone 4
dZone5 = RequestZone2([716, 235], 0.4, .2, 20); % Request object for drop zone 5
dZone6 = RequestZone2([826, 328], 0.4, .3, 20); % Request object for drop zone 6


zoneList = [dZone1,dZone2,dZone3, dZone4,dZone5,dZone6];
zoneList(1).requestList = [Request2(0,1000, zoneList(1),timeExp) Request2(0,1,zoneList(1),timeExp)];%,Request(0,1, zoneList(1)),Request(0,1, zoneList(1)),Request(0,1,zoneList(1))];
zoneList(2).requestList = [Request2(0,1, zoneList(2),timeExp) Request2(0,1,zoneList(2),timeExp)];%,Request(0,1000, zoneList(2))];
zoneList(3).requestList = [Request2(0,1000, zoneList(3),timeExp), Request2(0, 1, zoneList(3),timeExp)];%,Request(0,1000, zoneList(3))];
zoneList(4).requestList = [Request2(0,1000, zoneList(4),timeExp) Request2(0,1,zoneList(4),timeExp)];%,Request(0,1, zoneList(1)),Request(0,1, zoneList(1)),Request(0,1,zoneList(1))];
zoneList(5).requestList = [Request2(0,1, zoneList(5),timeExp) Request2(0,1,zoneList(5),timeExp)];%,Request(0,1000, zoneList(2))];
zoneList(6).requestList = [Request2(0,1000, zoneList(6),timeExp), Request2(0, 1, zoneList(6),timeExp)];%,Request(0,1000, zoneList(3))];

manager = Manager2(zoneList, base); % Create a manager to receive and assign requests

color = ['y', 'g','m'];

% uav1 = UAVDrone(color(1),10,3,200,base,manager);
% uav2 = UAVDrone(color(2),10,3,200,base,manager);
% uav3 = UAVDrone(color(3),10,3,200,base,manager);
% uavArrayTest = [uav1,uav2,uav3];

% Assign UAV's 
 for k=1:numUAVs
        uavArray(k)=UAVDrone2(color(k),uavFlightTime,3,feetToPix(uavSpeed * 5280),base,manager);
        manager.addUAV(uavArray(k));
 end
 
% Simulate time step each is 1/2 hr
for c=1:600
        manager.refresh(c/60);    
end

title('UAV simulation test')

disp(manager.requestsMet + " Requests met")
disp(manager.expired + " Requests expired")
