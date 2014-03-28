classdef sectionFactory < handle
    properties
        debug = 0;
        
        cond
        task 
        list
        stim
        screens
        responseFilter
        
        displayIndex
    end
    
    methods
        %% Constructor task
        function obj = sectionFactory(debug,varargin)
            obj.debug = debug;
            if nargin == 7
                obj.cond = varargin{1};
                obj.task = varargin{2}; % judge, prac, block #
                obj.list = varargin{3}; % Variable cell based on task
                obj.stim = varargin{4}; % Required images with names
                obj.screens = varargin{5}; % Required images with names
                obj.responseFilter = varargin{6}; % Keymap to use
            else
                obj.displayIndex = varargin{1}; % Index during format to display
                obj.screens = varargin{2}; % Screens to display, in order
                obj.responseFilter = varargin{3}; % Keymap to use
            end
        end
    end
end