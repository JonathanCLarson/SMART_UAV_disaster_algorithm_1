%% uavDriver
% Test driver for the UAVDrone class
% Simulates the UAV over Puerto Rico
% Creates requests for the drone to fulfill
close all; clear; format long;
% Read in map for background of graph
MAP=imread('TestRun1Map.png'); image(MAP);
axis=[0 900 100 450];
hold on
base = Request(0,[130,285],1,1);
plot(base.position(1),base.position(2),'k.','MarkerSize',15)

hold on

for c = 1:40
reqList(c) = Request(0,[1100*rand,700*rand],0,2);
plot(reqList(c).position(1),reqList(c).position(2),'b.','MarkerSize',15);
end

manager = Manager1(reqList); % Create a manager to receive and assign requests


color = ['y', 'g','m'];

dZone1 = Request(0,[520,650],0,0); % Request object for drop zone 1
dZone2 = Request(0,[795,580],0,0); % Request object for drop zone 2
dZone3 = Request(0,[1070,185],0,0); % Request object for drop zone 3
uav1 = UAVDrone(base.position,color(1),10,3,50,base,manager);
uav2 = UAVDrone(base.position,color(2),10,3,50,base,manager);
uav3 = UAVDrone(base.position,color(3),10,3,50,base,manager);
% Simulate time step
for c=1:35
    uav1.refresh(c);
    uav2.refresh(c);
    uav3.refresh(c);
end

title('UAV simulation test')
