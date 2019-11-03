classdef (Abstract) IDescriptor < handle
    % IDescriptor provides information on proper initialization and 
    % which properties to set for mfc.MFactory
    methods (Abstract)
        % provides initialization description for mfc.MFactory
        % ctorParams is a cell array which contains the parameters passed to
        % the ctor and which properties are to be set during construction
        [ctorParams, defaultValues] = getMfcInitializationDescription(~);
    end
end