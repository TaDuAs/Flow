classdef IAppContext < gen.ICache & lists.IDictionary
    properties (Abstract)
        IocContainer IoC.IContainer;
    end
end

