%% MasterPlan
% Calls uavSim1 to perform multiple simulations

%Parameters:
clear; close all;
feet2pixRatio = 16.7; % The ratio for converting feet to pixels
uav = [2, 15, 3, 1]; % [number of UAV's, speed(mph),cargo load, flight time]
exprTime = 1; % How long it takes for the high priority request to expire
zones = [RequestZone3([510,660],0.05,.5,exprTime); % Request object for drop zone 1
        RequestZone3([785,580],0.05,0.4,exprTime); % Request object for drop zone 2
        RequestZone3([1080,170],0.05,.6,exprTime); % Request object for drop zone 3
        RequestZone3([886, 68], 0.05, .4, exprTime); % Request object for drop zone 4
        RequestZone3([716, 235], 0.05, .5, exprTime); % Request object for drop zone 5
        RequestZone3([826, 328], 0.05, .4, exprTime)]'; % Request object for drop zone 6
   base = [130,285]; % The location of base
   duration = 8; % The duration of the simulation in hours
   %MAP=imread('TestRun2Map.png'); image(MAP)
    
   %axis=[0 900 100 450];
   %hold on
   color = ['r', 'b', 'k']; % The colors to mark the lines
   
  [numMet, per, numExp, wait, waitHi,manager]=uavSim1(uav, zones, base, duration,feet2pixRatio);
  disp(numMet)
  disp(numExp)
   n=1;
   
   % Sensitivity analysis for expiration time and number of UAV's 
   % The numbers will be changed in each test trial to yield multiple
   % results
%    for c = 1:2
%        uav(1) = c;

eTime = zeros(8,1);
numComp = zeros(64,1);
perComp = zeros(64,1);
numExpr = zeros(8,1);


%        for k = 1:8
%            eTime(k) = k/2;
%            for g = 1:length(zones)
%                zones(g).exprTime = eTime(k);
%            end
% 
%            for m=1:8
%                 [numComp(n), perComp(n), numExpr(m), ~, ~,managers(n,1)]=uavSim1(uav, zones, base, duration,feet2pixRatio);
%                 n=n+1;
%            end
%        
%            expired(k) = mean(numExpr);
%        end
%        scatter(eTime,expired, 6, 'b')
% %        hold on
% %    end
% %    
   