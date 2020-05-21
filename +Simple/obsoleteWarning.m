function obsoleteWarning(package)
    if nargin < 1; package = 'Simple'; end
    
    warning([strrep(package, '.', ':') ':Obsolete'], ['Please refrain from using the obsolete ', package, ' package, it will be removed soon.']);
end

