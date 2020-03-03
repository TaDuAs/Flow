function s = enum2struct(enumClassName)
% enum2struct generates a struct with a field for each enumeration member
% of the specified enum class.
% For example:
% classdef MyEnum
%     enumeration x, y, z end
% end
%
% s = enum2struct('MyEnum')
%     s = 
%       struct with fields:
%
%           x: MyEnum.x
%           y: MyEnum.y
%           z: MyEnum.z

    enum = enumeration(enumClassName);
    s = cell2struct(mat2cell(enum, ones(size(enum))), arrayfun(@char, enum, 'UniformOutput', false));
end

