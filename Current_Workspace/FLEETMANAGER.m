classdef FLEETMANAGER
    % Manages all aspects of the response fleet.
    
    properties
        ResponseRegion % map of area covered by the fleet
        FleetSize % number of UAVs in fleet
        NumberBases % number of bases in region (typically 1)
        BaseLocation % location of UAV base servicing region
        NumberDelivery % number of delivery locations in the region
        DeliveryLocation % supply drop off points
        UAV % ith row is UAV i's [remainingbatterylife(hrs), assignedrequestid, timetocomplete, speed, payloadcapacity(kg) remainingpayload x y] 
        HPAssignment % list of UAVs assigned to HP request
        LPAssignment % list of UAVs assigned to LP requests
    end
    
    methods
        function obj = fleetmanager(obj,RR,FS,NB,BL,ND,DL,UAVS, HPA,LPA)
                 obj.ResponseRegion=RR;
                 obj.FleetSize=FS;
                 obj.NumberBases=NB;
                 obj.BaseLocation=BL;
                 obj.NumberDelivery=ND;
                 obj.DeliveryLocation=DL;
                 obj.UAV=UAVS;
                 obj.HPAssignment=HPA;
                 obj.LPAssignment=LPA;
                 %% Plot Bases and Delivery Locations
                 obj.plotbaselocations(NB);
                 obj.plotdeliverylocations(ND);
        end
        
        function plotbaselocations(obj,NB)
             for i=1:NB
              text(obj.BaseLocation(i,1)-70,obj.BaseLocation(i,2)-45,strcat('UAVBASE',num2str(i)),'color','red','FontSize',25);
             end
            end
        
         function plotdeliverylocations(obj,ND)
           for i=1:ND
           text(obj.DeliveryLocation(i,1),obj.DeliveryLocation(i,2),strcat('X DROP OFF ',num2str(i)),'color','red','FontSize',20);
           end
         end
        
            function time = requesttime(requestmanager)
            % time(i,j) is time from UAV i to request j
            end
             
%             function drawroute(obj requestmanager)
%                 hold on
%                 plot([0 85.8024],[0.8736 1.2157],'r')
    end
end

