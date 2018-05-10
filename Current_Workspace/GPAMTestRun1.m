%% Main Script for Puerto Rico / Ana Luisa Area UAV Disaster Cargo Fleet 
clear all; close all; format long;
%% SPECIFY RSPONSE REGION
 MAP=imread('TestRun1Map.png'); image(MAP); axis=[0 900 100 450]; hold on;  
 rect=[150 200 400 150]; % conversion: 1 map unit = .005 km
%% SIMULATION PARAMETERS
simstep=.25 % Number of hours per simulation step
k=15 % 1/k is mean number of hours between requests
fleetsize=2; %number of UAVs in fleet  1 backup
numberbases=1; % number of UAV bases servicing region
baselocation(1,1)=130; %x coordinate of base
baselocation(1,2)=285; % y-coordinate of base
numberdelivery=3;  % number of delivery locations
deliverylocation(1,1)=520; % x-coordinate of first delivery location
deliverylocation(1,2)=670; % y-coordinate of first delivery location
deliverylocation(2,1)=795; % x-coord of 2nd delivery location
deliverylocation(2,2)=580; % y-coord of 2nd delivery location
deliverylocation(3,1)=1070; % x-coord of 3rd delivery location
deliverylocation(3,2)=185; % y-coord of 3rd delivery lcoation
for i=1:fleetsize  %compute time needed to return to base from drop-off location j
    for j=1:numberdelivery
RT(i,j)=sqrt((deliverylocation(j,1)-baselocation(1,1))^2+(deliverylocation(j,2)-baselocation(1,2))^2)/50*i; %i=1 slow UAV return times; i=2 fast UAV times
    end
end

%% Specify Request Zone Probabilities
numberrequestzones=3; % number of request zones
pint=[0,.2,.21,.65;.65 .75,.95,1]; % probability intervals used for randomization of request zones
          % zone 1 HP [0,.2)     zone 2 HP [.2,.21), zone 3 HP [.21,.65), 
          % zone 1 LP [.65,.75)  zone 2 LP [.75,.95), zone 3 LP [.95,1] 
          
%% Specify UAVs in Fleet
% ith row is UAV i's [MaxBatteryLife(hrs), RemainingBatteryLife, AssignedRequestID,  TimeToRequest, Speed, MaxPayload(in kg),  Remainingpayload, xPosition, yPosition]
% RemainingBatteryLife = -t if t hrs charging time to full capacity; AssignedID = 0 if unassigned;
uav=[1 1 0 0 50 1 1 baselocation(1,1) baselocation(1,2);2 2 0 0 100 2 2  baselocation(1,1) baselocation(1,2) ];   

%% Construct Fleet Manager   (obj,RR,FS,NB,BL,ND,DL,UAVS, HPA,LPA)
AnaLuisaFleetManager=FLEETMANAGER;
AnaLuisaFleetManager=fleetmanager(AnaLuisaFleetManager,MAP,fleetsize,numberbases,baselocation,numberdelivery,deliverylocation,uav, [0], [0]); 

%% Construct New Request Manager (NumberRequestZones ProbIntervals RequestLog=[ID Time Priority x  y Zone Load(kg)  Assigned UAV, Time Completed] lastrequestID)
AnaLuisaRequestManager=REQUESTMANAGER; 
AnaLuisaRequestManager=requestmanager(AnaLuisaRequestManager,3,pint,[0 0 0 0 0 0 0 0  0],0);

%%  Test Run 1  Single Drop-Off Number of Requests = 1 or 2 (when more requests, slects HD closest two)%%
numreq=15; %number of requests
 AnaLuisaRequestManager=TestRun1(AnaLuisaFleetManager,AnaLuisaRequestManager,k,numreq)

