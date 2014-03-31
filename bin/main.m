classdef main < handle
    % main.m class for WHR
    
    properties
        debug = 1;
        
        subjinfo        
     
        conditions = {'lines','bodies'};
        format
        blocks = {'1','2','3','4','5','6'}
        order
        abort = 0;
        
        lists
        images
        
        monitor
        path
        keys
        timing
        out
        
        head
    end
    
    methods (Static)
        %% Directory list
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
        
        %% Keyset
        function [keys] = keyset
            % Key prep
            KbName('UnifyKeyNames');
            keys.keys1_7 = [KbName('1!') KbName('2@') KbName('3#'), ...
                KbName('4$') KbName('5%') KbName('6^') KbName('7&')];
            keys.qkey = KbName('q');
            keys.pkey = KbName('p');
            keys.esckey = KbName('Escape');
            keys.spacekey = KbName('SPACE');
        end
                
        %% readList
        function [list] = readList(path)
            [num,txt] = xlsread(path);
            num = num2cell(num);
            if size(num,2) == 2
                txt(2:end,1) = num(:,1); % First column, second row including headers
                txt(2:end,2) = num(:,2); % Second column, second row including headers
            elseif size(num,2) == 1
                txt(2:end,2) = num; % Second column, second row including headers
            else
                error('main.m (readList): Error reading xlsx data');
            end
            list = txt;
        end
        
        %% readImage
        function [image] = readImage(path)
            image = imread(path);
        end
    end
    
    methods
        %% Constructor
        function obj = main(varargin)
            % Pre-allocate
            obj.lists = cell([length(obj.conditions) 2]);
            for i = 1:length(obj.conditions)
                obj.images.(obj.conditions{i}).stim = [];
                obj.images.(obj.conditions{i}).screens = [];
            end
            obj.images.misc = [];
            
            obj.head.judge = {'Trial','Condition','Picture','Response'};
            obj.head.sm = {'Block','Trial','Target','Match','Condition','Level','CorrectResponse','SubjectResponse','RT','Accuracy'};
        end
        
        %% Dispset
        function dispset(obj)
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
            
            [monitor.w, monitor.rect] = Screen('OpenWindow', monitor.whichScreen, monitor.white); % Open Screen
            Screen('FillRect',monitor.w,monitor.white);
            Screen('Flip',monitor.w);
            
            %             % Text formatting
            %             Screen('TextSize',monitor.display_window,20);
            %             Screen('TextFont',monitor.display_window,'Helvetica');
            %             Screen('TextStyle',monitor.display_window,0);
            
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
                
                prespath = which('pres.m');
                if ~isempty(prespath)
                    [presext,~,~] = fileparts(prespath);
                    rmpath(presext);
                end
                
                javauipath = which('javaui.m');
                if ~isempty(javauipath)
                    [javauiext,~,~] = fileparts(javauipath);
                    rmpath(javauiext);
                end
                
                obj.path.bin = [obj.path.base filesep 'bin'];
                addpath(obj.path.bin);
                obj.path.out = [obj.path.base filesep 'out'];
                obj.path.content = [obj.path.base filesep 'content'];
                contents = obj.listDirectory(obj.path.content);
                contents = regexp(contents(1:end-1),'\n','split');
                % Condition-specific content
                for i = 1:length(contents)
                    obj.path.(contents{i}) = [obj.path.content filesep contents{i}];
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
            
            obj.subjinfo = {udInput{1},udInput{2},udInput{3}};
            obj.order = udInput{4};
            obj.timing = udInput{5};
            
            if obj.debug
                fprintf('main.m (expset): Setting up key filter.\n');
            end
            
            [obj.keys] = obj.keyset;
            
        end     
                
        %% readAllContent
        function readAllContent(obj)
            
            d = obj.listDirectory(obj.getPath('general'),'xlsx');
            d = regexp(d(1:end-1),'\n','split');
            
            orStatement = '';
            
            for i = 1:length(obj.conditions)
                
                orStatement = [orStatement '|' obj.conditions{i}];
                
                dCond = d(~cellfun(@isempty,cellfun(@(y)(regexp(y,obj.conditions{i})),d,'UniformOutput',false)));
                dPrac = dCond(~cellfun(@isempty,cellfun(@(y)(regexp(y,'prac')),dCond,'UniformOutput',false)));
                dTrial = dCond(cellfun(@isempty,cellfun(@(y)(regexp(y,'prac')),dCond,'UniformOutput',false)));
                
                obj.lists{i,1} = obj.readList([obj.getPath('general') filesep dPrac{1}]);
                obj.lists{i,2} = obj.readList([obj.getPath('general') filesep dTrial{1}]);
                
                dGen = obj.listDirectory(obj.getPath('general'),obj.conditions{i},'jpg');
                dGen = regexp(dGen(1:end-1),'\n','split');
                
                obj.images.(obj.conditions{i}).screens = cell([length(dGen) 2]);
                obj.images.(obj.conditions{i}).screens(:,1) = dGen;
                
                for j = 1:length(dGen)
                    obj.images.(obj.conditions{i}).screens{j,2} = obj.readImage([obj.getPath('general') filesep dGen{j}]);
                end
                
                dStim = obj.listDirectory(obj.getPath(obj.conditions{i}),'jpg');
                dStim = regexp(dStim(1:end-1),'\n','split');
                
                obj.images.(obj.conditions{i}).stim = cell([length(dStim) 2]);
                obj.images.(obj.conditions{i}).stim(:,1) = dStim;
                
                for j = 1:length(dStim)
                    obj.images.(obj.conditions{i}).stim{j,2} = obj.readImage([obj.getPath(obj.conditions{i}) filesep dStim{j}]);
                end
            end
            
            dMisc = obj.listDirectory(obj.getPath('general'),'jpg');
            dMisc = regexp(dMisc(1:end-1),'\n','split');
            dMisc = dMisc(cellfun(@isempty,cellfun(@(y)(regexp(y,orStatement(2:end))),dMisc,'UniformOutput',false)));
            
            obj.images.misc = cell([length(dMisc) 2]);
            obj.images.misc(:,1) = dMisc;
                
            for ii = 1:length(dMisc)
                obj.images.misc{ii,2} = obj.readImage([obj.getPath('general') filesep dMisc{ii}]);
            end
        end

        %% formatSections
        function [displayObjects] = formatSections(obj,presObj)
           
            obj.format = cell([length(obj.conditions) (1+1+length(obj.blocks)) 2]); % Conditions x Task (1 judgment + 1 practice + # of blocks) x Identifiers (cond,task)
            
            displayObjects = cell([size(obj.format,1) size(obj.format,2)]);
            
            for i = 1:length(obj.conditions)
                for j = 1:(1+1+length(obj.blocks))
                    obj.format{i,j,1} = obj.conditions{i};
                    switch j
                        case 1                            
                            obj.format{i,j,2} = 'judge';
                            d = obj.listDirectory(obj.getPath(obj.conditions{i}),'jpg');
                            d = regexp(d(1:end-1),'\n','split');
                            
                            % Construct list
                            list = cell([length(d)+1 length(obj.head.judge)]); % Includes headers
                            
                            list(1,:) = obj.head.judge;
                            list(2:end,1) = num2cell(1:length(d));
                            list(2:end,2) = deal(obj.conditions(i));
                            list(2:end,3) = d(Shuffle(1:length(d)));
                                                       
                            screens = obj.images.(obj.conditions{i}).screens(~cellfun(@isempty,cellfun(@(y)(regexp(y,'judge_trial')),obj.images.(obj.conditions{i}).screens(:,1),'UniformOutput',false)),:);
                            
                            keymap = obj.getKey('keys1_7');                            
                        case 2 
                            obj.format{i,j,2} = 'prac';
                            
                            % Construct list
                            list = cell([size(obj.lists{i,1},1) length(obj.head.sm)]); % Includes headers, 1 is practice index
                            list(1,:) = obj.head.sm; % Headers
                            list(2:end,2) = num2cell([1:size(obj.lists{i,1},1)-1]'); % Trials
                            list(2:end,5) = deal(obj.conditions(i)); % Condition
                            
                            % Fill in
                            for k = 1:length(obj.lists{i,1}(1,:))
                                tempHead = obj.lists{i,1}{1,k};
                                listIndex = strcmpi(obj.head.sm,tempHead);
                                list(2:end,listIndex) = obj.lists{i,1}(2:end,k);
                            end
                            
                            screens = obj.images.(obj.conditions{i}).screens(~cellfun(@isempty,cellfun(@(y)(regexp(y,'practrial')),obj.images.(obj.conditions{i}).screens(:,1),'UniformOutput',false)),:);
                            screens = [screens; obj.images.misc];
                            keymap = [obj.getKey('qkey') obj.getKey('pkey')];
                        otherwise
                            obj.format{i,j,2} = obj.order{j-2}; % Displace 2
                            
                            % Construct list
                            blockIndices = cellfun(@any,cellfun(@(y)(str2double(obj.format{i,j,2})==y),obj.lists{i,2}(2:end,1),'UniformOutput',false)); % Index for block, not including headers
                            inListHead = obj.lists{i,2}(1,:); % Keep input headers
                            tempList = obj.lists{i,2}(2:end,:); 
                            tempList = tempList(blockIndices,:); % Parse without headers
                            
                            list = cell([size(tempList,1)+1 length(obj.head.sm)]); % Includes headers, 2 is task index
                            list(1,:) = obj.head.sm; % Headers
                            list(2:end,2) = num2cell([1:size(tempList,1)]'); % Trials
                            list(2:end,5) = deal(obj.conditions(i)); % Condition
                            
                            % Fill in
                            for k = 1:length(inListHead)
                                tempHead = inListHead{k};
                                listIndex = strcmpi(obj.head.sm,tempHead);
                                list(2:end,listIndex) = tempList(:,k);
                            end
                            
                            screens = obj.images.misc;
                            keymap = [obj.getKey('qkey') obj.getKey('pkey')];
                    end                    
                    stim = obj.images.(obj.conditions{i}).stim;
                    keymap = [keymap obj.getKey('esckey')];
                    
                    displayObjects{i,j} = sectionFactory(obj.debug,obj.monitor,obj.conditions{i},obj.format{i,j,2},list,stim,screens,keymap,obj.timing);
                    displayObjects{i,j}.loadPresObj(presObj);
                end
            end
        end
        
        %% formatScreens
        function [displayObjects] = formatScreens(obj,presObj)
            displaySequence = [1 2 3 6 9]; % Before judge, before prac, before task, before block 4, after final block (9)
            displayObjects = cell([length(obj.conditions) length(displaySequence)]);
            for i = 1:length(obj.conditions)
                for j = 1:length(displaySequence)
                    switch displaySequence(j)
                        % Screens are searched for in order of their
                        % presentation
                        case 1
                            pat = cell([2 1]);
                            pat{1} = [obj.conditions{i} '_judge_intro'];
                            pat{2} = [obj.conditions{i} '_judge_instruct'];
                        case 2
                            pat = cell([3 1]);
                            pat{1} = [obj.conditions{i} '_judge_end'];
                            pat{2} = [obj.conditions{i} '_sm_intro'];
                            pat{3} = [obj.conditions{i} '_sm_instruct'];
                        case 3
                            pat = cell([1 1]);
                            pat{1} = [obj.conditions{i} '_sm_begin'];
                        case 6
                            pat = cell([1 1]);
                            pat{1} = [obj.conditions{i} '_sm_halfway'];
                        case 9
                            pat = cell([1 1]);
                            pat{1} = [obj.conditions{i} '_sm_end'];
                    end
                    screens = [];
                    for k = 1:length(pat)
                        screens = [screens; obj.images.(obj.conditions{i}).screens(~cellfun(@isempty,cellfun(@(y)(regexp(y,pat{k})),obj.images.(obj.conditions{i}).screens(:,1),'UniformOutput',false)),:)];
                    end
                    
                    keymap = [obj.getKey('spacekey') obj.getKey('esckey')];
                    displayObjects{i,j} = sectionFactory(obj.debug,obj.monitor,displaySequence(j),screens,keymap);
                    displayObjects{i,j}.loadPresObj(presObj);
                end
            end
        end
        
        %% getMonitor
        function [monitor] = getMonitor(obj)
            monitor = obj.monitor;
        end
            
        %% getPath
        function [pathout] = getPath(obj,arg)
            pathout = obj.path.(arg);
        end
        
        %% getKey
        function [keyout] = getKey(obj,arg)
            keyout = obj.keys.(arg);
        end

    end
end