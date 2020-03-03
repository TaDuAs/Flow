classdef Stopwatch < handle
    %STOPWATCH Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        startTime;
        time;
    end
    
    methods
        function this = Stopwatch()
            this.start();
        end
        
        function this = start(this)
            this.startTime = clock;
            this.time = this.startTime;
        end
        
        function [lapTime, totalTime] = lap(this)
            t = clock;
            
            if nargout > 0
                lapTime = etime(t, this.time);
                if nargout > 1
                    totalTime = etime(t,this.startTime);
                end
            end
            
            this.time = t;
        end
        
        function timespan = lapAndLog(this, msg)
            [timespan] = this.lap();
            
            if nargin == 0
                msg = '';
            end
            
            display([msg ' ' this.time2str(timespan)]);
        end
        
        function timespan = lapAndLogTotal(this, msg)
            [~, timespan] = this.lap();
            
            if nargin == 0
                msg = '';
            end
            
            display([msg ' ' this.time2str(timespan)]);
        end
        
        function str = time2str(~, timespan)
            import Simple.cond;
            
            sec = mod(timespan,60);
            min = mod(floor(timespan/60),60);
            hr = floor(timespan/3600);
            
            str = [cond(hr >= 10, num2str(hr), ['0' num2str(hr)]) ':'...
                cond(min >= 10, num2str(min), ['0' num2str(min)]) ':'...
                cond(sec >= 10, num2str(sec), ['0' num2str(sec)])];
        end
    end
    
end

