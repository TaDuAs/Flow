classdef Histool
    % This class provides functions to generate a histogram
    % with or without plotting...
    methods (Static)
        function [bins, binterval, nBins] = calcBins(data, method, minimalBins)
        % [bins, binterval, nBins] = calcBins(data, method):
        % Calculates the number of bins using the specified method, and
        % generates the bins array.
        % Parameters:
        %   data - Data array... Claro...
        %   method - Name of the binning method to use
        %            'sturges' - Sturges' formula (default)
        %            'fd' - Freedman–Diaconis
        %            'sqrt' - square root
        %            numeric - the bin size to apply
        %   minimalBins - Don't calculate less bins than specified here
        % Returns: 
        %   bins - Bins array
        %   binterval - The equal width of each bin
        %   nBins - The number of bins in the array
        %------------------------------------------------------------------
        % [bins, binterval, nBins] = calcBins(data, binterval):
        % Similar, only bins array is calculated according to the
        % specified bin width.
            import Simple.Math.*;
            if ~exist('method', 'var') || isempty(method)
                method = 'sturges';
            end
            
            if isnumeric(method)
                binterval = method;
                nBins = ceil(range(data)/binterval);
                
                % ensure at least minimal bins are set
                if exist('minimalBins', 'var') && ~isempty(minimalBins) && nBins < minimalBins
                    nBins = minimalBins;
                    
                    % Calculate binterval
                    binterval = range(data)/nBins;
                end
            else
                n = length(data);

                % Calculate number of bins using the wanted method
                switch lower(method)
                    case 'sturges'
                        nBins = round(log(n) + 1);
                    case {'fd', 'freedman–diaconis', 'freedman diaconis'}
                        nBins = round(2 * iqr(data) / (n^(1/3)));
                    case {'sqrt', 'square root', 'square-root'}
                        nBins = round(sqrt(n));
                    otherwise
                        error(['Binning method ''' method ''' not supported']);
                end
                
                % ensure at least minimal bins are set
                if exist('minimalBins', 'var') && ~isempty(minimalBins) && nBins < minimalBins
                    nBins = minimalBins;
                end
                
                % Calculate binterval
                binterval = range(data)/nBins;
            end
            
            % Calculate bins array
            bins = (1:nBins).*binterval + min(data);
        end
        
        function freq = calcFrequencies(data, bins)
        % Calculates the frequencies of data for a bins array
            import Simple.Math.*;
            freq = zeros(1, length(bins));
            freq(1) = sum(data <= bins(1));
            for i = 2:length(freq)
                freq(i) = sum(data > bins(i-1) & data <= bins(i));
            end
        end
        
        function x = bins2x(bins)
            import Simple.Math.*;
            binsDiff = diff(bins);
            
            % asume first bin starts at 0
            if bins(1) > 0
                firstBinDiff = bins(1);
            else % asume first bin width is the same as the next one's
                try
                    
                firstBinDiff = binsDiff(1);
                catch ex
                     disp(ex);
                end
            end
            
            x = bins - 0.5*[firstBinDiff binsDiff];
        end
        
        function [mpv, stdev, gammaParams, goodness] = fitGamma(bins, freq, y, fittingOptions)
            import Simple.Math.*;
            import Simple.*;
            if nargin < 3
                fittingOptions = [];
            end
            
            x = Histool.bins2x(bins);
            significance = getobj(fittingOptions, 'alpha', 0.05);
            [gfit2, goodness2] = gamfit(x, significance, zeros(1, length(x)), freq);
            [gfit, goodness] = gamfit(y, significance);
            alpha = gfit(1);
            theta = gfit(2);
            
            mpv = (alpha-1)*theta;
            stdev = sqrt(alpha)*theta;
            gammaParams.alpha = alpha;
            gammaParams.theta = theta;
        end
        
        function [mpv, stdev, amplitude, goodness, gaussFit] = calcGaussian(bins, freq, fittingOptions)
        % Calculates a gaussian fit to a histogram
        % Parameters:
        %   bins - data bins
        %   freq - frequencies in each bin
        %   fittingOptions - Options regarding the fitting using matlab fit
        %                    function
        %           # useMatlabFit   - Determines whether to fit a gaussian
        %                              or just use the simple calculation
        %           # fitR2Threshold - Determines the fit's R square
        %                              threshold for using the fit
        %           # order          - The number of distributions to fit
        % Returns:
        %   mpv - most prevalent value
        %   std - standard deviation
        %   amplitude - the maximum value of the fit
            import Simple.*;
            import Simple.Math.*;
            if nargin < 3
                fittingOptions = [];
            end
            order = getobj(fittingOptions, 'order', 1);
            x = Histool.bins2x(bins);
            
            if order == 1 
                % Fit using basic normal distribution
                n = sum(freq);
                probability = freq/n;
                mpv = sum(x.*probability);
                stdev = sqrt(sum(((x-mpv).^2).*probability));

                % Get fit data
                amplitude = 1/(stdev*sqrt(2*pi));
                goodness = [];
        
                % generate gaussian distribution fit
                % ** gives better values than normfit, normfit uses a similar
                %    calculation as above.
                if getobj(fittingOptions, 'useMatlabFit', false)
                    gaussianX = x;
                    gaussianY = freq;

                    % Fit gaussian to histogram bars
                    [upper, lower] = Histool.prepareFitBounds(order, gaussianX, gaussianY);
                    [fittingParams, fitModel] = Histool.prepareGaussFitOptions(order, upper, lower, [amplitude, mpv, stdev]); 
                    [gaussFit, goodness] = fit(gaussianX', gaussianY', fitModel, fittingParams);

                    if goodness.rsquare >= getobj(fittingOptions, 'fitR2Threshold', 0.7)
                        % Get fit data
                        amplitude = abs(gaussFit.a1);
                        mpv = gaussFit.b1;
                        stdev = abs(gaussFit.c1);
                    end
                end
            elseif order > 1
                gaussianX = x;
                gaussianY = freq;

                amplitude = zeros(1, order);
                mpv = zeros(1, order);
                stdev = zeros(1, order);

                % Fit gaussian to histogram bars
                [upper, lower] = Histool.prepareFitBounds(order, gaussianX, gaussianY);
                [fittingParams, fitModel] = Histool.prepareGaussFitOptions(order, upper, lower); 
                [gaussFit, goodness] = fit(gaussianX', gaussianY', fitModel, fittingParams);
                
                % When the fitted model is rubbish, fit again without
                % upper/lower bounds and let matlab decide alone.
                % The fitting may have out of bounds values, but sometimes
                % the overall fit is better.
                if goodness.rsquare < getobj(fittingOptions, 'fitR2Threshold', 0.7)
                    [gaussFitNoBounds, goodnessNoBounds] = fit(gaussianX', gaussianY', fitModel);
                    
                    % If the no-bounds fit is better, use it instead
                    if goodnessNoBounds.rsquare > goodness.rsquare
                        gaussFit = gaussFitNoBounds;
                        goodness = goodnessNoBounds;
                    end
                end
                
                % Extract fitted values
                for i = 1:order
                    level = num2str(i);
                    amplitude(i) = gaussFit.(['a' level]);
                    mpv(i) = gaussFit.(['b' level]);
                    stdev(i) = gaussFit.(['c' level]);
                end
            else
                error('Gaussian order must be a positive whole number');
            end
        end
        
        function [h, freq, bins, binterval, nBins] = plot(data, binningMethod, minimalBins, fig)
            import Simple.Math.*;
            import Simple.*;
            if nargin < 2
                binningMethod = [];
            end
            if nargin < 3
                minimalBins = [];
            end
            
            [bins, binterval, nBins] = Histool.calcBins(data, binningMethod, minimalBins);
            freq = Histool.calcFrequencies(data, bins);
            
            if nargin >= 4
                if isa(fig, 'matlab.ui.Figure') || isnumeric(fig)
                    figure(fig);
                elseif isa(fig, 'matlab.graphics.axis.Axes')
                    subplot(fig);
                else
                    error('fig must be a matlab Figure id or a Figure/Axes object handle');
                end
            end
            
            h = histogram(data, bins);
        end
    end
    
    methods (Static, Access=private)
        function [fitOpt, fitModel] = prepareGaussFitOptions(order, upper, lower, start)
            nameValue = {'Upper', upper, 'Lower', lower};
            if nargin >= 4
                nameValue(5:6) = {'Start', start};
            end
            fitModel = ['gauss' num2str(order)];
            fitOpt = fitoptions(fitModel, nameValue{:});
        end
        
        function [upper, lower] = prepareFitBounds(order, x, y)
            maxX = max(x);
            maxY = max(y)*2;
            minX = min(x);
            minY = 0;
            upper = repmat([maxY, maxX, maxX-minX], 1, order);
            lower = repmat([minY, minX, 0], 1, order);
        end
    end
    
end

