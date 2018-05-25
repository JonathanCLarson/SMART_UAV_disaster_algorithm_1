function hd = HumanitarianDistance(request, uav)
% This tells what the distance is according to the humanitarian distance
% function so that the UAV gets to the high priority requests first

% Calculate the priority factor using the request's type and time elapsed.
p = request.priority * (request.timeFac)^(request.timeElapsed);
% Multiplication HD
% hd = p * (Distance(uav.position, request.zone.position) + 1);

% Addition HD
hd = Distance(uav.position,request.zone.position)+(p);
end