function hdi = HD(FM,RM)
% This function computes the humanitarian distance from UAV i to Request j
for i=1:FM.FleetSize
    for j=1:RM.NumActiveRequests
       hdi(i,RM.ActiveRequest(j,1))=sqrt((FM.UAV(i,8)-RM.ActiveRequest(j,4))^2+(FM.UAV(i,9)-RM.ActiveRequest(j,5))^2)/FM.UAV(i,5)+(1 + 999*(RM.ActiveRequest(j,3)-1));
    end
end

