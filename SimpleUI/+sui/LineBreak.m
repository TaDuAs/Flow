classdef LineBreak < uix.Container
    methods
        function this = LineBreak(varargin)
            sui.setSize(this, [0, 16], 'pixel');
            uix.set(this, varargin{:});
        end
    end
end

