classdef (Abstract) ModelPathObserver < handle
    % An abstract class that observes a field path on a model object and
    % listens to data change events.
    % 
    % Deriving classes must implement the doHandleModelUpdate method in
    % order to handle "model-changed" events.
    % Call the init method from deriving classes to start observing the
    % model.
    % 
    % The properties of handle objects in the model field path must
    % have the SetObservable attribute
    % 
    % Author: TADA
    
    
    properties (GetAccess=public,SetAccess=protected)
        ModelProvider;
        ModelPath;
        ModelListeners;
    end
    
    methods (Abstract,Access=protected)
        doHandleModelUpdate(this, src, args, setPathIndex, raisedListenerIndex);
    end
    
    methods (Access=protected)
        function this = ModelPathObserver()
            this.ModelListeners = {};
        end
        
        function init(this, modelPath, modelProvider)
            if ischar(modelPath)
                this.ModelPath = strsplit(modelPath, '.');
            elseif iscellstr(modelPath)
                this.ModelPath = modelPath;
            else
                throw(MException('mvvm:ModelPathObserver:InvalidModelPath', ...
                    'ModelPath must be a list of property names as a cell array of character vectors or as a character vector separated by ''.'''));
            end
            
            this.ModelProvider = modelProvider;
            
            % model 2 control data binding
            this.bindModelEvents();
        end
        
        function bindModelEvents(this, startAt)
            if nargin < 2 || isempty(startAt); startAt = 1; end
            
            % the scope is the current object in the watched field path,
            % start from the model itself
            scope = this.ModelProvider.getModel();
            
            for fieldIdx = startAt:length(this.ModelPath)
                % stop adding listeners once reached null reference
                if isempty(scope)
                    break;
                end
                
                % if this is not a handle continue searching for handles up
                % the field path
                if ~isa(scope, 'handle')
                    continue;
                end
                
                % get current field name
                field = this.ModelPath{fieldIdx};

                try
                    listenerIdx = length(this.ModelListeners)+1;
                    % listen to current field postset event
                    this.ModelListeners{listenerIdx} = ...
                        this.generateModelListener(scope, field, fieldIdx, listenerIdx);
                catch ex % this ex variable is here for debugging
                    % This exception should be thrown only if the property
                    % is not observable.
                    MException('mvvm:ModelPathObserver:HandleNotObseravable',...
                        [   'Can''t observe handle property at the model path "',...
                            strjoin(this.ModelPath(1:fieldIdx), '.'),...
                            '". Add SetObservable attribute to all properties used for data binding.'   ])...
                        .throw();
                end
                
                % scope on child
                scope = scope.(field);
            end
            
        end
        
        function listener = generateModelListener(this, scope, fieldName, fieldIdx, listenerIndex)
            % this fixates the value of fieldIdx in the callback function
            % which saves the effort of searching for the raised event
            % handler in order to remove listeners up the field path
            function callback(src, args)
                this.handleModelUpdate(src, args, fieldIdx, listenerIndex);
            end
            
            % create listenr
            listener = addlistener(scope, fieldName, 'PostSet', @callback);
        end
        
        function handleModelUpdate(this, src, args, setPathIndex, raisedListeberIndex)
            this.manageListenersUpTheFieldPath(setPathIndex, raisedListeberIndex+1);
            
            this.doHandleModelUpdate(src, args, setPathIndex, raisedListeberIndex);
        end
        
        function manageListenersUpTheFieldPath(this, setPathIndex, listenerIndex)
            if listenerIndex > length(this.ModelListeners)
                return;
            end
            
            % remove all listeners to removed objects
            this.cleanListeners(listenerIndex);
            
            % rebind up the field path
            this.bindModelEvents(setPathIndex);
        end
        
        function cleanListeners(this, startAt)
            % destroy and remove listeners from the list
            cellfun(@delete, this.ModelListeners(startAt:end));
            this.ModelListeners(startAt:end) = [];
        end
        
    end
    
    methods
        function delete(this)
            % delete all model listeners
            this.cleanListeners(1);
            
            % delete this
            delete@handle(this);
        end
    end
end

