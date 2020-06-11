function [vars, localParams] = parseExtenderArgs(args, ignoreList)
    
    if nargin < 2; ignoreList = {}; end
    
    extenderParamNames = {'FilterIndex'};
    innerParamNames = {'MultiSelect'};
    
    % exclude ignore list from params lists
    ignoreFlgas = ismember(innerParamNames, ignoreList);
    innerParamNames = innerParamNames(~ignoreFlgas);
    ignoreFlgas = ismember(extenderParamNames, ignoreList);
    extenderParamNames = extenderParamNames(~ignoreFlgas);
    
    % parse local params name-value pairs
    % apply validation and default values
    [vars, extenderArgs] = sui.splitExtenderArgs(args, extenderParamNames, innerParamNames); 
    
    % prep parser
    parser = inputParser();
    parser.FunctionName = 'sui.getfile';
    parser.CaseSensitive = false;
    
    % Reuse returned filter index
    parser.addOptional('FilterIndex', 1, @gen.valid.mustBeFinitePositiveRealScalar);
    
    parser.parse(extenderArgs{:});
    
    localParams = parser.Results;
end
