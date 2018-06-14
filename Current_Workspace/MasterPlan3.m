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
clear; close all; %clc;
dbstop if error
% dbclear all
f=1; % figure counter
% Create display of the map
 MAP=imread('Map2.png'); image(MAP) 
 hold on

% Parameters:
% base = [130,285];                   % The [x,y] location of the base
base = [578,398];                   % For bigger PR map
% base = [1091,86];                   % Guatemala


numZones = 13;                      % The number of request zones
duration = 8;                       % The duration of the simulation in hours
km2pixRatio = 1.609/90;             % The ratio for converting kilometers to pixels (90 for map 2, 73 for Guatemala)
uav = [3, 40, 2, 35];               % UAV fleet specifications: [number of UAV's, speed(km/h),cargo load (units), range (km)]
uavTest=uav;                        % For testing
exprTime = .75*ones(numZones,1);    % How long it takes for the high priority request to expire (hours)
exDev = (1/6) * ones(numZones, 1);  % The standard deviation of expiration times (hours)
priFac = 1000;                      % The priority factor by which low priority requests are reduced compared to high priority requests
timeFac = 0.95;                     % Factor by which requests become more important over time (.95 -> 5% more important every hour)
zonesNewProb = .02*ones(numZones,1);% Probability of a zone generating a new request on a given time step
zonesHiProb = .25*ones(numZones,1); % Probability of a new request being high priority (per zone)
zonesHiProb(1) = 0.75;                % Increase probability of high requests in zone 1

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
                 939 735
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
             
zoneParam = [zoneLocations,zonesNewProb,zonesHiProb,exprTime, exDev]; 
    % Matrix where element (i,j) corresponds to request zone i, property j,
    %   where property 1 is the x-location, 2 is the y-location, 3 is the 
    %   new probability, etc.

color = [ 'b','k','m','g','y','c','r','w']; % The colors to mark the lines
symbol = ['o','*','.','s','p','^','d','x','+']; % The symbols used to mark the graph

%% Single Simulation  
[~, ~, ~, ~, manager]=uavSim3(uav, zoneParam, base, priFac,timeFac, duration,km2pixRatio);
overall=writeManagers(manager,'singleRun.xlsx');
[total] = analyze(manager);
disp(total)

%% Number of UAVs
% uavTestU=uav;
% numUAVs=1:6;
% numExpU=zeros(1,20);
% numCompU=zeros(1,20);
% expiredU=zeros(1,6);
% completedU=zeros(1,6);
% numHiU=zeros(1,20); % Number of high priority requests from a simulation
% lolp = zeros(1,6);
% compPerUAV=zeros(1,6);
% % 
% for c=1:length(numUAVs)
%     uavTestU(1)=c;
%     for m=1:20
%              [numCompU(m), numExpU(m), ~, ~,managersU]=uavSim3(uavTestU, zoneParam, base, priFac,timeFac, duration,km2pixRatio);
%              numHiU(m)=numExpU(m);
%              % Get number of HP requests
%              for k=1:length(managersU.completedList)
%                  if managersU.completedList(k).priority==1
%                      numHiU(m)=numHiU(m)+1;
%                  end
%              end
%              for k=1:length(managersU.requestZones)
%                  for n=1:length(managersU.requestZones(k).activeList)
%                      if managersU.requestZones(k).activeList(n).priority==1
%                          numHiU(m)=numHiU(m)+1;
%                      end
%                  end
%              end
%     end
%     expiredU(c)=mean(numExpU);
%     expiredStDev(c)=std(numExpU);
%     completedU(c)=mean(numCompU);
%     completedStDev(c)=std(numCompU);
%     % LOLP: extract total number of high priority requests
%     lolp(c)=mean(numExpU./numHiU);
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
% sNumEx = zeros(4,4);    % Matrix to store number of expired requests for cargo simulation
% sCompleted = zeros(4,4);
% uavTests = uavTest;     % UAV fleet property array for cargo simulation
% zonesTestS = zoneParam; % Zone array for tests
% sNumComp=zeros(20,1);
% sNumExpr=zeros(20,1);
% speeds = linspace(20, 100, 5);
% figure(f)
% hold on
% % Vary the number of UAV's
% ManagerS = Manager6.empty;
% n = 1;
% for c = 1:4
%     uavTests(1) = c;
%     % Vary the speed
%     for a = 1:5
%         uavTests(2) = speeds(a);
%         for m = 1:20
%             [sNumComp(m), sNumExpr(a,m), ~, ~,ManagerS(n)]=uavSim3(uavTests, zonesTestS, base, priFac,timeFac, duration,km2pixRatio);
%             n = n+1;
%         end
%         sNumEx(c,a) = mean(sNumExpr(a,:));
%         sCompleted(c,a)=mean(sNumComp);
%         
%     end
%     figure(f)
%     plot(speeds,sNumEx(c,:), [color(c),'-'],'Linewidth',2)
%     hold on
%     figure(f+1)
%     plot(speeds, sCompleted(c,:), [color(c),'-'], 'Linewidth',2)
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
% f=f+2;
%% Multiple simulations    
% The first simulation will be the standard simulation to collect managers 
% Outputs spreadsheet with overall and zone-specific results
% managerArray = Manager6.empty;
% numMet = zeros(10, 1);
% per = zeros(10, 1);
% numExp = zeros(10, 1);
% wait = zeros(10, 1);
% waitHi = zeros(10, 1);
% for c = 1:100
%         [numMet(c),numExp(c),wait(c), waitHi(c), managerArray(c)] = uavSim3(uav, zoneParam, base, priFac,timeFac, duration,km2pixRatio);
% end
% [overallMat,zoneMat]=writeManagers(managerArray,'testOutput.xlsx');
% 
% figure(f) % Expired
% histogram(wait,10)
% title('Wait Distribution')
% xlabel('Wait time')
% ylabel('Frequency of result')
% figure(f+1) % Completed
% histogram(waitHi,10)
% title('High Priority Wait Time Distribution')
% xlabel('Completed requests')
% ylabel('Frequency of result')
% f=f+2;
%     


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
%             [cNumComp(m), cNumExpr(m), ~, ~,~]=uavSim3(uavTestc, zonesTestC, base, priFac,timeFac, duration,km2pixRatio);
%         end
%         cNumEx(c,a) = mean(cNumExpr);
%         cCompleted(c,a)=mean(cNumComp);
%         
%     end
%     figure(f)
%     plot(cargo,cNumEx(c,:), [color(c),'.'],'MarkerSize',20)
%     hold on
%     figure(f+1)
%     plot(cargo,cCompleted(c,:),[color(c),'.'],'MarkerSize',20)
%     hold on
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
% f=f+1;
%% Range simulations
% rNumEx = zeros(1,10);    % Matrix to store number of expired requests for range simulation
% rNumComp = zeros(1,10);
% rNumRech = zeros(1,10);
% rNumRef = zeros(1,10);
% 
% uavTestR = uavTest;         % UAV fleet property array for range simulation
% zonesTest = zoneParam;
% 
% ranges = linspace(15,70,5);
% expiredR = zeros(4,5);
% completedR = zeros(4,5);
% 
% % Recharges and refills at base
% rechargesR = zeros(4,5);
% refillsR = zeros(4,5);
% 
% % Vary the number of UAV's
% for c = 1:4
%     uavTestR(1) = c;
%     % Vary the range
%     for a = 1:5
%         uavTestR(4) = ranges(a);
%         for m = 1:10
%             [rNumComp(a,m),rNumEx(a,m), ~, ~,~,rNumRech(a,m),~,rNumRef(a,m),~]=uavSim3(uavTestR, zonesTest, base, priFac,timeFac, duration,km2pixRatio);
%             
%         end
%         expiredR(c,a) = mean(rNumEx);
%         completedR(c,a)=mean(rNumComp);
%         rechargesR(c,a)=mean(rNumRech);
%         refillsR(c,a)=mean(rNumRef);
%         
%         
%     end
%     figure(f)
%     plot(ranges,expiredR(c,:), [color(c),'-'],'Linewidth',2)
%     hold on
%     figure(f+1)
%     plot(ranges,completedR(c,:), [color(c),'-'],'Linewidth',2)
%     hold on
%     figure(f+2)
%     plot(ranges,rechargesR(c,:), [color(c),'-'],'Linewidth',2)
%     hold on
%     plot(ranges,refillsR(c,:), [color(c),'--'],'Linewidth',2)
% end
% figure(f)
% title('Range Simulation')
% xlabel('Range')
% ylabel('Expired Requests')
% legend('1 UAV','2 UAVs', '3 UAVs', '4 UAVs')
% hold off
% figure(f+1)
% title('Range Simulation')
% xlabel('Range')
% ylabel('Completed Requests')
% legend('1 UAV','2 UAVs', '3 UAVs', '4 UAVs')
% hold off
% figure(f+2)
% title('Range Simulation')
% xlabel('Range')
% ylabel('Number of Refills/Recharges')
% %legend('1 UAV: Recharges','1 UAV: Total Refills','2 UAVs: Total Recharges','2 UAVs: TotalRefills', '3 UAVs: Total Recharges', '4 UAVs')
% hold off
% f=f+1;    
%% The simulation for the different expiration times
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
%              [~,  eNumEx(k,m), ~, ~,~]=uavSim3(uavTeste, testZones, base, priFac,timeFac, duration,km2pixRatio);             
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

%% The simulation for the different probabilities 
% zonesP = zoneParam;              % zone matrix for testing
% uavTestP = uavTest;
% probsP = linspace(0.01, 0.5, 10); % The probability of a new request occuring
% numMetTestP = zeros(10,20);       % Completed requests (per simulation)
% numExpTestP = zeros(10,20);       % Expired requests (per simulation)
% completedP = zeros(4,5);         % Completed requests (average)
% expiredP = zeros(4,5);           % Expired requests (average)
% hold on
% % Adjust number of UAV's
% for c=1:4
%     uavTestP(1)=c;
%     % Change probability of a new request at each request zone.
%     for p = 1:10
%         % Apply probability to each request zone
%         for d = 1:numZones
%             zonesP(3,d) = probsP(p);
%         end
%         % Run 20 simulations
%         for m=1:20
%             [numMetTestP(p,m),numExpTestP(p,m), ~, ~,~]=uavSim3(uavTestP, zonesP, base, priFac,timeFac, duration,km2pixRatio);
%         end
%         % Find averages from simulations
%         expiredP(c,p)=mean(numExpTestP(p,:));
%         completedP(c,p) = mean(numMetTestP (p,:));
%     end
%     % plot results
%     figure(f)
%     plot(probsP,expiredP(c,:),[color(c),'-'],'Linewidth',2)
%     hold on
%     figure(f+1)
%     plot(probsP,completedP(c,:),[color(c),'-'],'Linewidth',2)
%     hold on
% end
% 
% figure(f) % Expired
% 
% xlabel('Probability of a new request')
% ylabel('Requests Expired')
% legend('1 UAV','2 UAVs','3 UAVs','4 UAVs','location','northwest')
% hold off
% figure(f+1) % Completed
% 
% xlabel('Probability of a new request')
% ylabel('Requests Completed')
% legend('1 UAV','2 UAVs','3 UAVs','4 UAVs','location','northwest')
% hold off
% f=f+2;

%% High Priority Request frequency simulation
% % Set parameters
% uavTestH = uavTest;
% zonesTest=zoneParam;
% probsH = linspace(0.1,0.6, 10); % The probability of a new request occuring
% numMetTestH = zeros(8,20);      % Completed requests (per simulation)
% numExpTestH = zeros(8,20);       % Expired requests (per simulation)
% completedH = zeros(4,5);        % Completed requests (average)
% expiredH = zeros(4,5);          % Expired requests (average)
% 
% % Adjust number of UAV's
% for c=1:4
%     uavTestH(1)=c;
%     % Change probability of a high priority request at each request zone.
%     for p = 1:10
%         % Apply probability to each request zone
%         for d = 1:numZones

%             zonesTest(d,4)= probsH(p);
%         end
%         % Run 20 simulations
%         for m=1:20
%             [numMetTestP(p,m), numExpTestP(p,m), ~, ~,~]=uavSim3(uavTestH, zonesTest, base, priFac,timeFac, duration,km2pixRatio);
%         end
%         % Find averages from simulations
%         expiredH(c,p)=mean(numExpTestP(p,:));
%         completedH(c,p) = mean(numMetTestP (p,:));
%     end
%     % plot results
%     figure(f)
%     plot(probsH,expiredH(c,:),[color(c),'-'],'Linewidth',2)
%     hold on
%     figure(f+1)
%     plot(probsH,completedH(c,:),[color(c),'-'],'Linewidth',2)
%     hold on
% end
% 
% figure(f) % Expired
% title('High Priority Frequency Simulation-Expired')
% xlabel('Probability of a High Priority Request')
% ylabel('Requests Expired')
% legend('1 UAV','2 UAVs','3 UAV"s','4 UAVs','location','northwest')
% hold off
% figure(f+1) % Completed
% title('High Priority Frequency Simulation-Completed')
% xlabel('Probability of a High Priority Request')
% ylabel('Requests Completed')
% legend('1 UAV','2 UAVs','3 UAVs','4 UAVs','location','northwest')
% hold off
%f=f+2;
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
%             [NumCompD(a,m), NumExprD(a,m), ~, ~,~]=uavSim3(uavTestD, zonesTestD, base, priFac,timeFac, durTest,km2pixRatio);
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
% priNumEx = zeros(1,20); % The number of expired requests for each trial (for this simulation)
% priNumComp = zeros(1,20); % The number of Completed requests for each trial (for this simulation)
% priWait=zeros(1,20); % Wait time values
% priWaitHi=zeros(1,20); % Wait time values (high priority)
% uavTestpri = uavTest;
% expiredPri=zeros(4,10);
% completedPri=zeros(4,10);
% waitPri = zeros(4,10);
% waitHiPri = zeros(4,10);
% priority=linspace(1.00001,2,10);
% % Vary the number of UAV's
% for c=1:4
%     uavTestpri(1)=c;
%     for k = 1:10
% %         Run several trials
%         for m=1:5
%             [priNumComp(k,m),priNumEx(k,m), priWait(k,m), priWaitHi(k,m),priManager]=uavSim3(uavTestpri, zoneParam, base, priority(k),timeFac, duration,km2pixRatio);
%         end
% %         Find averages of trials
%         expiredPri(c,k) = mean(priNumEx(k,:));
%         completedPri(c,k)=mean(priNumComp(k,:));
%         waitPri(c,k)=mean(priWait(k,:));
%         waitHiPri(c,k)=mean(priWaitHi(k,:));
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
%     plot(priority,waitHiPri(c,:),[color(c),'-'],'Linewidth',2)   
%     hold on
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
% xlabel('Priority Factor')
% ylabel('Average wait time')
% legend('1 UAV','2 UAVs', '3 UAVs', '4 UAVs')
% hold off
% figure(f+3)
% xlabel('Priority Factor')
% ylabel('Average high priority wait time')
% legend('1 UAV','2 UAVs', '3 UAVs', '4 UAVs')
% hold off
% f=f+4;

%% Time factor tests

% tNumEx = zeros(5,10); % The number of expired requests for each trial (for this simulation)
% tNumComp = zeros(5,10); % The number of Completed requests for each trial (for this simulation)
% tWait=zeros(5,10); % Wait time values
% tWaitHi=zeros(5,10); % Wait time values (high priority)
% uavTestTF = uavTest;
% expiredTF=zeros(4,5);
% completedTF=zeros(4,5);
% waitTF = zeros(4,5);
% waitHiTF = zeros(4,5);
% tFactor=linspace(0.5,0.99,5);
% % Vary the number of UAV's
% for c=1:4
%     uavTestTF(1)=c;
%     for k = 1:5
%         % Run several trials
%         for m=1:10
%             [tNumComp(k,m),tNumEx(k,m), tWait(k,m), tWaitHi(k,m),priManager]=uavSim3(uavTestTF, zoneParam, base, priFac,tFactor(k), duration,km2pixRatio);
%         end
%         % Find averages of trials
%         expiredTF(c,k) = mean(tNumEx(k,:));
%         completedTF(c,k)=mean(tNumComp(k,:));
%         waitTF(c,k)=mean(tWait(k,:));
%         waitHiTF(c,k)=mean(tWaitHi(k,:));
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
%     plot(tFactor,waitHiTF(c,:),[color(c),'-'],'Linewidth',2) 
%     hold on
% end
% 
% figure(f)
% xlabel('Time Factor')
% ylabel('Number Expired')
% legend('1 UAV','2 UAVs', '3 UAVs', '4 UAVs')
% hold off
% figure(f+1)
% xlabel('Time Factor')
% ylabel('Number Completed')
% legend('1 UAV','2 UAVs', '3 UAVs', '4 UAVs')
% hold off
% 
% figure(f+2)
% xlabel('Time Factor')
% ylabel('Average wait time')
% legend('1 UAV','2 UAVs', '3 UAVs', '4 UAVs')
% hold off
% figure(f+3)
% xlabel('Time Factor')
% ylabel('Average high priority wait time')
% legend('1 UAV','2 UAVs', '3 UAVs', '4 UAVs')
% hold off
% f=f+4;

