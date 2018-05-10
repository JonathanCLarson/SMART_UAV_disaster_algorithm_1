%%  TestManager
% manages tests for the driver class
classdef TestManager < handle
    
    properties

    requestList
    
    end
    methods
        % Constructor, initialize index to 1 to assign first request
        
        function obj = TestManager(reqList)
            obj.requestList = reqList;
            
        end
        
        % Assignment function
        function request = assign(manager)
            c = 1;
            while (c <= length(manager.requestList))
               if (manager.requestList(c).status > 1)
                nextRequest = manager.requestList(c);
                % exit the loop by skipping to the end
                c = length(manager.requestList);
               end
               c = c + 1;
            end
          request=nextRequest;
          request.status=1;
            
            %manager.index = manager.index + 1;
        end
        
    end
    
end

            


