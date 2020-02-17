classdef SingletonDependency < IoC.Dependency
    properties (Access=private)
        Instance;
    end
    
    methods
        function this = SingletonDependency(ioc, id, ctor, varargin)
            this@IoC.Dependency(ioc, id, ctor, varargin{:});
        end
        
        function obj = build(this, varargin)
            if isempty(this.Instance) || (isa(this.Instance, 'handle') && ~isvalid(this.Instance))
                this.Instance = build@IoC.Dependency(this, varargin{:});
            end
            
            obj = this.Instance;
        end
    end
    
    methods (Access={?IoC.SingletonDependency})
        function setSingleton(this, Instance)
            this.Instance = Instance;
        end
    end
    
    methods (Access=protected)
        function new = generateCopyInstance(this, ioc)
            % if the singleton was not created yet, it's time to build it
            % now. Fixes the extreme lazy loading problem
            if isempty(this.Instance)
                this.build();
            end
            new = IoC.SingletonDependency(ioc, this.Id, this.Ctor);
            new.setSingleton(this.Instance);
        end
    end
end

