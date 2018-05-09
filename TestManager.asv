%%  TestManager
% manages tests for the driver class
classdef TestManager < handle
    
    properties

    requestList
    index
    end
    methods
        % Constructor, initialize index to 1 to assign first request
        
        function obj = TestManager(reqList)
            obj.requestList = reqList;
            obj.index = 2;
        end
        
        % Assignment function
        function uav = assign(manager,uav)
            nextRequest = manager.requestList(manager.index);
            uav.request=nextRequest;
            manager.index = manager.index + 1;
        end
        
    end
    
end

            


