%% MasterPlan
% Calls uavSim1 to perform multiple simulations

%Parameters:
clear; close all;
km2pixRatio = 0.00509; % The ratio for converting feet to pixels
uav = [3, 40, 3, 15]; % [number of UAV's, speed(km/h),cargo load, range]
exprTime = 1; % How long it takes for the high priority request to expire
priFac = 1000; % The priority factory by which low priority requests are
% reduced compared to high priority requests

zones = [RequestZone4([510,660],.1,.25,exprTime); % Request object for drop zone 1
         RequestZone4([785,580],.1,0.5,exprTime); % Request object for drop zone 2
         RequestZone4([1080,170],.1,.5,exprTime); % Request object for drop zone 3
         RequestZone4([886, 68], .1, .5, exprTime); % Request object for drop zone 4
         RequestZone4([716, 235], .1, .5, exprTime); % Request object for drop zone 5
        RequestZone4([826, 328], .1, .5, exprTime)]'; % Request object for drop zone 6
base = [130,285]; % The location of base
duration = 4; % The duration of the simulation in hours
% MAP=imread('TestRun2Map.png'); image(MAP)
% axis=[0 900 100 450];
% hold on
color = ['r', 'b', 'k','m','g','y','c','w']; % The colors to mark the lines
symbol = ['o','*','s','p','^','d','x','+','.']; % The symbols used to mark the graph

   
[numMet, per, numExp, wait, waitHi,manager]=uavSim1(uav, zones, base, priFac, duration,km2pixRatio);
[total, zone, UAV] = analyze(manager);
disp(total)
%% Multiple simulations    
probs = linspace(0.01, 0.2, 5); % The probability of a new request occuring

numMetTest = zeros(1,5); % The number of requests met
perTest = zeros(1,5); % The percent of requests completed
numExpTest = zeros(1,5); % The number of expired requests
n=1; % The indices for our loops
q=1; % The indices for our loops
   
% Sensitivity analysis for expiration time and number of UAV's 
% The numbers will be changed in each test trial to yield multiple
% results
eTime = zeros(2,4); % The time the requests expire
numComp = zeros(1,32); % The number of requests completed
perComp = zeros(1,32); % The percent of the requests completed
numExpr = zeros(4,4); % The number of requests expired
expired = zeros(2,4); % The average expired over several trials 
managers = Manager4.empty; % The managers for the simulations
uavTest = uav; % The uav's for testing
zonesTest = zones; % The zones for testing
expiredProb = zeros(4,5); % the number expired from varying the probability of new requests
completedProb = zeros(4,5); % the number completed from varying the probability of new requests

%% This loop runs simulations by changing the number of uav's
for c = 1:8
    uavTest(1) = c;
    %% This loop runs simulations by changing the amount of cargo
    for a = 1:4
        cargo = a; % The cargo for the uav
        uavTest(3) = cargo; 
        for m = 1:10
            [cNumComp(m), cPerComp(m), cNumExpr(a,m), ~, ~,~]=uavSim1(uavTest, zonesTest, base, priFac, duration,km2pixRatio);
        end
        cNumEx = mean(cNumExpr(a,:));
        scatter(cargo,cNumEx, ['b',symbol(c)])
        hold on
    end
            
    %% The simulation for the different expiration times
%     for k = 1:4
%         eTime(c,k) = k/2;
%         for g = 1:length(zones)
%             zonesTest(g).exprTime = eTime(c,k);
%         end
% 
%         for m=1:4
%              [numComp(n), perComp(n), numExpr(k,m), ~, ~,managers(n)]=uavSim1(uavTest, zonesTest, base, priFac, duration,feet2pixRatio);
%              n=n+1;
%         end       
%         expired(c,k) = mean(numExpr(k,:));
%     end
%     figure(1)
%     scatter(eTime(c,:),expired(c,:), ['b',symbol(c)])
%     hold on
%% The simulation for the different probabilities 
%     for p = 1:5
%         for d = 1:length(zones)
%             zones(d).exprTime = exprTime;
%             zones(d).probNew = probs(p);
%         end
%         for m=1:3
%             [numMetTest(p,m), ~, numExpTest(p,m), ~, ~,manager]=uavSim1(uavTest, zones, base, priFac, duration,feet2pixRatio);
%         end
%     expiredProb(c,p)=mean(numExpTest(p,:));
%     completedProb(c,p) = mean(numMetTest (p,:));
%     figure(2)
%     scatter(probs(p),expiredProb(c,p),['r',symbol(c)])
%     hold on
%     scatter(probs(p),completedProb(c,p),['b',symbol(c)])
%     end
 end
figure(1)
title('Expiration Simulation')
xlabel('Expiration Time (hours)')
ylabel('Number Expired')
hold on
figure(2)
title('New Request Simulation')
xlabel('Probability of a new request')
ylabel('Number of requests')
legend('Number Expired','Number Completed','Location','northwest')
hold on
   