%% MasterPlan
% Calls uavSim1 to perform multiple simulations

%Parameters:
clear; close all;
uav = [3, 18, 3, 2];
exprTime = 2;
zones = [RequestZone2([510,660],0.08,.2,20); % Request object for drop zone 1
        RequestZone2([785,580],0.08,0.3,20); % Request object for drop zone 2
        RequestZone2([1080,170],0.08,.4,20); % Request object for drop zone 3
        RequestZone2([886, 68], 0.08, .4, 20); % Request object for drop zone 4
        RequestZone2([716, 235], 0.08, .3, 20); % Request object for drop zone 5
        RequestZone2([826, 328], 0.08, .3, 20)]'; % Request object for drop zone 6
   base = [130,285];
   duration = 12;
   %MAP=imread('TestRun2Map.png'); image(MAP)
    
   %axis=[0 900 100 450];
   %hold on
   color = ['r', 'b', 'k'];
   
  [~, per, numExp, ~, ~,~]=uavSim1(uav, exprTime, zones, base, duration);
   n=1;
   
   % Sensitivity analysis for expiration time and number of UAV's
   for c = 1:2
       uav(1) = c;
       for k = 1:4
           eTime(k) = k/2;
           for m=1:5
                [numComp(n), perComp(n), numExp(m), wait(n), waitHi(n),manager(n)]=uavSim1(uav, eTime(k), zones, base, duration);
                n=n+1;
           end
       
           expired(c, k) = mean(numExp);
       end
       scatter(eTime,expired(c,:), 6, color(c))
       hold on
   end
   
   