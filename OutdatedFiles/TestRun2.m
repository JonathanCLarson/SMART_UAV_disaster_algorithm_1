function  RM =TestRun2(FM,RM,k,numreq)

%%  Test Run 1  Single Drop-Off of up to 2 Requests%% 
Rand=rand(numreq);
for i=1:numreq
    reqid=i;
    RM=RM.newrequest(FM,reqid,k,Rand(i,i))
    % 1. Extract active requests from the RequestLog 
    nopen=0;
    for c=1:RM.LastRequestID
        if RM.RequestLog(c,9)==0
            nopen=nopen+1;
            RM.ActiveRequest(nopen,1)=RM.RequestLog(c,1);
            RM.ActiveRequest(nopen,2)=RM.RequestLog(c,2);
            RM.ActiveRequest(nopen,3)=RM.RequestLog(c,3);
            RM.ActiveRequest(nopen,4)=RM.RequestLog(c,4);
            RM.ActiveRequest(nopen,5)=RM.RequestLog(c,5);
            RM.ActiveRequest(nopen,6)=RM.RequestLog(c,6);
            RM.ActiveRequest(nopen,7)=RM.RequestLog(c,7);
            RM.ActiveRequest(nopen,8)=RM.RequestLog(c,8);
            RM.ActiveRequest(nopen,9)=RM.RequestLog(c,9);
        end
        RM.NumActiveRequests=nopen;
     end
end

    % 2.  Compute HD(i,j) Distance from UAV i to Request j
    for i=1:FM.FleetSize
        for j=1:nopen
            HDI=HD(FM,RM);
        end
    end
    
  % 3. Define the Admissible Set and Compute the Total HD for each Admissible Assignemnt
    if nopen==1
        AdmissibleSet= [1 1; 1 2]  %assign open request 1 to UAV1 or open request 1 to UAV2
        THD(1,1)= HDI(1,1); % total distance if UAV1 responds
        THD(2,1)=HDI(2,1); % total distance if UAV 2 respnds
        I=1; % both distances are the same
    else
        AdmissibleSet=combnk(1:nopen,FM.FleetSize);
     for i=1:size(AdmissibleSet)
       THD(i,1)= HDI(1,AdmissibleSet(i,1))+HDI(2,AdmissibleSet(i,2));
     end
      [M,I] = min(THD);
    end
    
    % 4. Display map of UAV routes minimizing THD.

     plot([FM.UAV(1,8) RM.ActiveRequest(AdmissibleSet(I,1),4)+10],[FM.UAV(1,9) RM.ActiveRequest(AdmissibleSet(I,1),5)+10],'b');
     hold on
     plot([FM.UAV(2,8) RM.ActiveRequest(AdmissibleSet(I,2),4)],[FM.UAV(2,9) RM.ActiveRequest(AdmissibleSet(I,2),5)],'y');
end
