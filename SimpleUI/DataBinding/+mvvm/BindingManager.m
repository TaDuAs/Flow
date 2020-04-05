classdef BindingManager < handle
    % mvvm.BindingManager class manages everything there is to know about
    % data binding
    % Use model provider methods to manage model providers associated with
    % specified contaienrs. Generally model providers are associated with
    % UI components (mnainly figures), but the container can be anything.
    % mvvm.BindingManager listens to the containers ObjectBeingDestroyed
    % event (when the container is a handle) and automatically removes its
    % associated model provider when the container is being deleted
    %
    % Static Methods:
    % mvvm.BindingManager.instance()
    %       Returns the single instance of the mvvm.BindingManager class
    %
    % mvvm.BindingManager.forceNewInstance()
    %       Forces the mvvm.BindingManager to deleter it's single instance
    %       and produce a new one
    %
    % mvvm.BindingManager.getModProv([container])
    %       Retrives the model provider associated with the specified 
    %       container or the default model provider when no container is 
    %       specified or when no model provider is associated with the
    %       specifeid container
    %
    % mvvm.BindingManager.setModProv(container, modelProvider)
    %       Associates a model provider with the specified container
    %
    % mvvm.BindingManager.setDefaultModProv(modelProvider)
    %       Replaces the existing dafault model provider with the new
    %       specified one.
    %
    % mvvm.BindingManager.removeModProv(container)
    %       Removes any model-provier association with the specified
    %       container.
    %
    % mvvm.BindingManager.setBinder(binder)
    %       Saves a reference to the given mvvm.Binder to keep it alive
    %       event if the user did not keep it's reference.
    %       Binders will be removed automatically when deleted.
    %
    % mvvm.BindingManager.removeBinder(binder)
    %       Remove the binder from keep-alive list and deletes it.
    % 
    % Written by TADA. Jan 2019.
    
    properties (GetAccess=public,SetAccess=private)
        ModelProvidersList;
        ContainerDestroyedListeners;
        MPDestroyedListeners;
        BindersList;
    end
    
    methods (Static, Access=private)
        function ref = singletonInstance(forceNewInstance)
        % Gets the single instance of the mvvm.BindingManager class
            persistent instance;
            
            if nargin > 0 && forceNewInstance
                delete(instance);
            end
            
            if isempty(instance) || ~isvalid(instance)
                instance = mvvm.BindingManager();
            end
            
            ref = instance;
        end
    end
    
    methods (Static) % singleton
        function ref = forceNewInstance()
        % Forces mvvm.BindingManager to replace the old instance with a new
        % one. Only use this for testing.
            ref = mvvm.BindingManager.singletonInstance(true);
        end
        
        function ref = instance()
        % gets the single instance of mvvm.BindingManager
            ref = mvvm.BindingManager.singletonInstance();
        end
        
        function setModProv(container, provider)
        % Sets a model provider associated with a specified container.
        % If one was already associated with this container, the MP is
        % simply replaced
            bm = mvvm.BindingManager.instance();
            bm.setModelProvider(container, provider);
        end
        
        function setDefaultModProv(provider)
        % Sets the default model provider
            bm = mvvm.BindingManager.instance();
            bm.setDefaultModelProvider(provider);
        end
        
        function removeModProv(container)
        % Removes the model provider associated with the specified
        % container
            bm = mvvm.BindingManager.instance();

            % remove the model provider container
            bm.removeModelProvider(container);
        end
        
        function modelProvider = getModProv(container)
        % mvvm.BindingManager.getProvider(container) returns the specific
        % model provider for a specified container. The user is responsible
        % for instantiating this 
            if nargin < 1 || isempty(container)
                container = groot();
            end
            bm = mvvm.BindingManager.instance();
            modelProvider = bm.getModelProvider(container);
        end
        
        function setBinder(binder)
        % saves a reference of a data binder.
        % mvvm.Binder instances are referenced by mvvm.BindingManager to
        % keep them alive without having to keep a reference in the base
        % workspace or to couple to GUI handles.
        % mvvm.Binder automatically send tehmselves to the 
        % mvvm.BindingManager during construction and remove themselves
        % upon destruction
            bm = mvvm.BindingManager.instance();

            % save the model provider
            bm.saveBinder(binder);
        end
        
        function removeBinder(binder)
        % removes all reference of a data binder from the
        % mvvm.BindingManager.
        % mvvm.Binder instances are referenced by mvvm.BindingManager to
        % keep them alive without having to keep a reference in the base
        % workspace or to couple to GUI handles.
        % mvvm.Binder automatically send tehmselves to the 
        % mvvm.BindingManager during construction and remove themselves
        % upon destruction
            bm = mvvm.BindingManager.instance();

            % save the model provider
            bm.clearBinder(binder);
        end
    end
    
    methods % ctor dtor
        function this = BindingManager()
            this.ModelProvidersList = struct('container', {}, 'provider', {});
            this.ContainerDestroyedListeners = {};
            this.MPDestroyedListeners = {};
            this.BindersList = {};
            this.setDefaultModelProvider(this.generateDefaultModelProvider());
        end
        
        function delete(this)
            delete@handle(this);
            
            % delete all listeners to containers delete events
            for i = 1:numel(this.ContainerDestroyedListeners)
                listener = this.ContainerDestroyedListeners{i};
                if ~isempty(listener) && isa(listener, 'handle')
                    delete(listener);
                end
            end
            this.ContainerDestroyedListeners = [];
            
            % delete all listeners to model provider delete events
            for i = 1:numel(this.MPDestroyedListeners)
                listener = this.MPDestroyedListeners{i};
                if ~isempty(listener) && isa(listener, 'handle')
                    delete(listener);
                end
            end
            this.MPDestroyedListeners = [];
            
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
                    this.ContainerDestroyedListeners{i} = container.addlistener('ObjectBeingDestroyed', @onObjectBeingDestroyed);
                else
                    % Only handles have events
                    this.ContainerDestroyedListeners{i} = [];
                end
            else
                % terminate listener to previous model provider delete
                % event
                mplistener = this.MPDestroyedListeners{i};
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
                this.MPDestroyedListeners{i} = modelProvider.addlistener('ObjectBeingDestroyed', @onObjectBeingDestroyed);
            else
                % Only handles have events
                this.MPDestroyedListeners{i} = [];
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
            listener = this.ContainerDestroyedListeners{i};
            if ~isempty(listener) && isa(listener, 'handle')
                delete(listener);
            end
            this.ContainerDestroyedListeners(i) = [];
            
            % terminate listener to destruction event of the removed model 
            % provider
            listener = this.MPDestroyedListeners{i};
            if ~isempty(listener) && isa(listener, 'handle')
                delete(listener);
            end
            this.MPDestroyedListeners(i) = [];
        end
        
        function modelProvider = getModelProvider(this, container)
        % gets the model provider associated with the specified container
        % if no provider is found, returns the default model provider
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
        end
    end
    
    methods (Access=protected)
        
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
            
%             validContainers = ishandle(registeredContainers) | ~isa(registeredContainers, 'handle') | gen.isvalidhandle(registeredContainers);
            ctl = container;
            ctlMask = false(size(registeredContainers));
            imgroot = groot();
            while ~isempty(ctl)
                ctlMask = eq(ctl, registeredContainers);
                if any(ctlMask)
                    break;
                end
                
                ctl = ctl.Parent;
            end
%                 
%                 if ~isvalid(ctl)
%                     ctl = imgroot;
%                 elseif isa(ctl, 'mvvm.IControl')
%                     ctl = ancestor(ctl);
%                 else
%                     ctl = ctl.Parent;
%                 end
% 
%             end
                
%             idx = find(ctlMask & validContainers, 1, 'first');
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

