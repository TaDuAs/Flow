classdef wlc
    %WLC Summary of this class goes here
    %   Detailed explanation goes here
    
    methods (Static)
        function s = S(x, p, l, T)
            import Simple.Scientific.PhysicalConstants;
            if nargin < 4 || isempty(T)
                T = PhysicalConstants.RT;
            end
            kbt = PhysicalConstants.kB * T;
            s = -(kbt/(p*l))*(1+1/(2*(1-x/l)^3)); 
        end
        
        function f = F(x, p, l, T, k, model)
        % f = F(x, p, l, [T])
        % calculates the stretching force in position x
        % for a polymer chain with persistence length: p
        % and contour length: l
        % f = F(x, p, l, [T], k)
        % solves the force numerically using the correct
        % tip height: D=x-f/k (f is positive in WLC)
        % ** Don't use this with multiple p,l solutions.
            
            import Simple.Scientific.PhysicalConstants;
            import Simple.Math.wlc;
            
            % Validate & initialize valuse
            if nargin < 4 || isempty(T); T = PhysicalConstants.RT; end
            if nargin < 5; k = []; end
            if nargin < 6; model = ''; end
            n = length(p);
            if n ~= length(l)
                error('The dimensions of vectors p & l must be consistent.');
            end
            if isempty(k)
                f = zeros(n, length(x));
            else
                f = zeros(n, length(x), 3);
            end
            
            % calculate f for each P-L set
            for i = 1:n
                kbt = PhysicalConstants.kB * T;
                if isempty(k)
                    
                    wlcf = Simple.Math.wlc.getWlcFunction(kbt, p(i), l(i), model);
                    
                    % calculate f according to WLC formula
                    % vectorized solution
                    f(i, :) = real(wlcf(x));
%                     x1 = x/l(i);
%                     f(i, :) = real((kbt./p(i))*(1./(4*(1-x1).^2)-1/4+x1));
                else
                    % calculate f according to WLC formula, while
                    % substituting x with D=x-f/k to get correct tip height
                    % x and f are recalculated iteratively.
                    % The solution generally converges after 6 iterations.
                    wlcf = Simple.Math.wlc.getWlcFunction(kbt, [], [], model); 
                    x1 = x;
                    for j = 1:6
