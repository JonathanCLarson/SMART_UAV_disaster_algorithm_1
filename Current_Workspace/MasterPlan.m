%% MasterPlan
% Calls uavSim1 to perform multiple simulations

%Parameters:
clear; close all;
feet2pixRatio = 16.7;
uav = [2, 15, 3, 1]; % [number of UAV's, speed(mph),cargo load, flight time]
exprTime = 2;
zones = [RequestZone3([510,660],0.05,.5,exprTime); % Request object for drop zone 1
        RequestZone3([785,580],0.05,0.4,exprTime); % Request object for drop zone 2
        RequestZone3([1080,170],0.05,.6,exprTime); % Request object for drop zone 3
        RequestZone3([886, 68], 0.05, .4, exprTime); % Request object for drop zone 4
        RequestZone3([716, 235], 0.05, .5, exprTime); % Request object for drop zone 5
        RequestZone3([826, 328], 0.05, .4, exprTime)]'; % Request object for drop zone 6
   base = [130,285];
   duration = 12;
   %MAP=imread('TestRun2Map.png'); image(MAP)
    
   %axis=[0 900 100 450];
   %hold on
   color = ['r', 'b', 'k'];
   
  [numMet, per, numExp, wait, waitHi,manager]=uavSim1(uav, exprTime, zones, base, duration,feet2pixRatio);
  disp(numMet)
  disp(numExp)
   n=1;
   
   % Sensitivity analysis for expiration time and number of UAV's
   for c = 1:2
       uav(1) = c;
       for k = 1:4
           eTime(k) = k/2;
           for m=1:8
                [numComp(n), perComp(n), numExp(m), wait(n), waitHi(n),manager(n)]=uavSim1(uav, eTime(k), zones, base, duration,feet2pixRatio);
                n=n+1;
           end
       
           expired(c, k) = mean(numExp);
       end
       scatter(eTime,expired(c,:), 6, color(c))
       hold on
   end
   
   