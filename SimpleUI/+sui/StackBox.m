classdef StackBox < sui.DynamicLayoutBox
    %STACKBOX Stacks contents from top to bottom, dynamically resizing
    %         its own height to accomodate contents
    %      ** As sui.StackBox is a sui.DynamicLayoutBox, use
    %      ** BasePosition instead of Position property...
    %      *** StackBoxes are dynamically resizing, don't place a StackBox
    %      *** inside an HBox/VBox/etc.
    %      *** There's no problem placing an HBox/VBox inside a StackBox
    %
    %  See also: sui.FlowBox
    % 
    %  Written by: TADA, Dec. 2018
    
    methods
        function this = StackBox(varargin)
            this@sui.DynamicLayoutBox(varargin{:})
        end
    end
    
    methods (Access=protected)
        function [positions, calculatedSize] = findBoxesPositions(this, boxes)
            originalSize = sui.getSize(this, 'pixels');
            boxPadding = get(this, 'Padding');
            boxMargin = get(this, 'Spacing');
            posx = boxPadding;
            posy = boxPadding;
            totalHeight = 2*boxPadding;
            positions = zeros(length(boxes), 5);
            
            for i = 1:length(boxes)
                box = boxes(i);
                boxSize = sui.getSize(box, 'pixels');
                
                % set current box position
                positions(i,:) = [posx posy i boxSize];

                % move to next position
                posy = posy + boxSize(2) + boxMargin;
                totalHeight = totalHeight + boxSize(2) + boxMargin;
            end

            calculatedSize = [originalSize(1), totalHeight - boxMargin];
        end
    end
end

