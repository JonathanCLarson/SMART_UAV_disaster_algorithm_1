%% uavDriver
% Test driver for the UAVDrone class
% Creates requests for the drone to fulfill
close all
clear

base = Request(0,[0,0],1,1);
plot(base.position(1),base.position(2),'k.','MarkerSize',15)

hold on
% req1= Request(0,[200,200],0,1);
% plot(req1.position(1),req1.position(2),'b.','MarkerSize',15)
% 
% req2= Request(0,[100,200],0,1);
% plot(req2.position(1),req2.position(2),'b.','MarkerSize',15)
% 
% req3=Request(0,[200,100],0,1);
% plot(req3.position(1),req3.position(2),'b.','MarkerSize',15)
% 
% req4=Request(0,[50,150],0,1);
% plot(req4.position(1),req4.position(2),'b.','MarkerSize',15)
% 
% req5=Request(0,[200*rand,200*rand],0,1);
% plot(req5.position(1),req5.position(2),'b.','MarkerSize',15)
% 
% 
% reqList = [req1, req2,req3,req4,req5];

for c = 1:20
reqList(c) = Request(0,[200*rand,200*rand],0,2);
plot(reqList(c).position(1),reqList(c).position(2),'b.','MarkerSize',15);
end

manager = TestManager(reqList);


color = ['y', 'g','m'];

uav1 = UAVDrone(base.position,color(1),10,3,25,base,manager);
uav2 = UAVDrone(base.position,color(2),10,3,25,base,manager);
uav3 = UAVDrone(base.position,color(3),10,3,25,base,manager);
% Simulate time step
for c=1:35
    uav1.refresh(c);
    uav2.refresh(c);
    uav3.refresh(c);
end

axis([0,200,0,200])
title('UAV simulation test')
