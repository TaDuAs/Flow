classdef SessionDependency < IoC.Dependency
    properties (Access=private)
        Instance;
    end
    
    methods
        function this = SessionDependency(ioc, id, ctor, varargin)
            this@IoC.Dependency(ioc, id, ctor, varargin{:});
        end
        
        function obj = build(this, varargin)
            if isempty(this.Instance) || (isa(this.Instance, 'handle') && ~isvalid(this.Instance))
                this.Instance = build@IoC.Dependency(this, varargin{:});
            end
            
            obj = this.Instance;
        end
    end
    
    methods (Access=protected)
        function new = generateCopyInstance(this, ioc)
            new = IoC.SessionDependency(ioc, this.Id, this.Ctor);
        end
    end
end

