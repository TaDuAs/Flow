classdef fjc
    % Tool for freely joint chain (FJC) fitting and simmulation
    % math based on:
    %   Janshoff, A., Neitzert, M., Oberd?rfer, Y. and Fuchs, H., 2000. 
    %   Force spectroscopy of molecular systems—single molecule spectroscopy of polymers and biomolecules.
    %   Angewandte Chemie International Edition, 39(18), pp.3212-3237.
    
    methods (Static)
        function f = F(x, k, l, T)
        % f = F(x, p, l, [T])
        % calculates the stretching force in distance x
        % for a polymer chain with Kuhn length: lk
        % and contour length: L
            
            import Simple.Scientific.PhysicalConstants;
            import Simple.Math.fjc;
            % Validate & initialize valuse
            if nargin < 4 || isempty(T)
                T = PhysicalConstants.RT;
            end
            kBT = T * PhysicalConstants.kB;
            l = l(:);
            
            % calculate f for each lk-L
            f = kBT./k(:).*(3*x./l + (9/5)*(x./l).^3 + (297/175)*(x./l).^5 + (1539/875)*(x./l).^7);
        end
        
        function [k, l, gof, output] = fit(x, y, k, l, T, params)
            import Simple.Scientific.PhysicalConstants;
            if nargin < 5
                T = PhysicalConstants.RT;
            end
            kBT = PhysicalConstants.kB * T;
            
            % set fitting type
            % FJC extension force is given by the taylor approximation of
            % the inverse langevine function:
            fjcFunction = Simple.Math.fjc.getFjcFunction(kBT);
            fjcf = fittype(fjcFunction);
            
            % Set fit bounds & method
            fitOpt = fitoptions(fjcf);
            fitOpt.Lower = [0, x(end)];
            
            if nargin >= 4
                fitOpt.StartPoint = [k, l];
            end
            
            fitOpt.MaxFunEvals = 150;
            fitOpt.MaxIter = 100;
            if nargin >= 6
                fitOpt = fitoptions(fitOpt, params);
            end
            
            [fitArgs, gof, output] = fit(x', y', fjcf, fitOpt);
            
            k = fitArgs.k;
            l = fitArgs.l;
        end
        
        function [k, l, gof, output] = fitAll(x, y, LcRange, klRange, T, params)
            if nargin < 5
                T = Simple.Scientific.PhysicalConstants.RT;
            end
            kBT = Simple.Scientific.PhysicalConstants.kB * T;
            
            fjcFunction = Simple.Math.fjc.getFjcFunction(kBT);
            sfoo = func2str(fjcFunction);
            
            % generate function expression
            n = size(LcRange, 1);
            c = cell(1,n);
            for i = 1:n
                c{i} = regexprep(regexprep(regexprep(sfoo, '@\([^()]*\)', ''), 'kBT', num2str(kBT)), '(k|l)', ['$0' num2str(i)]);
            end
            
            % generate fit type
            fjcf = fittype(strjoin(c, ' + '));
            
            % map arg names
            argNames = arrayfun(@(n) strcat({'k', 'l'}, num2str(n)), 1:n, 'UniformOutput', false);
            argNames = [argNames{:}];
            coeffNames = coeffnames(fjcf);
            argsIdxMask = cellfun(@(name) find(strcmp(argNames, name)), coeffNames);
            
            % Set fit bounds & method
            fitOpt = fitoptions(fjcf);
            fitOpt.Lower = [0, x(end)];
            
            lower = reshape([klRange(:, 1)'; LcRange(:, 1)'], size(coeffNames));
            upper = reshape([klRange(:, 2)'; LcRange(:, 2)'], size(coeffNames));
            fitOpt = fitoptions(fjcf);
            fitOpt.Lower = lower(argsIdxMask);
            fitOpt.Upper = upper(argsIdxMask);
            fitOpt.StartPoint = lower(argsIdxMask);
            
            fitOpt.MaxFunEvals = 150;
            fitOpt.MaxIter = 100;
            if nargin >= 6
                fitOpt = fitoptions(fitOpt, params);
            end
            
            [fitArgs, gof, output] = fit(x', y', fjcf, fitOpt);
            
            k = zeros(n, 1);
            l = zeros(n, 1);
            for i = 1:n
                sidx = num2str(i);
                k(i) = fitArgs.(['k' sidx]);
                l(i) = fitArgs.(['l' sidx]);
            end
        end
        
        function func = createExpretion(kBT, k, l)
            x = sym('x');
            fjcSym = -kBT/k*(3*x/l + (9/5)*(x/l).^3 + (297/175)*(x/l).^5 + (1539/875)*(x/l).^7);
            func = Simple.Math.Ex.Symbolic(fjcSym);
        end
        
        function ffjc = getFjcFunction(kBT)
            ffjc = @(k, l, x) kBT/k*(3*x/l + (9/5)*(x/l).^3 + (297/175)*(x/l).^5 + (1539/875)*(x/l).^7);
        end
    end
end

