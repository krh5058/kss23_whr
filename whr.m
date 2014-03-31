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

if obj.debug
    fprintf('whr.m: Content parse and format success!\n')
end

end

