classdef GuiOneWayBinder < mvvm.AdaptationBinder
    % mvvm.GuiOneWayBinder is a one-way binder which updates the
    % model after gui changes, but DOES NOT update the gui when the model
    % is updated. 
    % mvvm.GuiOneWayBinder operates only as a mvvm.ControlObserver,
    % but inherits from mvvm.AdaptationBinder instead of implementing
    % mvvm.IBinderBase to reuse the mvvm.Binder and mvvm.AdaptationBinder
    % functionality which works and is well tested.
    
    
    methods
        function this = GuiOneWayBinder(modelPath, control, property, varargin)
            if numel(varargin) >= 1
                if isa(varargin{1}, 'function_handle')
                    adapter = mvvm.FunctionHandleDataAdapter([], varargin{1});
                    varargin = varargin(2:end);
                elseif isa(varargin{1}, 'mvvm.IDataAdapter')
                    adapter = varargin{1};
                    varargin = varargin(2:end);
                else
                    adapter = mvvm.NoopDataAdapter();
                end
            else
                adapter = mvvm.NoopDataAdapter();
            end
            this@mvvm.AdaptationBinder(modelPath, control, property, adapter, varargin{:});
            this.stop('model');
        end
        
        function start(this, ~)
            start@mvvm.AdaptationBinder(this, 'control');
        end
        
        function stop(this, what)
            if nargin >= 2 && strcmp(what, 'model')
                stop@mvvm.AdaptationBinder(this, 'model');
            else
                stop@mvvm.AdaptationBinder(this, 'all');
            end
        end
    end
    
    methods (Access=protected)
        function bindData(~, ~, ~)
            % this binder shouldn't update the GUI at all...
        end
    end
end

