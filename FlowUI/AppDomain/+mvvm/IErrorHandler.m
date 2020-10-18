classdef (Abstract) IErrorHandler < handle
    methods (Abstract)
        % log and handle an error
        handleException(this, err, msg);
    end
end

