%% uavDriver
% Test driver for the UAV simulation
% Simulates the UAV over the desired map
% Calls the UAVSim3 file to run a simulation
%close all;
clear; format long;

%% Parameters
% General parameters
% Read in map for background of graph, use file name of image for map.
MAP=imread('Map2.png'); image(MAP);
hold on
base = [578,398];   % Location of the base (x,y) on the simulation map
duration = 6;      % Duration of the simulation (hours)
km2pixRatio = 1.609/90; % Number of pixels in one kilometer on the map (converted from miles)

% UAV Parameters
numUAVs = 3; % The number of UAV's in the fleet
uavSpeed = 40; % in km/h
uavRange = 35; % in hrs
uavCap = 2; % Drone capacity 
uavVector = [numUAVs,uavSpeed,uavCap,uavRange];

% Request/requestzone parameters
numZones = 13;
exDev = (1/6) * ones(numZones, 1);  % The standard deviation of expiration times (hours)
priFac = 1;                         % The maximum value of the priority factor (does not effect results)
timeFac = 1/10;                     % Factor by which requests become more important over time (.95 -> 5% more important every hour)
addedVal = 1;                       % Value added to distance in HD function (low sensitivity)
zonesXProb = .0035*ones(numZones,1); % Probability of a new request being high priority (per zone) .0035
zonesYProb = .012*ones(numZones,1);  % Probability of a zone generating a new request on a given time step: .012

exprTimeX = ones(numZones,1);       % Mean expiration time for X requests
exprTimeY = 3*ones(numZones,1);     % Mean expiration time for Y requests
% (x,y) locations of zone delivery locations (in pixels) on the simulation map
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
zoneParam = [zoneLocations,zonesXProb,zonesYProb,exprTimeX,exprTimeY]; 

%% Run Simulation
% Run the simulation and display UAV paths
[~, ~, ~, ~,~, manager]=uavSim3(uavVector, zoneParam, base, priFac,timeFac,addedVal, duration,km2pixRatio);
% Write an excel file and display a table of results
overall=writeManagers2(manager,'simulationResult.xlsx');
[total] = analyze(manager); 
disp(total)

