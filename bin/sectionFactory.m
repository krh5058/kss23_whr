classdef sectionFactory < handle
    properties
        debug = 0;
        abort = 0;
        monitor
        timing
        
        cond
        task 
        list
        headers
        stim
        screens
        responseFilter
        
        displayIndex
        
        presObj
    end
    
    methods
        %% Constructor
        function obj = sectionFactory(debug,monitor,varargin)
            obj.debug = debug;
            obj.monitor = monitor;
            
            if length(varargin)==7
                obj.cond = varargin{1};
                obj.task = varargin{2}; % judge, prac, block #
                obj.list = varargin{3}(2:end,:); % Variable cell based on task
                obj.headers = varargin{3}(1,:); % Headers
                obj.stim = varargin{4}; % Required images with names
                obj.screens = varargin{5}; % Required images with names
                obj.responseFilter = varargin{6}; % Keymap to use
                obj.timing = varargin{7};
            else
                obj.displayIndex = varargin{1}; % Index during format to display
                obj.screens = varargin{2}; % Screens to display, in order
                obj.responseFilter = varargin{3}; % Keymap to use
            end
        end
        
        function loadPresObj(obj,presObj)
           obj.presObj = presObj; 
        end
        
        function run(obj)
            RestrictKeysForKbCheck([obj.responseFilter]);
            switch obj.task
                case 'judge'
                    for i = 1:length(obj.list)
                        [tex1] = obj.presObj.mkimg(obj.monitor.w,obj.screens{1,2}); % Judgment trial screen
                        [tex2] = obj.presObj.mkimg(obj.monitor.w,obj.stim{strcmp(obj.list{i,3},obj.stim(:,1)),2});
                        obj.presObj.screenflip(obj.monitor.w);
                        [~,resp] = KbStrokeWait;
                        
                        obj.presObj.closetex(tex1);
                        obj.presObj.closetex(tex2);
                        if find(resp)==KbName('Escape')
                            obj.abortFnc;
                            return;
                        else
                            rate = KbName(find(resp));
                            obj.list(i,5) = regexp(rate,'\d','match');
                        end
                    end
                case 'prac'
                    for i = 1:length(obj.list)
                        [tex1] = obj.presObj.mkimg(obj.monitor.w,obj.screens{1,2}); % Practice trial screen
                        [tex2] = obj.presObj.mkimg(obj.monitor.w,obj.stim{~cellfun(@isempty,cellfun(@(y)(regexp(y,obj.list{i,3},'match')),obj.stim(:,1),'UniformOutput',false)),2}); % Target
                        obj.presObj.screenflip(obj.monitor.w);
                        pause(obj.timing(1));
                        [tex3] = obj.presObj.mkimg(obj.monitor.w,obj.screens{1,2}); % Practice trial screen
                        [tex4] = obj.presObj.mkimg(obj.monitor.w,obj.screens{3,2}); % Mask
                        obj.presObj.screenflip(obj.monitor.w);
                        pause(obj.timing(2));
                        [tex5] = obj.presObj.mkimg(obj.monitor.w,obj.screens{1,2}); % Practice trial screen
                        [tex6] = obj.presObj.mkimg(obj.monitor.w,obj.stim{~cellfun(@isempty,cellfun(@(y)(regexp(y,obj.list{i,4},'match')),obj.stim(:,1),'UniformOutput',false)),2}); % Match
                        [t0] = obj.presObj.screenflip(obj.monitor.w);
                        
                        [t1,resp] = KbStrokeWait([],t0+obj.timing(3));
                        
                        obj.presObj.closetex(tex1);
                        obj.presObj.closetex(tex2);
                        obj.presObj.closetex(tex3);
                        obj.presObj.closetex(tex4);
                        obj.presObj.closetex(tex5);
                        obj.presObj.closetex(tex6);
                        
                        if find(resp)==KbName('Escape')
                            obj.abortFnc;
                            return;
                        elseif ~any(resp)                            
                        else
                            subjresp = KbName(find(resp));
                            obj.list{i,8} = subjresp;
                            obj.list{i,9} = t1-t0;
                            obj.list{i,10} = strcmp(subjresp,obj.list{i,7});
                        end
                        
                        obj.presObj.fixshow(obj.monitor);                        
                        pause(obj.timing(4));
                    end
                otherwise
            end
            obj.presObj.screenflip(obj.monitor.w); % Clear screen
            RestrictKeysForKbCheck([]);
        end
        
        function abortFnc(obj)
            obj.presObj.screenflip(obj.monitor.w);
            RestrictKeysForKbCheck([]);
            obj.abort = 1;
        end
    end
end