function hd = HumanitarianDistance(request, uav)
% This tells what the distance is according to the humanitarian distance
%   function so that the UAV gets to the high priority requests first
% Inputs: 
%   request = The Request object (has priority, time factor, and position)
%   uav =     The UAV object (stores position)
% Output:
%   hd = The humanitarian distance between the request



% Calculate the priority factor using the request's type and time elapsed.
p = request.priority;
k = uav.manager.addedVal;
% Multiplication HD
hd = (1./p) * (Distance(uav.position, request.zone.position) + k);
% Geographic Distance
% hd=Distance(uav.position,request.zone.position);
% Addition HD
%hd = Distance(uav.position,request.zone.position)+(p);
end