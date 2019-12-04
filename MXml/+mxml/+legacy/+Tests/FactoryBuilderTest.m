classdef FactoryBuilderTest < handle
    methods
        function initFactory(~, factory)
            % Use class name as string as class identifier
            factory.addConstructor('mxml.legacy.Tests.Class1', @(data) mxml.legacy.Tests.Class1(data.x,data.y, data.list));

            % Use class(instance) as class identifier
            factory.addConstructor('mxml.legacy.Tests.Class2', @(data) mxml.legacy.Tests.Class2(data.a,data.b,data.c));
        end
    end
end

