classdef main < handle
% main.m class for WHR
    
    properties
        debug = 1;
        
        subjinfo
        condition = {'Lines','Bodies'};
        current_condition
        prac_block
        blocks = {'1','2','3','4','5','6'}
        current_block
        abort = 0;
        
        monitor
        path
        text
        keys
        keymap
        cbfeed = [zeros([5 1]); ones([5 1])]; % Counter-balance measures
        out
    end
    
    methods (Static)
        function d = listDirectory(path,varargin)
            % Search path with optional wildcards
            % path = search directory
            % varargin{1} = name filter
            % varargin{2} = extension filter
            
            narginchk(1,3);
            
            name = [];ext = [];
            
            vin = size(varargin,2);
            
            if vin==1
                name = varargin{1};
            elseif vin==2
                name = varargin{1};
                ext = varargin{2};
            end
            
            if ismac
                [~,d] = system(['ls ' path filesep '*' name '*' ext ' | xargs -n1 basename']);
            elseif ispc
                [~,d] = system(['dir /b "' path '"' filesep '*' name '*' ext]);
            else
                error('main.m (listDirectory): Unsupported OS.');
            end
        end
    end
    
    methods
         %% Constructor
         function obj = main(varargin)
             
             % Query user

                                      
         end
         
        %% Dispset
        function [monitor] = dispset(obj)
            if obj.debug
                % Find out how many screens and use lowest screen number (laptop screen).
                whichScreen = max(Screen('Screens'));
            else
                % Find out how many screens and use largest screen number (desktop screen).
                whichScreen = min(Screen('Screens'));
            end
            
            % Rect for screen
            rect = Screen('Rect', whichScreen);
            
            % Screen center calculations
            center_W = rect(3)/2;
            center_H = rect(4)/2;
            
            % ---------- Color Setup ----------
            % Gets color values.
            
            % Retrieves color codes for black and white and gray.
            black = BlackIndex(whichScreen);  % Retrieves the CLUT color code for black.
            white = WhiteIndex(whichScreen);  % Retrieves the CLUT color code for white.
            
            gray = (black + white) / 2;  % Computes the CLUT color code for gray.
            if round(gray)==white
                gray=black;
            end
            
            % Taking the absolute value of the difference between white and gray will
            % help keep the grating consistent regardless of whether the CLUT color
            % code for white is less or greater than the CLUT color code for black.
            absoluteDifferenceBetweenWhiteAndGray = abs(white - gray);
            
            % Data structure for monitor info
            monitor.whichScreen = whichScreen;
            monitor.rect = rect;
            monitor.center_W = center_W;
            monitor.center_H = center_H;
            monitor.black = black;
            monitor.white = white;
            monitor.gray = gray;
            monitor.absoluteDifferenceBetweenWhiteAndGray = absoluteDifferenceBetweenWhiteAndGray;
            
            obj.monitor = monitor;
            
        end
        
        %% Pathset
        function pathset(obj)
            try
                mainpath = which('main.m');
                if ~isempty(mainpath)
                    [mainext,~,~] = fileparts(mainpath);
                    rmpath(mainext);
                end
                
                javauipath = which('javaui.m');
                if ~isempty(javauipath)
                    [javauiext,~,~] = fileparts(javauipath);
                    rmpath(javauiext);
                end
                obj.path.bin = [obj.path.base filesep 'bin'];
                obj.path.out = [obj.path.base filesep 'out'];
                obj.path.content = [obj.path.base filesep 'content'];
                contentcell = {'general','pictures'}; % Add to cell for new directories in 'content'
                for i = 1:length(contentcell)
                    obj.path.(contentcell{i}) = [obj.path.content filesep contentcell{i}];
                end
            catch ME
                disp(ME);
            end
        end
        
        %% Expset
        function expset(obj)
            if obj.debug
                fprintf('main.m (expset): UI query for experimental parameters.\n');
            end
            
            frame = javaui(obj.blocks);
            waitfor(frame,'Visible','off'); % Wait for visibility to be off
            udInput = getappdata(frame,'UserData'); % Get frame data
            java.lang.System.gc();
            
            if isempty(udInput)
                error('main.m (expset): User Cancelled.');
            end
        end
        
    end
end