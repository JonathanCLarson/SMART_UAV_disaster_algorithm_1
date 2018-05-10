classdef REQUESTMANAGER2
    % Creates and manages requests.
        
    properties
        NumberRequestZones % 
        PInt % Matrix defining probability intervals in which HP and LP requests occur
        RequestLog %ith row is [Priority Status,Location, Load, Time Requested, Assigned UAV, Time Completed]
        LastRequestID % Number of last request
        ActiveRequest % [requestID, time of request, priority, x, y, weight]
        NumActiveRequests % current number of active requests
       end
    
    methods
        function obj = requestmanager2(obj,NRZ,PI,RL,LRI)
            %Construct an instance of this class
            obj.NumberRequestZones=NRZ;
            obj.PInt=PI;
            obj.RequestLog=RL;
            obj.LastRequestID=LRI;
          end
        
        function obj = newrequest(obj,FM,reqid,k,Rand)  %% This function is used to generate new requests
            obj.LastRequestID=reqid;  %%update latest request number
             obj.RequestLog(reqid,1)=reqid;
            %% Update Request Time
            if reqid>1
            obj.RequestLog(reqid,2)=obj.RequestLog(reqid-1,2)+exprnd(k);  
            else
            obj.RequestLog(reqid,2)=exprnd(k);
            end
            
            %% Compute request zone 
            L=FM.NumberDelivery;  %number of delivery zones
               for i=1:2
                for j=1:L
                 if  obj.PInt(i,j) <= Rand && Rand < obj.PInt(i,j+1) % i=1 New LP request i=2 new LP request
                 obj.RequestLog(reqid,3)=1+ (i-1)*999; % HP=1; LP=1000
                 obj.RequestLog(reqid,4)=FM.DeliveryLocation(j,1);
                 obj.RequestLog(reqid,5)=FM.DeliveryLocation(j,2);
                 obj.RequestLog(reqid,6)=j; %%zone of request
                 obj.RequestLog(reqid,7)=.5; %% cargo requirement (kg)
                 obj.RequestLog(reqid,8)=0; %% UAV#
                 obj.RequestLog(reqid,9)=0; %% completion time
                 end
                   if obj.RequestLog(reqid,3)==1;
                  text(obj.RequestLog(reqid,4)+10*(reqid-1),obj.RequestLog(reqid,5)+50,strcat(' ',num2str(reqid)),'color','red','FontSize',25);
                  else
                  text(obj.RequestLog(reqid,4)+10*(reqid-1),obj.RequestLog(reqid,5)+50,strcat(' ',num2str(reqid)),'color','blue','FontSize',25);
                   end
                end
              end
                             
        end
    end
        
            
    
             
end

