function [obj] = whr(varargin)
% As requested by Suzy Scherf, Sara Barth
%
% Author: Ken Hwang, M.S.
% SLEIC, PSU

%% Directory initialization and set-up
p = mfilename('fullpath');
[p,~,~] = fileparts(p);

% Bin
bin = [p filesep 'bin'];
addpath(bin);

% Object setup
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

if obj.debug
    fprintf('whr.m: Directory initialization success!.\n')
end
end