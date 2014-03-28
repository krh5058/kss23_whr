classdef sectionFactory < handle
    properties
        debug = 0;
        cond
        task
    end
    
    methods
        %% Constructor
        function obj = sectionFactory(debug)
            obj.debug = debug;
        end
    end
end