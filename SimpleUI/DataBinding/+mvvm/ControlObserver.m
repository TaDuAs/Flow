classdef (Abstract) ControlObserver < handle
    %CONTROLOBSERVER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access=private)
        ControlCallbackFunction_;
    end
    
    properties (GetAccess=public,SetAccess=protected)
        Control;
        ControlEvent;
        ControlDestroyedListener;
        ControlEventListener;
    end
    
    methods (Abstract, Access=protected)
        handleControlUpdate(this, arg);        
    end
    
    methods
        function this = ControlObserver()
        end
        
        function delete(this)
            % dispose control listener
            if ~isempty(this.ControlEvent)
                if ~isempty(this.ControlEventListener)
                    % delete event listener
                    delete(this.ControlEventListener);
                    this.ControlEventListener = [];
                elseif isa(this.Control, 'handle') && isvalid(this.Control)
                    % remove event handler function
                    set(this.Control, this.ControlEvent, []);
                end
            end
            
            delete@handle(this);
        end
        
        function start(this)
            if ~isvalid(this)
                return;
            end
            
            this.startObserving();
        end
        
        function stop(this)
            control = this.Control;
            event = this.ControlEvent;
            if isprop(control, event)
                % remove callback
                set(control, event, []);
            elseif ~isempty(this.ControlEventListener)
                % disable listener
                this.ControlEventListener.Enabled = false;
            end
        end
        
        function tf = isSubjectToControl(this, control)
        % determines whether this observes the given control or one of its
        % descendants
            tf = mvvm.isChildOf(this.Control, control);
        end
    end
    
    methods (Access=protected)
        
        function init(this, control, event)
            this.Control = control;
            if nargin >= 3
                this.ControlEvent = event;
            end
            
            % when the control is destroyed, also terminate the binder
            this.ControlDestroyedListener = control.addlistener('ObjectBeingDestroyed', @(~,~) delete(this));
        end
        
        function startObserving(this)
            if isprop(this.Control, this.ControlEvent)
                % reset callback
                set(this.Control, this.ControlEvent, this.ControlCallbackFunction_);
            elseif isempty(this.ControlEventListener)
                % enable listener
                this.ControlEventListener = this.Control.addlistener(this.ControlEvent, this.ControlCallbackFunction_);
            else
                this.ControlEventListener.Enabled = true;
            end
        end
        
        function setupControlBinding(this)
            % control 2 model data binding
            if ~isempty(this.ControlEvent)
                this.bindControlEvent();
            end
        end
        
        function bindControlEvent(this)
            % control callback handler function
            function listenerFunction(~, args)
                this.handleControlUpdate(args);
            end
            
            % save listener function handle
            this.ControlCallbackFunction_ = @listenerFunction;
            
            % bind the callback to the control event
            this.startObserving();
        end
    end
end

