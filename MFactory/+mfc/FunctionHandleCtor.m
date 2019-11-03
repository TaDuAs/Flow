classdef FunctionHandleCtor < mfc.MCtor
    methods
        function this = FunctionHandleCtor(type, ctor)
            this@mfc.MCtor(ctor);
            this.Type = type;
        end
    end
end

