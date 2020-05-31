classdef (Abstract) IExImportDAO < handle
    %IExImportDAO is an interface for data import export classes
    
    methods (Abstract)
        % save(dao, data, key) - exports data with the specified key
        % save(dao, data, results, key) - exports data and data analysis
        %                                 results with the specified key
        save(dao, data, varargin)
        
        % data = load(dao, key) - imports data with the specified key
        % [data, results] = load(dao, key) - imports data and data analysis
        %                                    resuls with the specified key
        varargout = load(dao, key)
    end
end

