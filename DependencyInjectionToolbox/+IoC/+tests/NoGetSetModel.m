classdef NoGetSetModel < handle & matlab.mixin.SetGet
    %GETSETMODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        prop1;
        prop2;
        prop3;
    end
    
    methods
        function obj = NoGetSetModel()
        end
    end
end

