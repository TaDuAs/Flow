classdef GlobalBindingManager < handle
    % mvvm.GlobalBidningManager provides a static instance of
    % mvvm.IBindingManager to mvvm.Binders when no binding manager is set
    % explicitly.
    % The static api is not recomended, best practice would be to supply 
    % every binder with its relevant binding manager via the optional  
    % 'BidningManager' parameter, or use dependency injection to do so.
    % 
    % Static Methods:
    % mvvm.GlobalBindingManager.instance()
    %       Returns the single instance of the mvvm.IBindingManager class
    %
    % mvvm.GlobalBindingManager.forceNewInstance()
    %       Forces the mvvm.GlobalBindingManager to delete it's global instance
    %       and produce a new one
    % 
    % mvvm.GlobalBindingManager.forceNewInstance(bindingManager)
    %       Forces the mvvm.GlobalBindingManager to replace its global
    %       instance with the specified bindingManager instance
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
    methods (Static, Access=private)
        function ref = singletonInstance(forceNewInstance)
            persistent instance;
            
            if nargin > 0
                delete(instance);
            end
            
            if isempty(instance) || ~isvalid(instance)
                if nargin > 0 && ~isempty(forceNewInstance)
                    if ~isa(forceNewInstance, 'mvvm.IBindingManager')
                        throw(MException('mvvm:GlobalBindingManager:InvalidInstance', 'Loaded instance of mvvm.GlobalBindingManager must implement the mvvm.IBindingManager interface'));
                    end
                    
                    instance = forceNewInstance;
                else
                    instance = mvvm.BindingManager();
                end
            end
            
            ref = instance;
        end
    end
    
    methods (Static) % singleton
        
        function ref = forceNewInstance(bm)
        % Forces mvvm.GlobalBindingManager to replace the old instance with a new
        % one.
            if nargin < 1; bm = mvvm.BindingManager.empty(); end
            ref = mvvm.GlobalBindingManager.singletonInstance(bm);
        end
        
        function ref = instance()
        % gets the global instance of mvvm.IBindingManager
            ref = mvvm.GlobalBindingManager.singletonInstance();
        end
        
        function setModProv(container, provider)
        % Sets a model provider associated with a specified container.
        % If one was already associated with this container, the MP is
        % simply replaced
            bm = mvvm.GlobalBindingManager.instance();
            bm.setModelProvider(container, provider);
        end
        
        function setDefaultModProv(provider)
        % Sets the default model provider
            bm = mvvm.GlobalBindingManager.instance();
            bm.setDefaultModelProvider(provider);
        end
        
        function removeModProv(container)
        % Removes the model provider associated with the specified
        % container
            bm = mvvm.GlobalBindingManager.instance();

            % remove the model provider container
            bm.removeModelProvider(container);
        end
        
        function modelProvider = getModProv(container)
        % mvvm.GlobalBindingManager.getProvider(container) returns the specific
        % model provider for a specified container. The user is responsible
        % for instantiating this 
            if nargin < 1 || isempty(container)
                container = groot();
            end
            bm = mvvm.GlobalBindingManager.instance();
            modelProvider = bm.getModelProvider(container);
        end
        
        function setBinder(binder)
        % saves a reference of a data binder.
        % mvvm.Binder instances are referenced by mvvm.GlobalBindingManager to
        % keep them alive without having to keep a reference in the base
        % workspace or to couple to GUI handles.
        % mvvm.Binder automatically send tehmselves to the 
        % mvvm.GlobalBindingManager during construction and remove themselves
        % upon destruction
            bm = mvvm.GlobalBindingManager.instance();

            % save the model provider
            bm.saveBinder(binder);
        end
        
        function removeBinder(binder)
        % removes all reference of a data binder from the
        % mvvm.GlobalBindingManager.
        % mvvm.Binder instances are referenced by mvvm.GlobalBindingManager to
        % keep them alive without having to keep a reference in the base
        % workspace or to couple to GUI handles.
        % mvvm.Binder automatically send tehmselves to the 
        % mvvm.GlobalBindingManager during construction and remove themselves
        % upon destruction
            bm = mvvm.GlobalBindingManager.instance();

            % save the model provider
            bm.clearBinder(binder);
        end
    end
    
end

