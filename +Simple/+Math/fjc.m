classdef fjc
    % Tool for freely joint chain (FJC) fitting and simmulation
    % math based on:
    %   Janshoff, A., Neitzert, M., Oberd?rfer, Y. and Fuchs, H., 2000. 
    %   Force spectroscopy of molecular systems—single molecule spectroscopy of polymers and biomolecules.
    %   Angewandte Chemie International Edition, 39(18), pp.3212-3237.
    
    methods (Static)
        function f = F(x, lk, L, T)
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
            L = L(:);
            
            % calculate f for each lk-L
            f = kBT./lk(:).*(3*x./L + (9/5)*(x./L).^3 + (297/175)*(x./L).^5 + (1539/875)*(x./L).^7);
        end
        
        function [lk, L, gof, output] = fit(x, y, lk, L, T, params)
            import Simple.Scientific.PhysicalConstants;
            if nargin < 5
                T = PhysicalConstants.RT;
            end
            kBT = PhysicalConstants.kB * T;
            
            % set fitting type
            % FJC extension force is given by the taylor approximation of
            % the inverse langevine function:
            fjcFunction = @(lk, L, x) kBT/lk*(3*x/L + (9/5)*(x/L).^3 + (297/175)*(x/L).^5 + (1539/875)*(x/L).^7);
            fjcf = fittype(fjcFunction);
            
            % Set fit bounds & method
            fitOpt = fitoptions(fjcf);
            fitOpt.Lower = [0, x(end)];
            
            if nargin >= 4
                fitOpt.StartPoint = [lk, L];
            end
            
            fitOpt.MaxFunEvals = 150;
            fitOpt.MaxIter = 100;
            if nargin >= 6
                fitOpt = fitoptions(fitOpt, params);
            end
            
            [fitArgs, gof, output] = fit(x', y', fjcf, fitOpt);
            
            lk = fitArgs.lk;
            L = fitArgs.L;
        end
        
        function func = createExpretion(kBT, lk, L)
            syms x;
            fjcSym = -kBT/lk*(3*x/L + (9/5)*(x/L).^3 + (297/175)*(x/L).^5 + (1539/875)*(x/L).^7);
            func = Simple.Math.Ex.Symbolic(fjcSym);
        end
    end
end

