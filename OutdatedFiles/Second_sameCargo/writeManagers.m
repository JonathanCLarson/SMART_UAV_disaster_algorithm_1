%% writeManagers
function [overallMatrix,zoneMatrix,status1,status2] = writeManagers(managers,fileName)

% Function to write the data from an array of managers into an Excel file
%   for data analysis after performing UAV simulations
% 
% Input:
%   managers: A 1-D array of Manager5 objects created by calling the
%       uavSim1 function to run several simulations
%       NOTE: Since these objects are from the same set of simulations, they
%       have the same number of UAVs and request zones
%       NOTE: Length must be less than 
%   fileName: A character array for the file name for the Excel file
%       ex: 'Output.xlsx'
% Output: 
%   writes Excel file ('fileName')
%       Sheet 1: Overall data for each simulation
%       Sheet 2: Overall data for each request zone
%       Sheet 3: Overall data for the UAV fleet

%% Parameters
% Overall
n = length(managers);           % The number of managers
nZones = length(managers(1).requestZones); % Number of request zones
numCompleted = zeros(n,1);      % Number of completed requests
numExpired = zeros(n,1);        % Number of expired requests
avgWait = zeros(n,1);           % Average wait time for completed or expired requests
avgWaitHi = zeros(n,1);
avgWaitLow = zeros(n,1);
totalRecharges = zeros(n,1); % Number of times UAV battery was replaced
totalRestocks = zeros(n,1); % Number of times UAV cargo was restocked
totalRefills = zeros(n,1); % Total restocks + refuels
totalIdle = zeros(n,1); % Total amount of idle time spent by UAV's
numRedirects = zeros(n,1); % Total number of times UAV's were redirected
simLabels = cell(n,1);    
valueLabels = {'Completed','Expired','Average_Wait','High_Priority_Wait','Low_Priority_Wait','Recharges','Restocks','Refills','Idle_time','Redirects'};

% Zone data: entry (i,j) corresponds to requestZone i, from simulation j
zonesCompleted = zeros(nZones,n);
zonesExpired = zeros(nZones,n);
zonesWait = zeros(nZones,n);
zonesWaitHi = zeros(nZones,n);
zonesWaitLow = zeros(nZones,n);
zoneNames = cell(n*nZones,1);
zoneVariables = {'Completed', 'Expired', 'Average_wait','High_Priority_Wait','Low_Priority_Wait'};

%% Extract data
i=1;
for c=1:n
    % Extract data from managers
    [numCompleted(c), ~, numExpired(c), avgWait(c), avgWaitHi(c),avgWaitLow(c),zonesWait(:,c),zonesWaitHi(:,c),zonesWaitLow(:,c),totalRecharges(c),totalRestocks(c),totalRefills(c),totalIdle(c)] = analyze3(managers(c));
    numRedirects(c)= managers(c).numRedirect;
    simLabels{c} = char("Simulation " + c); % String of the Simulation label
    % Zone-specific data (separate for each zone)    
    for k=1:nZones
        zonesCompleted(k,c) =  managers(c).requestZones(k).completed;
        zonesExpired(k,c) = managers(c).requestZones(k).expired;
        zoneNames{i}=char("Simulation "+c+" Zone "+k);
        i=i+1;
    end

end
%% Build Matrices
overallMatrix = [numCompleted numExpired avgWait avgWaitHi avgWaitLow totalRecharges totalRestocks totalRefills totalIdle numRedirects];

zoneMatrix = zeros(n*nZones,length(zoneVariables));
% Build zone matrix
for m=1:(n*nZones)
    zoneMatrix(m,:)= [zonesCompleted(m),zonesExpired(m),zonesWait(m),zonesWaitHi(m),zonesWaitLow(m)];
end



%% Write Excel File
totMax = length(valueLabels);
totMaxChar = char(totMax+65);
range = ['B2:' totMaxChar int2str(n+1)];
% Write overall matrix
status1  = xlswrite(fileName,overallMatrix,'Overall',range);
% Add labels for columns and rows
xlswrite(fileName,valueLabels,'Overall',['B1:' totMaxChar '1']);
xlswrite(fileName,simLabels,'Overall',['A2:A' int2str(n+1)]);

zoneMax = length(zoneVariables);
zoneMaxChar = char(zoneMax+65);
rangeZone = ['B2:' zoneMaxChar int2str(n*nZones +1)];
status1=xlswrite(fileName,zoneMatrix,'Zones',rangeZone);
xlswrite(fileName,zoneVariables,'Zones',['B1:' zoneMaxChar '1']);
status2=xlswrite(fileName,zoneNames,'Zones',['A2:A' int2str(length(zoneNames)+1)]);




end