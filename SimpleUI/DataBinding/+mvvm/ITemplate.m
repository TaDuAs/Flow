classdef (Abstract) ITemplate
    % mvvm.ITemplate is the API interface for generating UI components in
    % an mvvm.Repeater data binder.
    % Author: TADA
    
    methods (Abstract)
        % Builds the GUI template for a given scope inside a specified 
        % container.
        % Returns a handles struct containing the hObjects of the generated
        % UI compoenents
        % Input:
        %   template - the template instance
        %   scope - the scope model provider for the template
        %   container - the UI container to build the template components
        %               in
        h = build(template, scope, container)
        
        % Tears down the template UI components for a given model scope.
        % Input:
        %   template - the template instance
        %   scope - the scope model provider for the template
        %   container - the UI container to build the template components
        %               in
        %   h - the handles struct that was generated by the template
        teardown(template, scope, container, h)
    end
end

