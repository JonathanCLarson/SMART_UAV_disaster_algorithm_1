%% Analyze function for UAV simulation
% returns numerical results of the UAV simulation
% input: manager = UAV manager object to analyze

function  table = analyze(manager)
disp("# of completed requests: " + manager.requestsMet);

