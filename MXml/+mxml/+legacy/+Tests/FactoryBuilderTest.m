classdef FactoryBuilderTest < handle
    methods
        function initFactory(~, factory)
            % Use class name as string as class identifier
            factory.addConstructor('Simple.IO.MXML.Tests.Class1', @(data) Simple.IO.MXML.Tests.Class1(data.x,data.y, data.list));

            % Use class(instance) as class identifier
            factory.addConstructor('Simple.IO.MXML.Tests.Class2', @(data) Simple.IO.MXML.Tests.Class2(data.a,data.b,data.c));
        end
    end
end

