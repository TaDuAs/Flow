classdef (Abstract) IFactory < handle
    methods (Abstract)
        addConstructor(factory, className, ctor);
        instance = construct(factory, className, varargin);
        instance = constructEmptyArray(factory, className);
        tf = hasCtor(factory, className);
        reset(factory);
    end
    
    methods (Abstract, Hidden)
        instance = cunstructEmpty(this, className, data);
    end
end

