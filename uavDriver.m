%% uavDriver
% Test driver for the UAVDrone class
% Creates requests for the drone to fulfill
close all
clear all

base = Request(0,[0,0],1,1);
plot(base.position(1),base.position(2),'k.','MarkerSize',15)

hold on
req1= Request(0,[200,200],0,1);
plot(req1.position(1),req1.position(2),'b.','MarkerSize',15)
req2= Request(0,[100,700],0,1);


uav1 = UAVDrone(base.position,req1,2000,3,25,base);
% Simulate time step
for c=1:12
    uav1=uav1.refresh(c);
end
