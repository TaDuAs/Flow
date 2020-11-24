classdef IAppContext < gen.ICache & lists.IDictionary & mxml.INonSerializable
    % mvvm.IAppContext is the interface for application and session level
    % state management context
    % 
    % notice that mvvm.IAppContext is also mxml.INonSerializable to solve
    % the circular references issue
    % 
    
    properties (Abstract)
        IocContainer IoC.IContainer;
    end
end

