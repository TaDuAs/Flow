function frm = jframe(fig, stopWarning, varargin)
    if nargin < 1
        fig = gcf;
    end
    if nargin >= 2 && stopWarning
        warning('off', 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
    end
    frm = get(handle(fig), 'JavaFrame');
    
    if nargin > 2
        set(frm, varargin{:});
    end
end

