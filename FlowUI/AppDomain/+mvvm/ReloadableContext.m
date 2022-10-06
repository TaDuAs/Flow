classdef ReloadableContext < mvvm.IAppContext
    properties (Access=private)
        Id;
        Context mvvm.IAppContext = mvvm.AppContext.empty();
        DataAccessObject dao.FSOutputDataExporter = dao.MXmlDataExporter.empty();
        Messenger mvvm.MessagingMediator;
        AppClosingListener;
    end
    
    properties (Dependent)
        IocContainer IoC.IContainer;
    end
    
    methods
        function this = AppContext(context, dao, messenger)
            this.Context = context;
            this.DataAccessObject = dao;
            this.Messenger = messenger;
            
            this.AppClosingListener = messenger.register('AppClosing', @this.onAppClosing);
        end
        
        function ioc = get.IocContainer(this)
            ioc = this.Context.IocContainer;
        end
        
        function onAppClosing(this, message)
            this.save();
        end
        
        function load(this)
            this.Context = this.DataAccessObject.load();
        end
        
        function save(this)
            this.DataAccessObject.save(this.Context);
        end
    end
    
    methods % gen.ICache methods
        function clearCache(this)
        % clears the entire cache
            this.Context.clearCache();
        end
        
        function value = get(this, key)
        % Gets a value stored in cache
            value = this.Context.get(key);
        end
        
        function set(this, key, value)
        % Stores the value in cache
            this.Context.set(key, value);
        end
        
        function removeEntry(this, key)
        % Removes a stored value from the cache
            this.Context.removeEntry(key);
        end
        
        function containsKey = hasEntry(this, key)
        % Determines whether the cache stores a value with the specified
        % key
            containsKey = this.Context.hasEntry(key);
        end
        
        function keys = allKeys(this)
        % Gets all stored keys
            keys = this.Context.allKeys();
        end
        
        function items = allValues(this)
        % Gets all stored values
            items = this.Context.allValues();
        end
    end
end

