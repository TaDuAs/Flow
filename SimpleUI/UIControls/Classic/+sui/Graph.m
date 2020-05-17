classdef Graph < handle & matlab.mixin.SetGet & mvvm.IControl
    % Graph is a wrapper class for graphics elements such as lines, scatter
    % plots, bar charts, etc.
    % Use this class to allow graphics data bining
    %
    % Author: TADA 2019
    
    properties (Access=private)
        Dirty_;
        X_;
        Y_;
        AxisBeingDestroyedListener_;
        YAxis_;
        ColorOrder_;
        YLim_;
        XLim_;
    end
    
    properties
        Tag;
        Axis;
        Handles;
        PlotFunction (1,1) function_handle = @plot;
        Args (1,:) cell;
    end
    
    properties (Access=protected)
        DrawDelayTimer;
    end
    
    properties (Access=public, Dependent)
        DrawDelay (1,1) double;
        Dirty;
        X;
        Y;
        YAxis;
        ColorOrder;
        YLim;
        XLim;
    end
    
    methods % property access methods
        function set.DrawDelay(this, value)
            this.DrawDelayTimer.StartDelay = value;
        end
        function value = get.DrawDelay(this)
            value = this.DrawDelayTimer.StartDelay;
        end
        
        function set.Dirty(this, dirty)
            this.Dirty_ = dirty;
            
            if dirty
                % reset previous redraw, wait for more updates, then redraw
                stop(this.DrawDelayTimer);
                start(this.DrawDelayTimer);
            end
        end
        function dirty = get.Dirty(this)
            dirty = this.Dirty_;
        end
        
        function set.X(this, x)
            this.X_ = x;
            if ~isempty(this.Y)
                this.Dirty = true;
            end
        end
        function x = get.X(this)
            x = this.X_;
        end
        
        function set.Y(this, y)
            this.Y_ = y;
            if ~isempty(this.X)
                this.Dirty = true;
            end
        end
        function y = get.Y(this)
            y = this.Y_;
        end
        
        function set.YAxis(this, value)
            this.YAxis_ = value;
            if ~isempty(this.Handles)
                this.prepAxes();
            end
        end
        function value = get.YAxis(this)
            value = this.YAxis_;
        end
        
        function set.ColorOrder(this, value)
            this.ColorOrder_ = value;
            if ~isempty(this.Handles)
                this.prepAxes();
            end
        end
        function value = get.ColorOrder(this)
            value = this.ColorOrder_;
        end
        
        function set.YLim(this, value)
            this.YLim_ = value;
            if ~isempty(this.Handles)
                this.prepAxes();
            end
        end
        function value = get.YLim(this)
            value = this.YLim_;
        end
        
        function set.XLim(this, value)
            this.XLim_ = value;
            if ~isempty(this.Handles)
                this.prepAxes();
            end
        end
        function value = get.XLim(this)
            value = this.XLim_;
        end
    end
    
    methods
        function this = Graph(axis, varargin)
            this.Axis = axis;
            this.AxisBeingDestroyedListener_ = addlistener(axis, 'ObjectBeingDestroyed', @(~,~) this.delete());
            
            % the timer will prevent exesive redrawing
            this.DrawDelayTimer = timer();
            this.DrawDelayTimer.TimerFcn = @(~, ~) this.redraw();
            this.DrawDelayTimer.TasksToExecute = 1;
            this.DrawDelayTimer.StartDelay = 0.1;
            
            uix.set(this, varargin{:});
        end
        
        function delete(this)
            this.Axis = [];
            delete@handle(this);
            delete@matlab.mixin.SetGet(this);
            stop(this.DrawDelayTimer);
            delete(this.DrawDelayTimer);
            delete(this.AxisBeingDestroyedListener_);
            delete(this.Handles);
            this.PlotFunction = @plot;
            this.X_ = [];
            this.Y_ = [];
        end
        
        function h = ancestor(this, type)
            if nargin < 2
                ax = [this.Axis];
                h = [ax.Parent];
            else
                h = ancestor([this.Axis], type);
            end
        end
    end
    
    methods (Access=protected)
        function redraw(this)
            try
                sx = size(this.X);
                sy = size(this.Y);

                if ~(isempty(this.X) && isempty(this.Y)) &&...
                   (~all(sx == sy) && ~(any(sx == 1) && any(sx == sy) && all(sy > 1)) && ~(any(sy == 1) && any(sx == sy) && all(sx > 1)))
                    warning('sui:Graph:xySizeMismatch', 'X and Y matrices sizes must match. size(X) = [%s]; size(Y) = [%s]', num2str(sx), num2str(sy));
                elseif ~isempty(this.X) && ~isempty(this.Y)
                    delete(this.Handles);
                    this.prepAxes();
                    hold(this.Axis, 'on');
                    this.Handles = this.PlotFunction(this.Axis, this.X, this.Y, this.Args{:});
                elseif isempty(this.X) && isempty(this.Y)
                    delete(this.Handles);
                end
            catch ex
                err = getReport(ex, 'extended');
                disp(err);
                rethrow(ex);
            end
        end
        
        function prepAxes(this)
            % yyaxis must come before the rest
            if ~isempty(this.YAxis_)
                yyaxis(this.Axis, this.YAxis_);
            end
            if ~isempty(this.ColorOrder_)
                this.Axis.ColorOrder = this.ColorOrder_;
            end
            if ~isempty(this.YLim_)
                ylim(this.Axis, this.YLim_);
            end
            if ~isempty(this.XLim_)
                xlim(this.Axis, this.XLim_);
            end
        end
    end
end

