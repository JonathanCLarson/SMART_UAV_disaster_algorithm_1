function hd = HumanitarianDistance(request, uav)
% This tells what the distance is according to the humanitarian distance
% function so that the UAV gets to the high priority requests first
request.refresh(uav.time);
p = request.priority * 0.95^(request.timeElapsed);
% Multiplication HD
hd = p * (Distance(uav.position, request.zone.position) + 1);

% Addition HD
%hd = Distance(uav.position,request.zone.position)+(p);
end