%                         f = double(real((kbt./p(i))*(1./(4*(1-x1).^2)-1/4+x1)));
                        f = double(real(wlcf(p(i), l(i), x1)));
                        x1 = (x-f/k);
                    end
                end
            end
        end
        
        function [p, l] = PL(x, f, s, T, k)
        % calculates the persistence length p and contour length l
        % of a polymer chain which corresponds to the force: f
        % and stiffness: s (df/dx) in position x
        % 
        % F = kBT/P(1/(4(1-x/L)^2) + x/L - 1/4)
        % dF/dx = kBT/PL(1/(2(1-x/L)^3) + 1)
            import Simple.Scientific.PhysicalConstants;
            import Simple.Math.wlc;
            if nargin < 4 || isempty(T)
                T = PhysicalConstants.RT;
            end
            if nargin < 5
                k = [];
            end

            kbt = PhysicalConstants.kB * T;
            
            % Solve two equations with parameters problem numerically
            syms P L D;
            if isempty(k)
                solution = vpasolve(...
                    [(kbt/P)*(1/(4*(1-x/L)^2) + x/L -1/4) == abs(f),...
                     (kbt/(P*L))*(1+1/(2*(1-x/L)^3)) == abs(s)], [P, L]);
            else
                solution = vpasolve(...
                    [(kbt/P)*(1/(4*(1-D/L)^2) + D/L -1/4) == abs(f),...
                     (kbt/(P*L))*(1+1/(2*(1-D/L)^3)) == abs(s),...
                     x-abs(f)/k == D], [P, L, D]);
            end
            p = double(solution.P);
            l = double(solution.L);
        end
        
        function [y, correctP, correctL] = correctSolution(x, p, l, T, k)
        % Find the correct solution of the wlc problem.
        % Less peaks: better
        % Max value farthest (higher x values): better
        % Arguments:
        %   x - The x vector to calculate wlc for
        %   p - Persistence length solutions
        %   l - Contour length solutions
        % Returuns:
        %   y - the calculated wlc vector for the specified x vector
        %       according to the best solution
        
            import Simple.Math.wlc;
            if nargin < 4
                T = [];
            end
            if nargin < 5
                k = [];
            end
            
            % Calculate all solutions of the wlc
            solutions = wlc.F(x, p, l, T, k);
            
            % find location of maximal value
            npl = size(solutions, 1);
            nf = size(solutions, 3);
            solInfo = zeros(npl*nf, 6);
            [solInfo(:, 5), solInfo(:, 4)] = max(solutions, [], 2);
            for j = 1:nf
                idx = (0:(npl-1))*nf+j;
                solInfo(idx, 6) = solutions(:, end, j);
            end
            
            % find number of peaks in each solution
            for i = 1:npl
                for j = 1:nf
                    if length(solutions(i, :, j)) < 3
                        maxima = 0;
                        minima = 0;
                    else
                        maxima = findpeaks(solutions(i, :, j));
                        minima = findpeaks(-solutions(i, :, j));
                    end

                    solInfo((i-1)*nf + j, [1 2 3]) = [i j length(minima)+length(maxima)];
                end
            end
            
            % order solutions by number of peaks, and location of maximal
            % value.
            % less peaks: better
            % maximal value farthest (higher x value): better
            solutionsOrderedByProbability = sortrows(solInfo, [3, -4]);
            mostProbableSolutionIndex = solutionsOrderedByProbability(1, [1 2]);
            
            y = solutions(mostProbableSolutionIndex(1), :, mostProbableSolutionIndex(2));
            correctP = p(mostProbableSolutionIndex(1));
            correctL = l(mostProbableSolutionIndex(1));
        end
        
        function [p, l, gof, output] = fitAll(x, y, contourRange, persistenceRange, T, model, varargin)
            if nargin < 5; T = Simple.Scientific.PhysicalConstants.RT; end
            if nargin < 6 || isempty(model); model = ''; end
            kBT = Simple.Scientific.PhysicalConstants.kB * T;
            
            wlcfunction = Simple.Math.wlc.getWlcFunction(kBT, [], [], model);
            sfoo = func2str(wlcfunction);
            
            n = size(contourRange, 1);
            c = cell(1,n);
            for i = 1:n
                c{i} = regexprep(regexprep(regexprep(sfoo, '@\([^()]*\)', ''), '(p|l)', ['$0' num2str(i)]), 'kBT', num2str(kBT));
            end
            wlcf = fittype(strjoin(c, ' + '));
            
            % map arg names
            argNames = arrayfun(@(n) strcat({'p', 'l'}, num2str(n)), 1:n, 'UniformOutput', false);
            argNames = [argNames{:}];
            coeffNames = coeffnames(wlcf);
            argsIdxMask = cellfun(@(name) find(strcmp(argNames, name)), coeffNames);
            
            % Set fit bounds & method
            lower = reshape([persistenceRange(:, 1)'; contourRange(:, 1)'], size(coeffNames));
            upper = reshape([persistenceRange(:, 2)'; contourRange(:, 2)'], size(coeffNames));
            fitOpt = fitoptions(wlcf);
            fitOpt.Lower = lower(argsIdxMask);
            fitOpt.Upper = upper(argsIdxMask);
            fitOpt.StartPoint = lower(argsIdxMask);
            
            fitOpt.MaxFunEvals = 150;
            fitOpt.MaxIter = 100;
            if nargin >= 7
                fitOpt = fitoptions(fitOpt, params);
            end
            
            [fitArgs, gof, output] = fit(x(:), y(:), wlcf, fitOpt);
            
            p = zeros(n, 1);
            l = zeros(n, 1);
            for i = 1:n
                sidx = num2str(i);
                p(i) = fitArgs.(['p' sidx]);
                l(i) = fitArgs.(['l' sidx]);
            end
        end
        
        function [p, l, gof, output] = fit(x, y, p, l, T, model, params)
            import Simple.Scientific.PhysicalConstants;
            if nargin < 5; T = PhysicalConstants.RT; end
            if nargin < 6; model = ''; end
            
            % Fit type
            kBT = PhysicalConstants.kB * T;
            wlcfunction = Simple.Math.wlc.getWlcFunction(kBT, [], [], model);
            wlcf = fittype(wlcfunction);
            
            % Set fit bounds & method
            fitOpt = fitoptions(wlcf);
            fitOpt.Lower = [0, x(end)];
            
            if nargin >= 4
                fitOpt.StartPoint = [p, l];
            end
            
            fitOpt.MaxFunEvals = 150;
            fitOpt.MaxIter = 100;
            if nargin >= 7
                fitOpt = fitoptions(fitOpt, params);
            end
            
            [fitArgs, gof, output] = fit(x', y', wlcf, fitOpt);
            
            p = fitArgs.p;
            l = fitArgs.l;
        end
        
        function func = createExpretion(kBT, p, l, model)
            if nargin < 4; model = ''; end
            wlcf = Simple.Math.wlc.getWlcFunction(kBT, [], [], model);
            symWlcf = subs(-1*sym(wlcf), {'p', 'l'}, [p, l]);
            func = Simple.Math.Ex.Symbolic(symWlcf);
        end
        
        function wlcfunction = getWlcFunction(kBT, p, l, model)
            if nargin < 4 || isempty(model); model = 'bustamante'; end
            
            % bustamante WLC equation
            % C. Bustamante, J.F. Marko, E.D. Siggia, S. Smith
            % Science, 265 (1994), p. 1599
            % Entropic elasticity of lambda-phage DNA
            % wlcfunction = @(p, l, x) (kBT/p) * (1./(4*(1-(x./l)).^2) + x./l - 1/4);
            
            % bouchiat 7th order polinomial corection to bustamante equation
            % Bouchiat, C., Wang, M. D., Allemand, J. F., Strick, T., Block, S. M., & Croquette, V.
            % (1999), Biophysical journal, 76(1), 409-413,
            % Estimating the persistence length of a worm-like chain molecule from force-extension measurements.
            
            switch lower(model)
                case 'bouchiat'
                    if nargin < 2 || isempty(p)
                        wlcfunction = @(p, l, x) (kBT/p) * (1./(4*(1-(x./l)).^2) + x./l - 1/4 + (-0.516422*(x/l).^2) + (-2.73741*(x/l).^3) + (16.0749*(x/l).^4) + (-38.8760*(x/l).^5) + (39.4994*(x/l).^6) + (-14.1771*(x/l).^7));
                    else
                        wlcfunction = @(x) (kBT/p) * (1./(4*(1-(x./l)).^2) + x./l - 1/4 + (-0.516422*(x./l).^2) + (-2.73741*(x./l).^3) + (16.0749*(x./l).^4) + (-38.8760*(x./l).^5) + (39.4994*(x./l).^6) + (-14.1771*(x./l).^7));
                    end
                case 'bustamante'
                    if nargin < 2 || isempty(p)
                        wlcfunction = @(p, l, x) (kBT/p) * (1./(4*(1-(x./l)).^2) + x./l - 1/4);
                    else
                        wlcfunction = @(x) (kBT/p) * (1./(4*(1-(x./l)).^2) + x./l - 1/4);
                    end
            end
        end
    end
    
    
    
end

