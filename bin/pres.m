classdef pres < handle
    % Presentation object
    
    properties
        debug = 0;
    end
    
    methods (Static)
        %% mkimg
        % Arguments: Screen window, picture matrix
        % Output: Texture handle
        function [tex] = mkimg(w,pic)
            tex = Screen('MakeTexture',w,pic);
            Screen('DrawTexture',w,tex);
        end
        
        %% screenflip
        % Arguments: Screen window, picture matrix
        % Output: Texture handle
        function [secs] = screenflip(w)
            [secs] = Screen('Flip',w);
        end
        
        %% Closetex
        % Arguments: Texture handle
        % Output: Texture handle
        function [result] = closetex(tex)
            try
                Screen('close',tex);
                result = 0;
            catch me
                disp(me);
                result = 1;
            end
        end
        
        %% Fixshow
        % Arguments: Monitor data structure
        function fixshow(monitor)
            Screen('DrawLine',monitor.w,monitor.black,monitor.center_W-20,monitor.center_H,monitor.center_W+20,monitor.center_H,7);
            Screen('DrawLine',monitor.w,monitor.black,monitor.center_W,monitor.center_H-20,monitor.center_W,monitor.center_H+20,7);
            Screen('Flip',monitor.w);
        end
        
    end
    
    methods
        %% Constructor
        function obj = pres(debug)   
            obj.debug = debug;
        end        
    end
end