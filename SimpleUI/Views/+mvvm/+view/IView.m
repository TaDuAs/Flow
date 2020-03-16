classdef (Abstract) IView < mvvm.view.IContainer
    % mvvm.view.IView is an interface for view objects
    
    properties (Abstract, GetAccess=public, SetAccess=private)
        % Application object
        App appd.IApp;
        
        % view status
        Status mvvm.view.ViewStatus;
    end
    
    properties (Abstract) % property injections
        % Parent view
        OwnerView mvvm.view.IView;
        
        % Containing figure
        Fig matlab.ui.Figure;
        
        % Application messenger object
        Messenger appd.MessagingMediator;
        
        % Data binding manager object
        BindingManager mvvm.BindingManager;
        
        % Provides the current views model provider object for data binding
        ModelProviderMapping mvvm.view.ViewProviderMapping;
        
        % View manager for interaction with other views
        ViewManager mvvm.view.IViewManager;
        
        % The Id of the current view
        Id string;
    end
    
    events % view lifecycle events
        % Fires once the view is initialized and configured and ready for
        % UI components initialization
        initialized;
        
        % Fires once the views UI components are initialized
        componentsInitialized;
        
        % Fires once the view is fully loaded and ready for user
        % interaction
        loaded;
        
        % Fires when the view is closing, before it is actually closed.
        % Allows for user interaction before closing such as "saving data"
        % or "canceling"
        closing;
    end
    
    methods (Abstract)
        % Shows the current view
        show(view);
        
        % Accesses the ancestral tree of a view's ui component
        % parent = ancestor(view)
        %   Gets the direct ancestor of the current view
        %
        % parent = ancestor(view, type)
        %   Gets the first ancestor of a view with the given type
        parent = ancestor(view, type);
        
        % Starts the current view's lifecycle
        start(view);
        
        % Terminates the current view
        close(view);
    end
end

