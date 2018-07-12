function dist = Distance(pos1,pos2)
% Calculate distance between two points
    dist = sqrt(((pos1(1)-pos2(1))^2)+((pos1(2)-pos2(2)).^2));
    