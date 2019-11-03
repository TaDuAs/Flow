classdef MCtor < mfc.IMCtor
    properties
        CtorFunctionHandle function_handle;
        Type char;
    end
    
    methods
        function this = MCtor(ctor)
            if isa(ctor, 'function_handle')
                this.CtorFunctionHandle = ctor;
                this.Type = func2str(ctor);
            elseif ischar(ctor) || isStringScalar(ctor)
                this.CtorFunctionHandle = str2func(ctor);
                this.Type = ctor;
            else
                throw(MException('MFactory:MCtor:InvalidCtor', 'ctor must be either a function handle a class name'));
            end
        end
        
        function obj = build(this, varargin)
            obj = this.CtorFunctionHandle(varargin{:});
        end
        
        function type = getTypeName(this)
            type = this.Type;
        end
    end
end

