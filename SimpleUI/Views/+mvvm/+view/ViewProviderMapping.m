classdef ViewProviderMapping
    properties
        BindingManager mvvm.BindingManager;
        View mvvm.view.IView = mvvm.view.Window.empty();
        ModelProvider mvvm.providers.IModelProvider = mvvm.providers.SimpleModelProvider.empty();
        onInitializedOnce event.listener;
    end
    
    methods
        function this = ViewProviderMapping(bm, view, mp)
            this.BindingManager = bm;
            this.View = view;
            this.ModelProvider = mp;
            
            this.onInitializedOnce = addlistener(view, 'initialized', @this.onViewInitialized);
        end
        
        function onViewInitialized(this, ~, ~)
            this.BindingManager.setModelProvider(this.View.getContainerHandle(), this.ModelProvider);
            delete(this.onInitializedOnce);
        end
    end
end

