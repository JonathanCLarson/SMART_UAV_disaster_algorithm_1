%% uavDriver
% Test driver for the UAVDrone class
% Creates requests for the drone to fulfill
close all
clear

base = Request(0,[0,0],1,1);
plot(base.position(1),base.position(2),'k.','MarkerSize',15)

hold on
req1= Request(0,[200,200],0,1);
plot(req1.position(1),req1.position(2),'b.','MarkerSize',15)

req2= Request(0,[100,200],0,1);
plot(req2.position(1),req2.position(2),'b.','MarkerSize',15)

req3=Request(0,[200,100],0,1);
plot(req3.position(1),req3.position(2),'b.','MarkerSize',15)

req4=Request(0,[50,150],0,1);
plot(req4.position(1),req4.position(2),'b.','MarkerSize',15)

req5=Request(0,[200*rand,200*rand],0,1);
plot(req5.position(1),req5.position(2),'b.','MarkerSize',15)


reqList = [req1, req2,req3,req4,req5];
manager = TestManager(reqList);




uav1 = UAVDrone(base.position,reqList(1),800,8,25,base,manager);
% Simulate time step
for c=1:25
    uav1=uav1.refresh(c);
end


title('UAV simulation test')
