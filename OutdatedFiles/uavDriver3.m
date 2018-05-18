%% uavDriver
% Test driver for the UAVDrone class
% Simulates the UAV over Puerto Rico
% Creates requests for the drone to fulfill
close all; clear; format long;

% Parameters
numUAVs = 3; % The number of UAV's in the fleet
timeExp = 20; % Time at which high priority requests expire

% Read in map for background of graph
MAP=imread('TestRun1Map.png'); image(MAP);
axis=[0 900 100 450];
hold on
base = RequestZone1([130,285],1,1,0);
base.requestList=Request1('B','B',base,0);
plot(base.position(1),base.position(2),'k.','MarkerSize',15)

hold on

% for c = 1:40
% reqList(c) = Request(0,[1100*rand,700*rand],0,2);
% plot(reqList(c).position(1),reqList(c).position(2),'b.','MarkerSize',15);
% end
dZone1 = RequestZone1([520,650],0.5,.5,20); % Request object for drop zone 1
dZone2 = RequestZone1([795,580],0.1,0.2,20); % Request object for drop zone 2
dZone3 = RequestZone1([1070,185],0.5,.4,20); % Request object for drop zone 3


zoneList = [dZone1,dZone2,dZone3];
zoneList(1).requestList = [Request1(0,1000, zoneList(1),timeExp) Request1(0,1,zoneList(1),timeExp)];%,Request(0,1, zoneList(1)),Request(0,1, zoneList(1)),Request(0,1,zoneList(1))];
zoneList(2).requestList = [Request1(0,1, zoneList(2),timeExp) Request1(0,1,zoneList(2),timeExp)];%,Request(0,1000, zoneList(2))];
zoneList(3).requestList = [Request1(0,1000, zoneList(3),timeExp), Request1(0, 1, zoneList(3),timeExp)];%,Request(0,1000, zoneList(3))];

manager = Manager1(zoneList, base); % Create a manager to receive and assign requests

color = ['y', 'g','m'];

% uav1 = UAVDrone(color(1),10,3,200,base,manager);
% uav2 = UAVDrone(color(2),10,3,200,base,manager);
% uav3 = UAVDrone(color(3),10,3,200,base,manager);
% uavArrayTest = [uav1,uav2,uav3];

% Assign UAV's 
 for k=1:numUAVs
        uavArray(k)=UAVDrone1(color(k),50,3,50,base,manager);
        manager.addUAV(uavArray(k));
 end
 
% Simulate time step
for c=1:100
        manager.refresh(c);    
end

title('UAV simulation test')

disp(manager.requestsMet + " Requests met")
disp(manager.expired + " Requests expired")
