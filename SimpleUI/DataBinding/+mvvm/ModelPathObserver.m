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
            this.ModelPath = this.checkModelPathValidity(modelPath);
            
            % add model changed listener
            this.ModelProvider = modelProvider;
            this.ModelListeners{1} = this.ModelProvider.addlistener('modelChanged', ...
                @(src, args) this.handleModelChanged(src.getModel(), args, 1, 1));
            
            % model 2 control data binding
            this.bindModelEvents();
        end
        
        function validPath = checkModelPathValidity(~, modelPath)
            if ischar(modelPath)
                validPath = strsplit(modelPath, '.');
            elseif iscellstr(modelPath)
                validPath = modelPath;
            else
                throw(MException('mvvm:ModelPathObserver:InvalidModelPath', ...
                    'ModelPath must be a list of property names as a cell array of character vectors or as a character vector separated by ''.'''));
            end
        end
        
        function bindModelEvents(this, startAt)
            if nargin < 2 || isempty(startAt); startAt = 1; end
            
            % the scope is the current object in the watched field path,
            % start from the model itself
            scope = this.ModelProvider.getModel();
            if startAt > 1
                scope = mvvm.getobj(scope, this.ModelPath(1:startAt-1));
            end
            
            for fieldIdx = startAt:numel(this.ModelPath)
                % stop adding listeners once reached null reference
                if isempty(scope)
                    break;
                end
                
                % get current field name
                field = this.ModelPath{fieldIdx};

                % if this is not a handle continue searching for handles up
                % the field path
                if ~isa(scope, 'handle')
                    % scope on child
                    scope = mvvm.getobj(scope, field);
                    continue;
                end
                
                if isempty(findprop(scope, field))
                    MException('mvvm:ModelPathObserver:HandleNotObseravable',...
                            'Class ''%s'' has no field or property with the name ''%s'' at the model path ''%s''',...
                            class(scope), field, strjoin(this.ModelPath(1:fieldIdx), '.'))...
                            .throw();
                end
                
                try
                    listenerIdx = numel(this.ModelListeners)+1;
                    % listen to current field postset event
                    this.ModelListeners{listenerIdx} = ...
                        this.generateModelListener(scope, field, fieldIdx, listenerIdx);
                catch ex % this ex variable is here for debugging
                    % This exception should be thrown only if the property
                    % is not observable.
                    if strcmp(ex.identifier, 'MATLAB:class:nonSetObservableProp')
                        MException('mvvm:ModelPathObserver:HandleNotObseravable',...
                            'The property ''%s'' of handle class ''%s'' Can''t be observed at the model path ''%s''. Add SetObservable attribute to all properties used for data binding.',...
                            class(scope), field, strjoin(this.ModelPath(1:fieldIdx), '.'))...
                            .throw();
                    else
                        rethrow(ex);
                    end
                end
                
                % scope on child
                scope = mvvm.getobj(scope, field);
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
            
            this.doHandleModelUpdate(args.AffectedObject, setPathIndex, raisedListeberIndex);
        end
        
        function handleModelChanged(this, src, args, setPathIndex, raisedListeberIndex)
            this.manageListenersUpTheFieldPath(setPathIndex, raisedListeberIndex+1);
            
            this.doHandleModelUpdate(src, setPathIndex, raisedListeberIndex);
        end
        
        function manageListenersUpTheFieldPath(this, setPathIndex, listenerIndex)
            if listenerIndex < numel(this.ModelListeners)
                % remove all listeners to removed objects
                this.cleanListeners(listenerIndex);
            end
            
            if setPathIndex < numel(this.ModelPath)
                % rebind up the field path
                this.bindModelEvents(setPathIndex);
            end
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
        
        function start(this)
            if ~isvalid(this)
                return;
            end
            
            function enableListener(l)
                l.Enabled = true;
            end
            
            cellfun(@enableListener, this.ModelListeners); 
        end
        
        function stop(this)
            if ~isvalid(this)
                return;
            end
            
            function disableListener(l)
                l.Enabled = false;
            end
            
            cellfun(@disableListener, this.ModelListeners); 
        end
    end
end

