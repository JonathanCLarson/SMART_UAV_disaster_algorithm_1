%% MasterPlan
% Master file to run UAV simulations using the uavSim1 function
% The parameters can be manipulated to test various scenarios, and the
%   paths of the UAV's can be plotted for visual inspection (Plots not
%   recommended for more than one simulation)
% 
% Any map can be used if an appropriate image is supplied, and if the
%   request zone and kilometer to pixel ratio is inputted

% Gabriel Flores, Jonathan Larson, and Ted Townsend

clear; close all; clc;
% Create display of the map
% MAP=imread('TestRun2Map.png'); image(MAP) 
% axis=[0 900 100 450];
% hold on

%Parameters:
km2pixRatio = 0.00509;   % The ratio for converting kilometers to pixels
uav = [3, 40, 3, 15];    % UAV fleet specifications: [number of UAV's, speed(km/h),cargo load (units), range (km)]
exprTime = .5;           % How long it takes for the high priority request to expire (hours)
priFac = 1000;           % The priority factor by which low priority requests are reduced compared to high priority requests
timeFac = 0.95;          % Factor by which requests become more important over time (.95 -> 5% more important every hour)
zonesNewProb = .1*[1 1 1 1 1 1];    % Probability of a zone generating a new request on a given time step
zonesHiProb = .25*[1 1 1 1 1 1];    % Probability of a new request being high priority (per zone)

% Array of [x,y] locations for each request zone based on the map image
zoneLocations = [510,660;   % Zone 1
                 785,580;   % Zone 2
                 1080,170;  % Zone 3
                 886,68;    % Zone 4
                 716,235;   % Zone 5
                 826,328];  % Zone 6
             
% Create the Request Zone objects and store them in an array           
zones = RequestZone4.empty;
for c=1:length(zoneLocations)
    zones(c)=RequestZone4(zoneLocations(c,:),zonesNewProb(c),zonesHiProb(c),exprTime,priFac,timeFac,c);
end


% zones = [RequestZone4([510,660],zonesNewProb(1),zonesHiProb(1),exprTime,1);   % Request object for drop zone 1
%          RequestZone4([785,580],zonesNewProb(2),zonesHiProb(2),exprTime,2);   % Request object for drop zone 2
%          RequestZone4([1080,170],zonesNewProb(3),zonesHiProb(3),exprTime,3);  % Request object for drop zone 3
%          RequestZone4([886, 68], zonesNewProb(4), zonesHiProb(4), exprTime,4);% Request object for drop zone 4
%          RequestZone4([716, 235], zonesNewProb(5), zonesHiProb(5),exprTime,5);% Request object for drop zone 5
%          RequestZone4([826, 328],zonesNewProb(6),zonesHiProb(6), exprTime,6)]';% Request object for drop zone 6
base = [130,285];   % The [x,y] location of base
duration = 6;       % The duration of the simulation in hours

color = [ 'b','k','m','g','y','c','r','w']; % The colors to mark the lines
symbol = ['o','*','.','s','p','^','d','x','+']; % The symbols used to mark the graph

% Single Simulation  
% [~, ~, ~, ~, ~,manager]=uavSim1(uav, zones, base, priFac, duration,km2pixRatio);
% [total, zone, UAV] = analyze(manager);
% disp(total)
%% Multiple simulations    
% The first simulation will be the standard simulation to collect managers
% managerArray = Manager4.empty;
% numMet = zeros(10, 1);
% per = zeros(10, 1);
% numExp = zeros(10, 1);
% wait = zeros(10, 1);
% waitHi = zeros(10, 1);
%     for c = 1:10
%         [numMet(c),per(c),numExp(c),wait(c), waitHi(c), managerArray(c)] = uavSim1(uav, zones, base, priFac, duration,km2pixRatio);
%         
%     end
%     
% avgMet=mean(numMet)
% avgPercentage = mean(per)
% avgExpired = mean(numExp)
% avgWait=mean(wait)
% avgWaitHi = mean(waitHi);
uavTest = [3, 40, 3, 15];
% %% Cargo capacity simulations
% cNumEx = zeros(4,4);    % Matrix to store number of expired requests for cargo simulation
% uavTestc = uavTest;         % UAV fleet property array for cargo simulation
% figure(1)
% % Vary the number of UAV's
% for c = 1:4
%     uavTestc(1) = c;
%     % Vary the cargo capacity
%     for a = 1:4
%         cargo = a; % The cargo for the uav
%         uavTestc(3) = cargo;
%         for m = 1:20
%             [cNumComp(m), ~, cNumExpr(a,m), ~, ~,~]=uavSim1(uavTestc, zonesTest, base, priFac, duration,km2pixRatio);
%         end
%         cNumEx(c,a) = mean(cNumExpr(a,:));
%         
%     end
%     plot([1 2 3 4],cNumEx(c,:), [color(c),'-'],'Linewidth',2)
%         hold on
% end
% title('Cargo Simulation')
% xlabel('Cargo load')
% ylabel('Expired Requests')
% legend('1 UAV','2 UAVs', '3 UAVs', '4 UAVs')
% hold off
%            
% %% The simulation for the different expiration times
% eTime = zeros(4,8); % The time the requests expire
% eNumEx = zeros(4,8); % The number of expired requests for each trial (for this simulation
% uavTeste = uavTest;
% expiredE=zeros(4,8);
% figure(2)
% % Vary the number of UAV's
% for c=1:4
%     uavTeste(1)=c;
%     for k = 1:8
%         eTime(c,k) = k/4;
%         % Adjust expiration time (0.25-2 hours)
%         for g = 1:length(zones)
%             zonesTest(g).exprTime = eTime(c,k);
%         end
%         % Run several trials
%         for m=1:20
%              [numComp(n), perComp(n), numExpr(k,m), ~, ~,managers(n)]=uavSim1(uavTeste, zonesTest, base, priFac, duration,km2pixRatio);
%              n=n+1;
%         end       
%         expiredE(c,k) = mean(numExpr(k,:));
%     end
%     plot(eTime(c,:),expiredE(c,:), [color(c),'-'],'Linewidth',2)
%     hold on
% end
% title('Expiration Simulation')
% xlabel('Expiration Time (hours)')
% ylabel('Number Expired')
% legend('1 UAV','2 UAVs', '3 UAVs', '4 UAVs')
% hold off

%% The simulation for the different probabilities 
uavTestP = uavTest;
probsP = linspace(0.01, 0.2, 8); % The probability of a new request occuring
numMetTestP = zeros(8,20);       % Completed requests (per simulation)
numExpTestP = zeros(8,20);       % Expired requests (per simulation)
completedP = zeros(4,5);        % Completed requests (average)
expiredP = zeros(4,5);          % Expired requests (average)
figure(3)
hold on
% Adjust number of UAV's
for c=1:4
    uavTestP(1)=c;
    % Change probability of a new request at each request zone.
    for p = 1:8
        % Apply probability to each request zone
        for d = 1:length(zones)
            zones(d).exprTime = exprTime;
            zones(d).probNew = probsP(p);
        end
        % Run 20 simulations
        for m=1:20
            [numMetTestP(p,m), ~, numExpTestP(p,m), ~, ~,~]=uavSim1(uavTestP, zones, base, priFac, duration,km2pixRatio);
        end
        % Find averages from simulations
        expiredP(c,p)=mean(numExpTestP(p,:));
        completedP(c,p) = mean(numMetTestP (p,:));
    end
    % plot results
    figure(3)
    plot(probsP,expiredP(c,:),[color(c),'-'],'Linewidth',2)
    hold on
    figure(4)
    plot(probsP,completedP(c,:),[color(c),'-'],'Linewidth',2)
    hold on
end

figure(3) % Expired
title('Request Frequency Simulation-Expired')
xlabel('Probability of a new request')
ylabel('Requests Expired')
legend('1 UAV','2 UAVs','3 UAVs','4 UAVs','location','northwest')
hold off
figure(4) % Completed
title('Request Frequency Simulation-Completed')
xlabel('Probability of a new request')
ylabel('Requests Completed')
legend('1 UAV','2 UAVs','3 UAVs','4 UAVs','location','northwest')
hold off


%% High Priority Request frequency simulation
% Set parameters
uavTestH = uavTest;
probsH = linspace(0.1,0.6, 10); % The probability of a new request occuring
numMetTestH = zeros(8,20);      % Completed requests (per simulation)
numExpTestH = zeros(8,20);       % Expired requests (per simulation)
completedH = zeros(4,5);        % Completed requests (average)
expiredH = zeros(4,5);          % Expired requests (average)

% Adjust number of UAV's
for c=1:4
    uavTestH(1)=c;
    % Change probability of a high priority request at each request zone.
    for p = 1:10
        % Apply probability to each request zone
        for d = 1:length(zones)
            zones(d).exprTime = exprTime;
            zones(d).probNew = probsH(p);
        end
        % Run 20 simulations
        for m=1:20
            [numMetTestP(p,m), ~, numExpTestP(p,m), ~, ~,~]=uavSim1(uavTestH, zones, base, priFac, duration,km2pixRatio);
        end
        % Find averages from simulations
        expiredH(c,p)=mean(numExpTestP(p,:));
        completedH(c,p) = mean(numMetTestP (p,:));
    end
    % plot results
    figure(5)
    plot(probsH,expiredH(c,:),[color(c),'-'],'Linewidth',2)
    hold on
    figure(6)
    plot(probsH,completedH(c,:),[color(c),'-'],'Linewidth',2)
    hold on
end

figure(5) % Expired
title('High Priority Frequency Simulation-Expired')
xlabel('Probability of a High Priority Request')
ylabel('Requests Expired')
legend('1 UAV','2 UAVs','3 UAVs','4 UAVs','location','northwest')
hold off
figure(6) % Completed
title('High Priority Frequency Simulation-Completed')
xlabel('Probability of a High Priority Request')
ylabel('Requests Expired')
legend('1 UAV','2 UAVs','3 UAVs','4 UAVs','location','northwest')
hold off