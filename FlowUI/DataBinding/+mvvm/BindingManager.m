classdef BindingManager < mvvm.IBindingManager
    % mvvm.BindingManager class manages everything there is to know about
    % data binding
    % Use model provider methods to manage model providers associated with
    % specified contaienrs. Generally model providers are associated with
    % UI components (mainly views or sub-views), but the container can be anything.
    % mvvm.BindingManager listens to the containers ObjectBeingDestroyed
    % event (when the container is a handle) and automatically removes its
    % associated model provider when the container is being deleted
    %
    % 
    % Written by TADA. Jan 2019.
    
    properties (GetAccess=public,SetAccess=private)
        ModelProvidersList;
        ContainerDestroyedListeners event.listener = event.listener.empty();
        MPDestroyedListeners event.listener = event.listener.empty();
        BinderListeners event.listener = event.listener.empty();
        BindersList;
    end
    
    methods % ctor dtor
        function this = BindingManager()
            this.ModelProvidersList = struct('container', {}, 'provider', {});
            this.BindersList = {};
            this.setDefaultModelProvider(this.generateDefaultModelProvider());
        end
        
        function delete(this)
            % delete all listeners to containers delete events
            for i = 1:numel(this.ContainerDestroyedListeners)
                listener = this.ContainerDestroyedListeners(i);
                if ~isempty(listener) && isa(listener, 'handle')
                    delete(listener);
                end
            end
            this.ContainerDestroyedListeners = event.listener.empty();
            
            % delete all listeners to model provider delete events
            for i = 1:numel(this.MPDestroyedListeners)
                listener = this.MPDestroyedListeners(i);
                if ~isempty(listener) && isa(listener, 'handle')
                    delete(listener);
                end
            end
            this.MPDestroyedListeners = event.listener.empty();
            
            % remove all model providers from the list
            this.ModelProvidersList = struct('container', {}, 'provider', {});
            
            % delete all data binders
            cellfun(@delete, this.BindersList);
            this.BindersList = {};
        end
    end
    
    methods
        function modelProvider = getDefaultProvider(this)
        % getDefaultProvider returns the default provider
            [~, modelProvider] = this.tryGetModelProvider(groot());
        end
        
        function setDefaultModelProvider(this, modelProvider)
        % sets a new default provider to replace the existing default
        % behaviour
            this.setModelProvider(groot(), modelProvider);
        end
        
        function setModelProvider(this, container, modelProvider)
        % sets the model provider associated with the specified container
        % If one is already associated with it, replace it with the new one
            
            if ~ishandle(container)
                throw(MException('mvvm:BindingManager:InvalidContainer', 'Model provider containers must be valid gui handles'));
            end
            
            [hasMP, ~, i] = this.tryGetModelProvider(container);
            
            function onObjectBeingDestroyed(src, e)
                this.removeModelProvider(container);
            end
            
            % If the model provider container isn't listed, 
            % add the model provider to the end of the list
            if ~hasMP
                i = numel(this.ModelProvidersList) + 1;
                
                if isa(container, 'handle')
                    % Listen to container destuction event and remove the MP
                    % and listener in case of container destruction
                    this.ContainerDestroyedListeners(i) = container.addlistener('ObjectBeingDestroyed', @onObjectBeingDestroyed);
                else
                    % Only handles have events
                    this.ContainerDestroyedListeners(i) = [];
                end
            else
                % terminate listener to previous model provider delete
                % event
                mplistener = this.MPDestroyedListeners(i);
                if ~isempty(mplistener) && isa(mplistener, 'handle')
                    delete(mplistener);
                end
            end
            
            % set the modelProvider
            this.ModelProvidersList(i) = ...
                struct('container', container, 'provider', modelProvider);
            
            if isa(modelProvider, 'handle')
                % Listen to container destuction event and remove the MP
                % and listener in case of container destruction
                this.MPDestroyedListeners(i) = modelProvider.addlistener('ObjectBeingDestroyed', @onObjectBeingDestroyed);
            else
                % Only handles have events
                this.MPDestroyedListeners(i) = [];
            end
        end
        
        function removeModelProvider(this, container)
        % removes the model provider at the specified index
            if eq(container, groot)
                this.setDefaultModelProvider(this.generateDefaultModelProvider());
            end
        
            [hasMP, ~, i] = this.tryGetModelProvider(container);
            if ~hasMP
                return;
            end
        
            % It's not BindingManagers job to delete the model provider
            % it does need to remove it from the list once the container 
            % is destroyed though
            this.ModelProvidersList(i) = [];
            
            % terminate listener to destruction event of the associated
            % container of the removed model provider
            listener = this.ContainerDestroyedListeners(i);
            if ~isempty(listener) && isa(listener, 'handle')
                delete(listener);
            end
            this.ContainerDestroyedListeners(i) = [];
            
            % terminate listener to destruction event of the removed model 
            % provider
            listener = this.MPDestroyedListeners(i);
            if ~isempty(listener) && isa(listener, 'handle')
                delete(listener);
            end
            this.MPDestroyedListeners(i) = [];
        end
        
        function modelProvider = getModelProvider(this, container)
        % gets the model provider associated with the specified container
        % if no provider is found, returns the default model provider
            if nargin < 2; container = groot(); end
            [~, modelProvider] = this.tryGetModelProvider(container);
        end
        
        function saveBinder(this, binder)
        % saves a reference of a data binder.
        % mvvm.Binder instances are referenced by mvvm.BindingManager to
        % keep them alive without having to keep a reference in the base
        % workspace or to couple to GUI handles.
        % mvvm.Binder automatically send tehmselves to the 
        % mvvm.BindingManager during construction and remove themselves
        % upon destruction
            this.BindersList{numel(this.BindersList) + 1} = binder;
            this.BinderListeners(end + 1) = addlistener(binder, 'modelUpdated', @this.onBinderModelUpdate);
        end
        
        function clearBinder(this, binder)
        % removes all reference of a data binder from the
        % mvvm.BindingManager.
        % mvvm.Binder instances are referenced by mvvm.BindingManager to
        % keep them alive without having to keep a reference in the base
        % workspace or to couple to GUI handles.
        % mvvm.Binder automatically send tehmselves to the 
        % mvvm.BindingManager during construction and remove themselves
        % upon destruction
            if isvalid(binder)
                delete(binder);
            end
            flags = cellfun(@(a) eq(a, binder), this.BindersList);
            this.BindersList(flags) = [];
            delete(this.BinderListeners(flags));
            this.BinderListeners(flags) = [];
        end
        
        function activateBindersDomain(this, containerControl)
            allBinders = this.BindersList;
            myBindersMask = cellfun(@(b) b.isSubjectToControl(containerControl), allBinders);
            cellfun(@start, allBinders(myBindersMask));
        end
        
        function deactivateBindersDomain(this, containerControl)
            allBinders = this.BindersList;
            myBindersMask = cellfun(@(b) b.isSubjectToControl(containerControl), allBinders);
            cellfun(@stop, allBinders(myBindersMask));
        end
    end
    
    methods (Access=protected)
        function onBinderModelUpdate(this, binder, args)
            notify(this, 'modelUpdated', args);
        end
        
        function [hasMP, modelProvider, idx] = tryGetModelProvider(this, container)
        % finds the model provider associated with the specified container
        % returns:
        % hasMP:         a logical scalar indicating whether a model
        %                provider associated with the container was found
        % modelProvider: The model provider associated with the specified
        %                container. If none were found, returns empty model
        %                provider vector
        % idx:           returns a numeric scalar with the index of the
        %                model provider associated with the specified
        %                container in the list of providers. if none were
        %                found returns an empty numeric array []
        
            % loops through all providers and searches through the specified
            % containers ancestral tree
            registeredContainers = [this.ModelProvidersList.container];
            if isempty(registeredContainers)
                hasMP = false;
                modelProvider = mvvm.providers.SimpleModelProvider.empty();
                idx = -1;
                return;
            end
            
            imgroot = groot();
            if ~isempty(container)
                ctl = container;
            else
                ctl = imgroot;
            end
            ctlMask = false(size(registeredContainers));
            while ~isempty(ctl)
                ctlMask = eq(ctl, registeredContainers);
                if any(ctlMask)
                    break;
                end
                
                if isprop(ctl, 'Parent')
                    ctl = ctl.Parent;
                elseif isa(ctl, 'mvvm.IControl')
                    ctl = ancestor(ctl);
                else
                    throw(MException('mvvm:BindingManager:UnbindableControlType', ...
                        'Bound controls and their ancestral tree must all be Matlab UI elements or mvvm.IControl'));
                end
            end
            
            idx = find(ctlMask, 1, 'first');
            mpSpec = this.ModelProvidersList(idx);
            modelProvider = mpSpec.provider;
            hasMP = eq(ctl, container);
        end
        
        function mp = generateDefaultModelProvider(this)
            mp = mvvm.providers.SimpleModelProvider();
        end
    end
end

