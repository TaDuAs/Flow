classdef TypeIgnoreList
    properties (Constant)
        Values = [?mxml.INonSerializable, ?IoC.Container, ?IoC.Dependency, ?mfc.MFactory, ?mvvm.IApp];
    end
end

