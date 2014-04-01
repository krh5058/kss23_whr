function [obj] = whr(varargin)
% As requested by Suzy Scherf, Sara Barth
%
% Author: Ken Hwang, M.S.
% SLEIC, PSU

%% Directory initialization and object set-up
p = mfilename('fullpath');
[p,~,~] = fileparts(p);

% Bin
bin = [p filesep 'bin'];
addpath(bin);

% Main object setup
obj = main;
obj.path.base = p;

% Property additions
if nargin > 0
    for nargs = 1:nargin
        if isstruct(varargin{nargs})
            fnames = fieldnames(varargin{nargs});
            for j = 1:length(fnames)
                obj.(inputname(nargs)).(fnames{j}) = varargin{nargs}.(fnames{j});
            end
        else
            obj.(inputname(nargs)) = varargin{nargs};
        end
    end
end

obj.pathset;

% Presentation object set-up, after pathset
presObj = pres(obj.debug);

if obj.debug
    fprintf('whr.m: Directory initialization success!.\n')
end

%% Experimental setup
if obj.debug
    fprintf('whr.m: Experimental setup...\n')
end

obj.expset;
obj.createSaveDir;

if obj.debug
    fprintf('whr.m: Experimental setup success!\n')
end

%% Content setup
if obj.debug
    fprintf('whr.m: Content setup...\n')
end

obj.readAllContent;

if obj.debug
    fprintf('whr.m: Content setup success!\n')
end

%% Monitor initialization
if obj.debug
    fprintf('whr.m: Monitor initialization...\n')
end

obj.dispset;

if obj.debug
    fprintf('whr.m: Monitor initialization success!\n')
end

%% Content parse and format
if obj.debug
    fprintf('whr.m: Content parse and format...\n')
end

[displayObjects] = obj.formatSections(presObj);
[displayScreenObjects] = obj.formatScreens(presObj);

obj.displayObjects = displayObjects;
obj.displayScreenObjects = displayScreenObjects;
obj.saveSession;

if obj.debug
    fprintf('whr.m: Content parse and format success!\n')
end

%% Presentation Sequence
if obj.debug
    fprintf('whr.m: Begin presentation sequence...\n')
end

if ~obj.debug
   main.initPres;
end

displayIndices = cellfun(@getDisplayIndex,displayScreenObjects);
for i = 1:length(obj.conditions)
    presIndex = 1;
    try
    while presIndex <= size(displayObjects,2)
        % Beginning presentation
        displayIndex = presIndex==displayIndices(i,:);
        if any(displayIndex)
            displayScreenObjects{i,displayIndex}.run
            obj.abort = displayScreenObjects{i,displayIndex}.abort;
            if ~obj.abort
                displayScreenObjects{i,displayIndex}.markComplete(true);
            end
        end
        
        if obj.abort
            break;
        end
        
        % Task presentation
        displayObjects{i,presIndex}.run;
        obj.abort = displayObjects{i,presIndex}.abort;
        if ~obj.abort
            displayObjects{i,presIndex}.markComplete(true);
        end
        
        if obj.abort
            break;
        end
        
        presIndex = presIndex + 1;
        
    end
    
    % Ending presentation
    displayIndex = presIndex==displayIndices(i,end);
    if any(displayIndex)
        displayScreenObjects{i,end}.run;
        obj.abort = displayScreenObjects{i,end}.abort;
        if ~obj.abort
            displayScreenObjects{i,end}.markComplete(true);
        end
    end
    
    if obj.abort
        if obj.debug
            fprintf('whr.m: User aborted.\n')
        end
        break;
    end
    catch ME
        disp(ME);
    end
end

obj.displayObjects = displayObjects;
obj.displayScreenObjects = displayScreenObjects;
obj.saveSession;

if obj.debug
    fprintf('whr.m: Presentation sequence success!\n')
end

Screen('CloseAll');

if ~obj.debug
    main.endPres; 
end

%% Writing output
if obj.debug
    fprintf('whr.m: Writing output...\n')
end

obj.writeData;

if obj.debug
    fprintf('whr.m: Writing output!\n')
end

end

