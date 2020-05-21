classdef ConsoleProggressBar < handle
    %CONSOLEPROGGRESSBAR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        actionName = '';
        proggress = 0;
        endAt = 0;
        alertInterval = 10;
        showEachIteration = false;
        iterationChar = '.';
        lastProggresion = 0;
        lastReturn = 0;
        returnInterval = 100;
        stopper;
    end
    
    events
        AlertProggress;
    end
    
    methods
        function this = ConsoleProggressBar(actionName, endAt, alertInterval,...
                showEachIteration, iterationChar)
            Simple.obsoleteWarning('Simple.UI');
            this.actionName = actionName;
            this.endAt = endAt;
            if nargin > 2
                this.alertInterval = alertInterval;
            end
            if nargin > 3
                this.showEachIteration = showEachIteration;
            end
            if nargin > 4 && ~isempty(iterationChar)
                this.iterationChar = iterationChar;
            end
            this.stopper = Simple.Stopwatch();
        end
        
        function reportProggress(this, howMuch)
            this.lastProggresion = this.lastProggresion + howMuch;
            
            % refresh proggress characters
            this.refreshProggress();
            
            % proggress
            prevProggress = this.proggress;
            this.proggress = prevProggress + howMuch;
            
            % alert proggress precentage
            if this.shouldAlertProggress(this.proggress, prevProggress)
                this.doAlertProggress(howMuch);
            end
        end
        
        function refreshProggress(this)
            currentlyInCurrentRow = this.proggress - this.lastReturn;
            spaceInCurrentRow = this.returnInterval - currentlyInCurrentRow;
            if spaceInCurrentRow >= this.lastProggresion
                str = char(zeros(1, this.lastProggresion));
                str(:) = this.iterationChar;
                fprintf(str);
            else
                str = char(zeros(1, spaceInCurrentRow + 1));
                str(:) = this.iterationChar;
                str(length(str)) = sprintf('\n');
                
                leftToReport = this.lastProggresion - spaceInCurrentRow;
                strRows = '';
                if (leftToReport / this.returnInterval) >= 1
                    numRows = floor(leftToReport / this.returnInterval);
                    strRows = char(zeros(this.returnInterval + 1,numRows));
                    strRows(:,:) = this.iterationChar;
                    strRows(end,:) = sprintf('\n');
                end
                
                howManyInLastRow = mod(leftToReport, this.returnInterval);
                strTail = char(zeros(1, howManyInLastRow));
                strTail(:) = this.iterationChar;
                
                fprintf([str strRows(:)' strTail]);
                this.lastReturn = this.proggress - howManyInLastRow;
            end
            
            this.lastProggresion = 0;
        end
    end
    
    methods (Access = private)
        
        function ret = shouldAlertProggress(this, currProggress, prevProggress)
            currPrecent = (currProggress / this.endAt)*100;
            prevPrecent = (prevProggress / this.endAt)*100;
            
            ret = floor(currPrecent / this.alertInterval) > floor(prevPrecent / this.alertInterval);
        end
        
        function doAlertProggress(this, reportedProgress)
            workDone = floor((this.proggress/this.endAt)*100);
            workDoneFraction = workDone/100;
            [~, timespan] = this.stopper.lap();
            timeEstimate = ((1-workDoneFraction) / workDoneFraction) * timespan;
            display([sprintf('\n'), this.actionName ' ', ...
                num2str(workDone), '% complete',...
                ' Estimated time left: ', this.stopper.time2str(timeEstimate)]);
            this.lastReturn = this.proggress;
            
            args = Simple.ProcessProgressED(reportedProgress, this.proggress, this.endAt - this.proggress);
            notify(this, 'AlertProggress', args);
        end
        
    end
    
end

