classdef FlowBox < sui.DynamicLayoutBox
    %FlowBox  - lays out content in sequential flow in lines left to right,
    %           dynamically resizing its own height to accomodate contents
    %        ** As sui.FlowBox is a sui.DynamicLayoutBox, use
    %        ** BasePosition instead of Position property!
    %       *** FlowBoxes are dynamically resizing, don't place a FlowBox
    %       *** inside an HBox/VBox/etc.
    %       *** There's no problem placing an HBox/VBox inside a FlowBox
    %
    %  b = sui.FlowBox(p1,v1,p2,v2,...) constructs a flow box and sets
    %  parameter p1 to value v1, etc.
    %
    %  See also: sui.StackBox
    % 
    %  Written by: TADA, Dec. 2018
    
    methods
        
        function this = FlowBox(varargin)
            this@sui.DynamicLayoutBox(varargin{:})
        end
    end
    methods (Access=protected)
        function [positions, calculatedSize] = findBoxesPositions(this, boxes)
            % Prepare inner drawable area matrix in points
            originalSize = sui.getSize(this, 'pixels');
            boxPadding = get(this, 'Padding');
            boxMargin = get(this, 'Spacing');
            posx = boxPadding;
            posy = boxPadding;
            rowHeight = 0;
            rowIndex = 1;
            totalHeight = 2*boxPadding;
            positions = zeros(length(boxes), 5);
            childrenInCurrentRowIdx = false(size(positions));
            
            for i = 1:length(boxes)
                box = boxes(i);
                boxSize = sui.getSize(box, 'pixels');
                
                % check if reached end of line
                if (posx + boxSize(1) + boxPadding) > originalSize(1) && i > 1
                    % Set row specs to entire row
                    positions(childrenInCurrentRowIdx) = repmat(...
                        [rowIndex, posx - boxMargin - boxPadding, rowHeight],...
                        sum(any(childrenInCurrentRowIdx,2)), 1);
                    
                    % return to start of line
                    posx = boxPadding;
                    
                    % go to next line
                    posy = posy + rowHeight + boxMargin;
                    
                    % append last line to total FlowBox height
                    totalHeight = totalHeight + rowHeight + boxMargin;
                    
                    % reset current row specs
                    rowIndex = rowIndex + 1;
                    rowHeight = 0;
                    childrenInCurrentRowIdx = false(size(positions));
                end
                
                % mark current child in the current row
                childrenInCurrentRowIdx(i, [3,4,5]) = true(1,3);
                
                % adjust row height
                rowHeight = max(rowHeight, boxSize(2));
                
                % set current box position
                positions(i, [1,2]) = [posx posy];

                % move to next position
                posx = posx + boxSize(1) + boxMargin;
            end
            
            if any(any(childrenInCurrentRowIdx))
                % Set row specs to entire row
                positions(childrenInCurrentRowIdx) = repmat(...
                    [rowIndex, posx - boxMargin - boxPadding, rowHeight],...
                    sum(any(childrenInCurrentRowIdx,2)), 1);
            end
            
            calculatedSize = [originalSize(1), totalHeight + rowHeight];
        end
    end
end

