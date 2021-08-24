classdef OneWayBinder < mvvm.AdaptationBinder
    % mvvm.OneWayBinder is a one-way binder which updates the gui after 
    % the model changes, but DOES NOT update the model when the GUI is 
    % updated. 
    % mvvm.OneWayBinder operates only as a mvvm.ModelObserver, but inherits
    % from mvvm.Binder instead of implementing mvvm.IBinderBase to reuse
    % the mvvm.Binder functionality which works and is well tested.
    
    
    methods
        function this = OneWayBinder(modelPath, control, property, varargin)
            if numel(varargin) >= 1 && (isa(varargin{1}, 'function_handle') || isa(varargin{1}, 'mvvm.IDataAdapter'))
                adapter = varargin{1};
                varargin = varargin(2:end);
            else
                adapter = mvvm.NoopDataAdapter();
            end
            this@mvvm.AdaptationBinder(modelPath, control, property, adapter, varargin{:});
            this.stop('control');
        end
        
        function start(this, ~)
            start@mvvm.AdaptationBinder(this, 'model');
        end
        
        function stop(this, what)
            if strcmp(what, 'control')
                stop@mvvm.AdaptationBinder(this, 'control');
            else
                stop@mvvm.AdaptationBinder(this, 'all');
            end
        end
    end
    
    methods (Access=protected)
        function handleControlUpdate(~, ~)
            % this binder shouldn't update the MODEL at all...
        end
    end
end

