classdef (Abstract) IDependencyFetcher
    methods (Abstract)
        % Fetches the desired dependency
        dep = fetch(this);
    end
end

