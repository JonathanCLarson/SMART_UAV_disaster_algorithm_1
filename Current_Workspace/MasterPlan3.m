%% MasterPlan
% Master file to run UAV simulations using the uavSim3 function
% The parameters can be manipulated to test various scenarios, and the
%   paths of the UAV's can be plotted for visual inspection (Plots not
%   recommended for more than one simulation)
% 
% Any map can be used if an appropriate image is supplied, and if the
%   request zone and kilometer to pixel ratio is inputted

% Gabriel Flores, Jonathan Larson, and Ted Townsend
% dbclear all
clear; close all; clc;
% dbstop if naninf
dbstop if error
% dbclear all
f=1; % figure counter
% Create display of the map
%   MAP=imread('Map2.png'); image(MAP) 
%   hold on

% Parameters:
% base = [130,285];                   % The [x,y] location of the base
base = [578,398];                   % For bigger PR map
% base = [1091,86];                   % Guatemala


numZones = 13;                      % The number of request zones
duration = 12;                      % STANDARD: 12 The duration of the simulation in hours
km2pixRatio = 1.609/90;             % The ratio for converting kilometers to pixels (90 for map 2, 73 for Guatemala)
uav = [3, 40, 2, 35];               % STANDARD: [3,40,2,35] UAV fleet specifications: [number of UAV's, speed(km/h),cargo load (units), range (km)]
uavTest=uav;                        % For testing
% exprTime = .75*ones(numZones,1);  % How long it takes for the high priority request to expire (hours)
exDev = (1/6) * ones(numZones, 1);  % The standard deviation of expiration times (hours)
priFac = 1;                       % The priority factor by which low priority requests are reduced compared to high priority requests
timeFac = 1/10;                        % Factor by which requests become more important over time (.95 -> 5% more important every hour)
addedVal = 1;
zonesXProb = .0035*ones(numZones,1);  % Probability of a new request being high priority (per zone) .0035
zonesYProb = .012*ones(numZones,1);  % Probability of a zone generating a new request on a given time step: .012

exprTimeX = ones(numZones,1);
exprTimeY = 3*ones(numZones,1);

% Array of [x,y] locations for each request zone based on the map image
% zoneLocations = [510,660;   % Zone 2
%                  785,580;   % Zone 2
%                  1080,170;  % Zone 3
%                  886,68;    % Zone 4
%                  716,235;   % Zone 5
%                  826,328];  % Zone 6

% Second Map:
zoneLocations = [276,715;
                 203 583;
                 221 303;
                 254 168;
                 404 193;
                 527 80;
                 776 95;
                 860 187;
                 1158 90;
                 1045 340;
                 794 550;
                 939 735;
                 635 728];
% Guatemala
% zoneLocations = [64,420;
%                  126,162;
%                  188,103;
%                  464,173;
%                  509,82;
%                  773,318;
%                  759,481;
%                  688,754];
             
zoneParam = [zoneLocations,zonesXProb,zonesYProb,exprTimeX,exprTimeY]; 
    % Matrix where element (i,j) corresponds to request zone i, property j,
    %   where property 1 is the x-location, 2 is the y-location, 3 is the 
    %   new X probability, 4 is new Y, etc.

color = [ 'b','k','m','g','y','c','r','w']; % The colors to mark the lines
symbol = ['o','*','.','s','p','^','d','x','+']; % The symbols used to mark the graph

%% Single Simulation  
% [~, ~, ~, ~,~, manager]=uavSim3(uav, zoneParam, base, priFac,timeFac,addedVal, duration,km2pixRatio);
% overall=writeManagers2(manager,'singleRun.xlsx');
% [total] = analyze(manager);
% disp(total)

%% Number of UAVs
% uavTestU=uav;
% numUAVs=1:6;
% numExpU=zeros(1,20);
% numCompU=zeros(1,20);
% expiredU=zeros(1,6);
% completedU=zeros(1,6);
% numReq=zeros(1,20); % Number of high priority requests from a simulation
% lolp = zeros(1,6);
% compPerUAV=zeros(1,6);
%  
% for c=1:length(numUAVs)
%     uavTestU(1)=c;
%     for m=1:20
%              [numCompU(m), numExpU(m), ~, ~, ~,managersU]=uavSim3(uavTestU, zoneParam, base, priFac,timeFac,addedVal, duration,km2pixRatio);
%              % Find total number of requests
%              numReq(m)=numExpU(m)+ numCompU(m); % Expired + Completed            
%              % Get number of active requests
%              for k=1:length(managersU.requestZones)
%                  numReq(m) = numReq(m)+length(managersU.requestZones(k).activeList);
%              end
%              
%     end
%     expiredU(c)=mean(numExpU);
%     expiredStDev(c)=std(numExpU);
%     completedU(c)=mean(numCompU);
%     completedStDev(c)=std(numCompU);
%     % LOLP: extract total number of high priority requests
%     lolp(c)=mean(numExpU./numReq);
%     compPerUAV(c) = completedU(c)/c;
% end
% figure(f)
% plot(numUAVs,expiredU)
% xlabel('Number of UAVs')
% ylabel('Expired requests')
% 
% figure(f+1)
% plot(numUAVs,completedU)
% xlabel('Number of UAVs')
% ylabel('Completed Requests')
% 
% figure(f+2)
% plot(numUAVs,lolp,'k.','MarkerSize',20)
% xlabel('Number of UAVs')
% ylabel('Proportion of HP requests that expired')
% figure(f+3)
% plot(numUAVs,compPerUAV,'k.','Markersize',20)
% xlabel('Number of UAVs')
% ylabel('Completed Requests/UAV')
% f=f+4;

%% Speed simulations
% numTrials = 20;
% sExpired =zeros(4,10);    % Matrix to store number of expired requests for cargo simulation
% sCompleted = zeros(4,10);
% sPercent = zeros(4,10);
% uavTests = uavTest;     % UAV fleet property array for cargo simulation
% zonesTestS = zoneParam; % Zone array for tests
% sNumComp=zeros(10,numTrials);
% sNumExpr = zeros(10,numTrials);
% sPerExp = zeros(10,numTrials);
% speeds = linspace(15, 60, 10);
% 
% % Vary the number of UAV's
% ManagerS = Manager6.empty;
% n = 1;
% for c = 1:4
%     uavTests(1) = c;
%     % Vary the speed
%     for a = 1:10
%         uavTests(2) = speeds(a);
%         for m = 1:numTrials
%             [sNumComp(a,m), sNumExpr(a,m),sPerExp(a,m), ~, ~,ManagerS(n)]=uavSim3(uavTests, zonesTestS, base, priFac,timeFac,addedVal, duration,km2pixRatio);
%             n = n+1;
%         end
%         sExpired(c,a) = mean(sNumExpr(a,:));
%         sCompleted(c,a)=mean(sNumComp(a,:));
%         sPercent(c,a) = mean(sPerExp(a,:));
%         
%     end
%     figure(f)
%     plot(speeds,sExpired(c,:), [color(c),'-'],'Linewidth',2)
%     hold on
%     figure(f+1)
%     plot(speeds, sCompleted(c,:), [color(c),'-'], 'Linewidth',2)
%     hold on
%     figure(f+2)
%     plot(speeds,sPercent(c,:),[color(c),'-'],'Linewidth',2)
%     hold on
% end
% 
% figure(f)
% xlabel('Speed')
% ylabel('Expired Requests')
% legend('1 UAV','2 UAVs', '3 UAVs', '4 UAVs')
% hold off
% figure(f+1)
% xlabel('Speed')
% ylabel('Completed Requests')
% legend('1 UAV', '2 UAVs', '3 UAVs', '4 UAVs')
% hold off
% figure(f+2)
% xlabel('Speed')
% ylabel('Percent of Requests Expired')
% legend('1 UAV', '2 UAVs', '3 UAVs', '4 UAVs')
% hold off
% f=f+2;
% 

%% Multiple simulations    
% The first simulation will be the standard simulation to collect managers 
% Outputs spreadsheet with overall and zone-specific results
% 
managerArray = Manager6.empty;
numMet = zeros(10, 1);
per = zeros(10, 1);
numExp = zeros(10, 1);
wait = zeros(10, 1);
waitHi = zeros(10, 1);
for c = 1:100
        [numMet(c),numExp(c),~, wait(c), waitHi(c), managerArray(c)] = uavSim3(uav, zoneParam, base, priFac,timeFac,addedVal, duration,km2pixRatio);
end
[overallMat,zoneMat]=writeManagers2(managerArray,'3UAV.xlsx');

% figure(f) % Expired
% histogram(wait,15)
% xlabel('Wait time')
% ylabel('Frequency of result')
% figure(f+1) % Completed
% histogram(waitHi,15)
% xlabel('X Wait time')
% ylabel('Frequency of result')
% figure(f+2)
% histogram(numMet,15)
% xlabel('Completed requests')
% ylabel('Frequency of result')
% figure(f+3)
% histogram(numExp,15)
% xlabel('Expired requests')
% ylabel('Frequency of result')
% f=f+2;


%% Cargo capacity simulations
% cNumEx = zeros(4,4);    % Matrix to store number of expired requests for cargo simulation
% cCompleted = zeros(4,4);
% uavTestc = uavTest;     % UAV fleet property array for cargo simulation
% zonesTestC = zoneParam; % Zone array for tests
% cNumComp=zeros(20,1);
% cNumExpr=zeros(20,1);
% figure(f)
% hold on
% % Vary the number of UAV's
% cargo=1:4;
% for c = 1:4
%     uavTestc(1) = c;
%     % Vary the cargo capacity
%     for a = 1:4
%         uavTestc(3) = cargo(a);
%         for m = 1:20
%             [cNumComp(m), cNumExpr(m), cPerExp, ~,~, ~]=uavSim3(uavTestc, zonesTestC, base, priFac,timeFac,addedVal, duration,km2pixRatio);
%         end
%         cNumEx(c,a) = mean(cNumExpr);
%         cCompleted(c,a)=mean(cNumComp);
%         cLOLP(c,a)=mean(cPerExp)
%         
%     end
%     figure(f)
%     plot(cargo,cNumEx(c,:), [color(c),'.'],'MarkerSize',20)
%     hold on
%     figure(f+1)
%     plot(cargo,cCompleted(c,:),[color(c),'.'],'MarkerSize',20)
%     hold on
%     figure(f+2)
%     plot(cargo,cLOLP,[color(c),'.'],'MarkerSize',20)
%     hold on
%       
%     
% end
% figure(f)
% xlabel('Cargo load')
% ylabel('Expired Requests')
% legend('1 UAV','2 UAVs', '3 UAVs', '4 UAVs')
% % Plot dots
% hold off
% figure(f+1)
% xlabel('Cargo load')
% ylabel('Completed Requests')
% legend('1 UAV','2 UAVs', '3 UAVs', '4 UAVs')
% % Plot dots
% hold off
% figure(f+2)
% xlabel('Cargo load')
% ylabel('Cargo LOLP')
% legend('1 UAV','2 UAVs', '3 UAVs', '4 UAVs')
% % Plot dots
% hold off
% f=f+1;

%% Range simulations
% rNumEx = zeros(1,20);    % Matrix to store number of expired requests for range simulation
% rNumComp = zeros(1,20);
% rPerEx = zeros(1,20);
% rNumRech = zeros(1,20);
% rNumRef = zeros(1,20);
% 
% uavTestR = uavTest;         % UAV fleet property array for range simulation
% zonesTest = zoneParam;
% 
% ranges = linspace(17,50,10);
% expiredR = zeros(4,length(ranges));
% completedR = zeros(4,length(ranges));
% percentR = zeros(4,length(ranges));
% % Recharges and refills at base
% rechargesR = zeros(4,length(ranges));
% refillsR = zeros(4,length(ranges));
% 
% % Vary the number of UAV's
% for c = 1:4
%     uavTestR(1) = c;
%     % Vary the range
%     for a = 1:length(ranges)
%         uavTestR(4) = ranges(a);
%         for m = 1:20
%             [rNumComp(m),rNumEx(m), rPerEx(m), ~, ~,~,rNumRech(m),~,rNumRef(m),~]=uavSim3(uavTestR, zonesTest, base, priFac,timeFac,addedVal, duration,km2pixRatio);            
%         end
%         percentR(c,a) = mean(rPerEx);
%         expiredR(c,a) = mean(rNumEx);
%         completedR(c,a)=mean(rNumComp);
%         rechargesR(c,a)=mean(rNumRech);
%         refillsR(c,a)  =mean(rNumRef);  
%     end
%     figure(f)
%     plot(ranges,expiredR(c,:), [color(c),'-'],'Linewidth',2)
%     hold on
%     figure(f+1)
%     plot(ranges,completedR(c,:), [color(c),'-'],'Linewidth',2)
%     hold on
%     figure(f+2)
%     subplot(2,1,1)
%     plot(ranges,rechargesR(c,:), [color(c),'-'],'Linewidth',2)
%     hold on
%     subplot(2,1,2)
%     plot(ranges,refillsR(c,:), [color(c),'-'],'Linewidth',2)
%     hold on
%     figure(f+3)
%     plot(ranges,percentR(c,:), [color(c),'-'],'LineWidth',2)
%     hold on
% end
% figure(f)
% xlabel('Range')
% ylabel('Expired Requests')
% legend('1 UAV','2 UAVs', '3 UAVs', '4 UAVs')
% hold off
% figure(f+1)
% xlabel('Range')
% ylabel('Completed Requests')
% legend('1 UAV','2 UAVs', '3 UAVs', '4 UAVs')
% hold off
% figure(f+2)
% subplot(2,1,1)
% xlabel('Range')
% ylabel('Number of Recharges')
% legend('1 UAV','2 UAVs', '3 UAVs', '4 UAVs')
% hold off
% subplot(2,1,2)
% xlabel('Range')
% ylabel('Number of Refills')
% legend('1 UAV','2 UAVs', '3 UAVs', '4 UAVs')
% hold off
% figure(f+3)
% xlabel('Range')
% ylabel('Percent Expired')
% legend('1 UAV','2 UAVs', '3 UAVs', '4 UAVs')
% hold off
% f=f+4;    

%% The simulation for the different expiration times: X expiration time
% eTime = zeros(4,8); % The time the requests expire
% eNumEx = zeros(8,20); % The number of expired requests for each trial (for this simulation
% uavTeste = uavTest;
% expiredE=zeros(4,8);
% testZones = zoneParam;
% 
% figure(f)
% % Vary the number of UAV's
% for c=1:4
%     uavTeste(1)=c;
%     for k = 1:8
%         eTime(c,k) = k/4;
%         % Adjust expiration time (0.25-2 hours)
%         for g = 1:numZones
%             testZones(g,5) = eTime(c,k);
%         end
%         % Run several trials
%         for m=1:20
%              [~,  eNumEx(k,m), ~, ~, ~,~]=uavSim3(uavTeste, testZones, base, priFac,timeFac,addedVal, duration,km2pixRatio);             
%         end       
%         expiredE(c,k) = mean(eNumEx(k,:));
%     end
%     plot(eTime(c,:),expiredE(c,:), [color(c),'-'],'Linewidth',2)
%     hold on
% end
% title('Expiration Simulation')
% xlabel('Expiration Time (hours)')
% ylabel('Number Expired')
% legend('1 UAV','2 UAVs', '3 UAVs', '4 UAVs')
% hold off
%% The simulation for the different expiration times: Y expiration time
% eTime = zeros(4,8); % The time the requests expire
% eNumEx = zeros(8,20); % The number of expired requests for each trial (for this simulation
% uavTeste = uavTest;
% expiredE=zeros(4,8);
% testZones = zoneParam;
% 
% figure(f)
% % Vary the number of UAV's
% for c=1:4
%     uavTeste(1)=c;
%     for k = 1:8
%         eTime(c,k) = k/4;
%         % Adjust expiration time (0.25-2 hours)
%         for g = 1:numZones
%             testZones(g,5) = eTime(c,k);
%         end
%         % Run several trials
%         for m=1:20
%              [~,  eNumEx(k,m), ~, ~, ~,~]=uavSim3(uavTeste, testZones, base, priFac,timeFac,addedVal, duration,km2pixRatio);             
%         end       
%         expiredE(c,k) = mean(eNumEx(k,:));
%     end
%     plot(eTime(c,:),expiredE(c,:), [color(c),'-'],'Linewidth',2)
%     hold on
% end
% title('Expiration Simulation')
% xlabel('Expiration Time (hours)')
% ylabel('Number Expired')
% legend('1 UAV','2 UAVs', '3 UAVs', '4 UAVs')
% hold off
%% Simulation for number of requests
% The simulation for the different number of requests entered 
% zonesR = zoneParam;              % zone matrix for testing
% uavTestR = uavTest;
% numTrials = 20;
% standard = [0.0035 0.012];          % Standard probability values
% ratios= linspace(0.5, 2, 10); % The probability of a new request occuring
% probsR = cell(4,10);           % Stores ratios
% numReqs = zeros(1,numTrials);
% numMetTestR = zeros(1,numTrials);       % Completed requests (per simulation)
% numExpTestR = zeros(1,numTrials);       % Expired requests (per simulation)
% completedR = zeros(4,10);         % Completed requests (average)
% expiredR = zeros(4,10);           % Expired requests (average)
% requestsR = zeros(4,10);
% managers = Manager6.empty;
% n=1;
% % Adjust number of UAV's
% for c=1:4
%     uavTestR(1)=c;
%     % Change probability of a new request at each request zone.
%     for p = 1:10
%         probsR{c,p} = ratios(p).* standard;
%         % Apply probability to each request zone
%         for d = 1:numZones
%             zonesR(d,3:4) = probsR{c,p};            
%         end
%         % Run 20 simulations
%         for m=1:numTrials
%             [numMetTestR(m),numExpTestR(m), ~, ~, ~,managers(n)]=uavSim3(uavTestR, zonesR, base, priFac,timeFac,addedVal, duration,km2pixRatio);
% 
%             [xReq,yReq] = managers(n).getNumRequests();
%             numReqs(m)=xReq+yReq;
%             n=n+1;
%         end
%         % Find averages from simulations
%         expiredR(c,p)=mean(numExpTestR);
%         completedR(c,p) = mean(numMetTestR );
%         requestsR(c,p) = mean(numReqs);
%     end
%     % plot results
%     figure(f)
%     plot(requestsR(c,:),expiredR(c,:),[color(c),'-'],'Linewidth',2)
%     hold on
%     figure(f+1)
%     plot(requestsR(c,:),completedR(c,:),[color(c),'-'],'Linewidth',2)
%     hold on
% end
% 
% figure(f) % Expired
% 
% xlabel('Number of requests')
% ylabel('Requests Expired')
% legend('1 UAV','2 UAVs','3 UAVs','4 UAVs','location','northwest')
% hold off
% 
% figure(f+1) % Completed
% xlabel('Number of requests')
% ylabel('Requests Completed')
% legend('1 UAV','2 UAVs','3 UAVs','4 UAVs','location','northwest')
% hold off
% 
% f=f+2;

%% The simulation for the different probabilities of Y requests
% zonesY = zoneParam;              % zone matrix for testing
% uavTestY = uavTest;
% numTrials = 20;
% probsY= linspace(0.0001, 0.03, 10); % The probability of a new request occuring
% numMetTestY = zeros(numTrials,1);       % Completed requests (per simulation)
% numExpTestY = zeros(numTrials,1);       % Expired requests (per simulation)
% reqY = zeros(numTrials,1);
% completedY = zeros(4,10);         % Completed requests (average)
% expiredY = zeros(4,10);           % Expired requests (average)
% requestsY = zeros(4,10);
% % Adjust number of UAV's
% for c=1:4
%     uavTestY(1)=c;
%     % Change probability of a new request at each request zone.
%     for p = 1:10
%         % Apply probability to each request zone
%         for d = 1:numZones
%             zonesY(d,4) = probsY(p);
%         end
%         % Run 20 simulations
%         for m=1:numTrials
%             [numMetTestY(m),numExpTestY(m), ~, ~, ~,manager]=uavSim3(uavTestY, zonesY, base, priFac,timeFac,addedVal, duration,km2pixRatio);
%             [~,reqY(m)] = manager.getNumRequests();
%         end
%         % Find averages from simulations
%         expiredY(c,p)=mean(numExpTestY);
%         completedY(c,p) = mean(numMetTestY);
%         requestsY(c,p) = mean(reqY);
%     end
%     % plot results
%     figure(f)
%     plot(requestsY(c,:),expiredY(c,:),[color(c),'-'],'Linewidth',2)
%     hold on
%     figure(f+1)
%     plot(requestsY(c,:),completedY(c,:),[color(c),'-'],'Linewidth',2)
%     hold on
% end
% figure(f) % Expired
% 
% xlabel('Number of Y requests')
% ylabel('Requests Expired')
% legend('1 UAV','2 UAVs','3 UAVs','4 UAVs','location','northwest')
% hold off
% figure(f+1) % Completed
% xlabel('Number of Y requests')
% ylabel('Requests Completed')
% legend('1 UAV','2 UAVs','3 UAVs','4 UAVs','location','northwest')
% hold off
% f=f+2;

%% Type X Request frequency simulation
% % Set parameters
% numTrials = 20;
% uavTestX = uavTest;
% zonesTest=zoneParam;
% reqX = zeros(1,numTrials);        % Number of X requests
% probsX = linspace(0.0001,0.01, 10);   % The probability of a new request occuring
% numMetTestX = zeros(1,numTrials); % Completed requests (per simulation)
% numExpTestX = zeros(1,numTrials); % Expired requests (per simulation)
% completedX = zeros(4,10);          % Completed requests (average)
% expiredX = zeros(4,10);            % Expired requests (average)
% requestsX = zeros(4,10); 
% 
% % Adjust number of UAV's
% for c=1:4
%     uavTestX(1)=c;
%     % Change probability of a high priority request at each request zone.
%     for p = 1:10
%         % Apply probability to each request zone
%         for d = 1:numZones
%             zonesTest(d,3)= probsX(p);
%         end
%         % Run 20 simulations
%         for m=1:numTrials
%             [numMetTestX(p,m), numExpTestX(p,m),~, ~, ~,manager]=uavSim3(uavTestX, zonesTest, base, priFac,timeFac,addedVal, duration,km2pixRatio);
%             [reqX(m),~] = manager.getNumRequests();
%         end
%         % Find averages from simulations
%         expiredX(c,p)=mean(numExpTestX(p,:));
%         completedX(c,p) = mean(numMetTestX (p,:));
%         requestsX(c,p) = mean(reqX);
%     end
%     % plot results
%     figure(f)
%     plot(requestsX(c,:),expiredX(c,:),[color(c),'-'],'Linewidth',2)
%     hold on
%     figure(f+1)
%     plot(requestsX(c,:),completedX(c,:),[color(c),'-'],'Linewidth',2)
%     hold on  
% end
% 
% figure(f) % Expired
% xlabel('Number of X Requests')
% ylabel('Requests Expired')
% legend('1 UAV','2 UAVs','3 UAV"s','4 UAVs','location','northwest')
% hold off
% figure(f+1) % Completed
% xlabel('Number of X requests')
% ylabel('Requests Completed')
% legend('1 UAV','2 UAVs','3 UAVs','4 UAVs','location','northwest')
% hold off
% f=f+2;

%% Request type ratio simulation
% Change distribution of request types, and keep number of requests
% approximately constant
% Set parameters
% numTrials = 20;
% uavTestRat = uavTest;
% zonesTest=zoneParam;
% reqRat = zeros(1,numTrials);        % Number of X requests
% totStandard = 0.0155;
% probsRat = linspace(0.05,.95,20);   % The probability of a new request occuring
% numMetTestRat = zeros(1,numTrials); % Completed requests (per simulation)
% numExpTestRat = zeros(1,numTrials); % Expired requests (per simulation)
% completedRat = zeros(4,20);          % Completed requests (average)
% expiredRat = zeros(4,20);            % Expired requests (average)
% requestsRat = zeros(4,20); 
% 
% % Adjust number of UAV's
% for c=1:4
%     uavTestRat(1)=c;
%     % Change probability of a high priority request at each request zone.
%     for p = 1:20
%         propX = probsRat(p); % Proportion of X requests
%         propY = 1-probsRat(p); % Proportion of Y requests
%         % Apply probability to each request zone
%         for d = 1:numZones
%             zonesTest(d,3:4) = [propX*totStandard,propY*totStandard];
%         end
%         % Run 20 simulations
%         for m=1:numTrials
%             [numMetTestRat(p,m), numExpTestRat(p,m),~, ~, ~,manager]=uavSim3(uavTestRat, zonesTest, base, priFac,timeFac,addedVal, duration,km2pixRatio);
%             [numX,numY] = manager.getNumRequests();
%             reqRat(m) = numX/(numX+numY);
%         end
%         % Find averages from simulations
%         expiredRat(c,p)=mean(numExpTestRat(p,:));
%         completedRat(c,p) = mean(numMetTestRat (p,:));
%         requestsRat(c,p) = mean(reqRat);
%     end
%     % plot results
%     figure(f)
%     plot(requestsRat(c,:),expiredRat(c,:),[color(c),'-'],'Linewidth',2)
%     hold on
%     figure(f+1)
%     plot(requestsRat(c,:),completedRat(c,:),[color(c),'-'],'Linewidth',2)
%     hold on  
% end
% 
% figure(f) % Expired
% xlabel('Proportion of X Requests')
% ylabel('Requests Expired')
% legend('1 UAV','2 UAVs','3 UAV"s','4 UAVs','location','northwest')
% hold off
% figure(f+1) % Completed
% xlabel('Proportion of X requests')
% ylabel('Requests Completed')
% legend('1 UAV','2 UAVs','3 UAVs','4 UAVs','location','northwest')
% hold off
% f=f+2;

%% Duration Simulation (Simulate effect of longer simulations)
% uavTestD = uavTest;
% zonesTestD = zoneParam; % Zone array
% % Vary the number of UAV's
% for c = 1:4
%     uavTestD(1) = c;
%     % Vary the simulation length
%     for a = 1:13
%         durTest = a+3;    % Duration variable to test
%         for m = 1:20     % Run several simulations
%             [NumCompD(a,m), NumExprD(a,m), ~, ~, ~,~]=uavSim3(uavTestD, zonesTestD, base, priFac,timeFac, addedVal,durTest,km2pixRatio);
%         end
%         NumExD(c,a) = mean(NumExprD(a,:));
%         NumCompletedD(c,a) = mean(NumCompD(a,:));
%         exPerHrD(c,a)=NumExD(c,a)/durTest; % Average expired per hour
%         comPerHrD(c,a)=NumCompletedD(c,a)/durTest; % Average completed per hour
%         
%     end
%     figure(f) % Expired
%     plot((4:16),exPerHrD(c,:), [color(c),'-'],'Linewidth',2)
%     hold on
%     figure(f+1) % Completed
%     plot((4:16),comPerHrD(c,:), [color(c),'-'],'Linewidth',2)
%     hold on
% end
% figure(f)
% title('Duration Simulation-Expired')
% xlabel('Duration length (hours)')
% ylabel('Expired Requests per hour')
% legend('1 UAV','2 UAVs', '3 UAVs', '4 UAVs')
% hold off
%            
% figure(f+1)
% title('Duration Simulation-Completed')
% xlabel('Duration length (hours)')
% ylabel('Completed Requests per hour')
% legend('1 UAV','2 UAVs', '3 UAVs', '4 UAVs','location','northwest')
% hold off
% f=f+2;
%% Priority Factor tests
% 
% numTrials = 20;
% priNumEx = zeros(1,numTrials); % The number of expired requests for each trial (for this simulation)
% priNumComp = zeros(1,numTrials); % The number of Completed requests for each trial (for this simulation)
% priWait=zeros(1,numTrials); % Wait time values
% priTimeLeft=zeros(1,numTrials); % Wait time values (high priority)
% uavTestpri = uavTest;
% expiredPri=zeros(4,10);
% completedPri=zeros(4,10);
% waitPri = zeros(4,10);
% timeLeftPri = zeros(4,10);
% priority=linspace(1,1000,10);
% % Vary the number of UAV's
% for c=1:4
%     uavTestpri(1)=c;
%     for k = 1:10
% %         Run several trials
%         for m=1:numTrials
%             [priNumComp(m),priNumEx(m), ~, priWait(m),priTimeLeft(m),priManager]=uavSim3(uavTestpri, zoneParam, base, priority(k),timeFac, addedVal,duration,km2pixRatio);
%         end
% %         Find averages of trials
%         expiredPri(c,k) = mean(priNumEx);
%         completedPri(c,k)=mean(priNumComp);
%         waitPri(c,k)=mean(priWait);
%         timeLeftPri(c,k)=mean(priTimeLeft);
%     end
%     figure(f)
%     plot(priority,expiredPri(c,:), [color(c),'-'],'Linewidth',2)
%     hold on
%     figure(f+1)
%     plot(priority,completedPri(c,:), [color(c),'-'],'Linewidth',2)
%     hold on
%     figure(f+2)
%     plot(priority,waitPri(c,:),[color(c),'-'],'Linewidth',2)
%     hold on
%     figure(f+3)
%     plot(priority,timeLeftPri(c,:),[color(c),'-'],'Linewidth',2)
%     hold on
%     
% end
% 
% figure(f)
% xlabel('Priority Factor')
% ylabel('Number Expired')
% legend('1 UAV','2 UAVs', '3 UAVs', '4 UAVs')
% hold off
% figure(f+1)
% xlabel('Priority Factor')
% ylabel('Number Completed')
% legend('1 UAV','2 UAVs', '3 UAVs', '4 UAVs')
% hold off
% 
% figure(f+2)
% xlabel('Priority Factor -Linear')
% ylabel('Average wait time')
% legend('1 UAV','2 UAVs', '3 UAVs', '4 UAVs')
% hold off
% figure(f+3)
% xlabel('Priority Factor -Linear')
% ylabel('Average time left')
% legend('1 UAV','2 UAVs', '3 UAVs', '4 UAVs')
% hold off
% f=f+4;

%% Time factor tests
% numTrials = 20;
% tNumEx = zeros(1,numTrials); % The number of expired requests for each trial (for this simulation)
% tNumComp = zeros(1,numTrials); % The number of Completed requests for each trial (for this simulation)
% tWait=zeros(1,numTrials); % Wait time values
% tTimeLeft=zeros(1,numTrials); % Wait time values (high priority)
% uavTestTF = uavTest;
% expiredTF=zeros(4,5);
% completedTF=zeros(4,5);
% waitTF = zeros(4,5);
% timeLeftTF = zeros(4,5);
% tFactor=linspace(0.1,.25,5);
% % Vary the number of UAV's
% for c=1:4
%     uavTestTF(1)=c;
%     for k = 1:5
%         % Run several trials
%         for m=1:numTrials
%             [tNumComp(m),tNumEx(m), ~, tWait(m), tTimeLeft(m),priManager]=uavSim3(uavTestTF, zoneParam, base, priFac,tFactor(k), addedVal,duration,km2pixRatio);
%         end
%         % Find averages of trials
%         expiredTF(c,k) = mean(tNumEx);
%         completedTF(c,k)=mean(tNumComp);
%         waitTF(c,k)=mean(tWait);
%         timeLeftTF(c,k)=mean(tTimeLeft);
%     end
%     figure(f)
%     plot(tFactor,expiredTF(c,:), [color(c),'-'],'Linewidth',2)
%     hold on
%     figure(f+1)
%     plot(tFactor,completedTF(c,:), [color(c),'-'],'Linewidth',2)
%     hold on
%     figure(f+2)
%     plot(tFactor,waitTF(c,:),[color(c),'-'],'Linewidth',2)
%     hold on
%     figure(f+3)
%     plot(tFactor,timeLeftTF(c,:),[color(c),'-'],'Linewidth',2) 
%     hold on
% end
% 
% figure(f)
% xlabel('Time Factor-Linear')
% ylabel('Number Expired')
% legend('1 UAV','2 UAVs', '3 UAVs', '4 UAVs')
% hold off
% figure(f+1)
% xlabel('Time Factor-Linear')
% ylabel('Number Completed')
% legend('1 UAV','2 UAVs', '3 UAVs', '4 UAVs')
% hold off
% 
% figure(f+2)
% xlabel('Time Factor-Linear')
% ylabel('Average wait time')
% legend('1 UAV','2 UAVs', '3 UAVs', '4 UAVs')
% hold off
% figure(f+3)
% xlabel('Time Factor-Linear')
% ylabel('Average high priority wait time')
% legend('1 UAV','2 UAVs', '3 UAVs', '4 UAVs')
% hold off
% f=f+4;

